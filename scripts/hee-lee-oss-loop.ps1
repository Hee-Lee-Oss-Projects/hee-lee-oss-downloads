<#
.SYNOPSIS
    Loop through Hee-Lee Oss good-deed tasks using your own AI agent (donated-compute lane).

.DESCRIPTION
    Runs a batch of Hee-Lee Oss good deeds end-to-end:
      hee-lee-oss next  ->  your agent (claude -p)  ->  hee-lee-oss submit  ->  repeat

    Each deed runs in a fresh agent invocation so context stays within limits.
    The loop stops when it reaches -Count, the session cap, or the task queue is empty.

    IMPORTANT: This runs on YOUR subscription (donated lane).
    Do NOT set ANTHROPIC_API_KEY — that bills the API instead of your subscription.
    The script will refuse to continue if ANTHROPIC_API_KEY is detected.

.PARAMETER Repo
    Target project repo (e.g. "Hee-Lee-Oss-Projects/open-coding-curriculum").
    Omit to let Hee-Lee Oss auto-pick the highest-priority project from the registry.

.PARAMETER Count
    Number of deeds to attempt this run. Default: 5.
    Set higher (20-50) for an unattended session. The session cap in ~/Hee-Lee Oss/config.yaml
    is the safety ceiling — the loop stops automatically when it is reached.

.PARAMETER ClaudeModel
    Model passed to claude -p via --model.
    Pass "Auto" (recommended) to pick per task based on effort and risk:
      large/high-risk  -> opus   (careful, thorough)
      medium           -> sonnet (balanced)
      small/low-risk   -> haiku  (fast and cheap)
    Omit to use your Claude Code default model.

.PARAMETER Agent
    Agent identifier recorded in the deed receipt. Default: "claude-code".
    Set to "gemini-cli", "cursor", "aider", "codex", or "copilot" if using another agent.

.PARAMETER Prompt
    The instruction sent to your agent for each task. The default covers all Hee-Lee Oss task types
    and includes the required guardrail clause. Only override if you have a good reason.

.PARAMETER PermissionMode
    How to handle agent permission prompts:
      acceptEdits  (default) - auto-approve file writes; prompts for commands/tool use
      skip         - fully unattended (--dangerously-skip-permissions); use for trusted content tasks

.PARAMETER DryRun
    Prepare each workspace but skip the agent and submit steps. Safe for testing setup.

.PARAMETER NoFork
    Push the branch directly to the project repo instead of forking.
    Use only when you have write access (e.g. you are a project maintainer).

.PARAMETER KeepWorkspaces
    Keep each workspace after submit. Default: delete on success (frees the session-cap slot).

.PARAMETER WorkDir
    Root directory for Hee-Lee Oss workspaces. Default: ~/Hee-Lee Oss

.EXAMPLE
    # Run 10 deeds auto-picking tasks and models (recommended starting point)
    .\hee-lee-oss-loop.ps1 -Count 10 -ClaudeModel Auto

.EXAMPLE
    # Run 20 deeds against a specific project on Sonnet
    .\hee-lee-oss-loop.ps1 -Repo Hee-Lee-Oss-Projects/open-coding-curriculum -Count 20 -ClaudeModel sonnet

.EXAMPLE
    # Test your setup without running the agent or opening PRs
    .\hee-lee-oss-loop.ps1 -Count 3 -DryRun

.EXAMPLE
    # Fully unattended session: 50 content tasks, auto-model, no prompts
    .\hee-lee-oss-loop.ps1 -Count 50 -ClaudeModel Auto -PermissionMode skip

.NOTES
    Prerequisites:
      npm install -g @hee-lee-oss/cli
      hee-lee-oss init
      hee-lee-oss doctor
      gh auth login
#>
[CmdletBinding()]
param(
    [string]$Repo,
    [int]$Count = 5,
    [string]$ClaudeModel = "",
    [string]$Agent = "claude-code",
    [string]$Prompt = "Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable at the task's output path. Meet every acceptance criterion. Honor the refusal guardrails in CONTEXT.md — if the task would cause harm, mislead, give unqualified high-stakes advice without required review, primarily benefit a for-profit, or violate a license or privacy, STOP and write nothing.",
    [ValidateSet("acceptEdits", "skip")][string]$PermissionMode = "acceptEdits",
    [switch]$DryRun,
    [switch]$NoFork,
    [switch]$KeepWorkspaces,
    [string]$WorkDir = "$env:USERPROFILE\Hee-Lee Oss",
    [ValidateSet("donated", "funded")][string]$Lane = "donated"
)

$ErrorActionPreference = "Stop"

# --- Safety: donated lane must run on subscription, not API key ---
if ($Lane -eq "donated" -and $env:ANTHROPIC_API_KEY) {
    Write-Error @"
ANTHROPIC_API_KEY is set. The donated lane runs on your Claude subscription, not the API.
Setting the API key would charge your API account instead.

Unset it and re-run:
  `$env:ANTHROPIC_API_KEY = `$null

If you intend to use the funded lane, re-run with: -Lane funded
"@
    return
}

# --- Locate the hee-lee-oss CLI ---
if (-not (Get-Command hee-lee-oss -ErrorAction SilentlyContinue)) {
    Write-Error "hee-lee-oss not found on PATH. Install it with: npm install -g @hee-lee-oss/cli"
    return
}
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Error "claude not found on PATH. Install Claude Code: https://claude.ai/code"
    return
}

function Invoke-Hee-Lee Oss {
    param([Parameter(ValueFromRemainingArguments = $true)] $RestArgs)
    $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
    try { & hee-lee-oss @RestArgs } finally { $ErrorActionPreference = $old }
}

# --- Auto model: pick per task based on effort and risk tier saved in task.json ---
function Get-AutoModel([string]$workspace) {
    $taskFile = Join-Path $workspace ".hee-lee-oss\task.json"
    $effort = "medium"; $risk = "medium"
    if (Test-Path $taskFile) {
        try {
            $t = Get-Content $taskFile -Raw | ConvertFrom-Json
            if ($t.tokenEstimate) { $effort = "$($t.tokenEstimate)" }
            if ($t.riskTier)      { $risk   = "$($t.riskTier)" }
        } catch {}
    }
    if ($risk -eq "high" -or $effort -eq "large") { return "opus" }
    if ($risk -eq "medium" -or $effort -eq "medium") { return "sonnet" }
    return "haiku"
}

# --- Main loop ---
$done    = 0
$prUrls  = @()
$nextArgs = @("next", "--lane", $Lane)
if ($Repo)   { $nextArgs += @("--repo", $Repo) }
if ($NoFork) { $nextArgs += "--no-fork" }

Write-Host ""
Write-Host "Hee-Lee Oss loop starting — up to $Count deed(s), lane: $Lane" -ForegroundColor Cyan
if ($DryRun) { Write-Host "[DRY RUN — agent and submit steps will be skipped]" -ForegroundColor Yellow }
Write-Host ""

for ($i = 1; $i -le $Count; $i++) {
    Write-Host "=== deed $i / $Count ===" -ForegroundColor Cyan

    # Pick and prepare the next task
    $out = (Invoke-Hee-Lee Oss @nextArgs 2>&1 | Out-String)
    Write-Host $out

    $m = [regex]::Match($out, 'HEE_LEE_OSS_NEXT taskId=(\S+) repo=(\S+) workspace=(.+?) output=(\S+)')
    if (-not $m.Success) {
        if ($out -match 'session cap') {
            Write-Warning "Session cap reached. Raise maxTasksPerSession in ~/Hee-Lee Oss/config.yaml, or run -SubmitReady to clear completed work."
        } else {
            Write-Host "No more eligible tasks — stopping." -ForegroundColor Yellow
        }
        break
    }

    $taskId  = $m.Groups[1].Value
    $repoUsed = $m.Groups[2].Value
    $ws       = $m.Groups[3].Value.Trim()

    if (-not (Test-Path $ws)) {
        Write-Warning "Workspace not found at $ws — stopping. Check ~/Hee-Lee Oss/config.yaml for session cap settings."
        break
    }

    if ($DryRun) {
        Write-Host "[dry run] prepared $taskId at $ws" -ForegroundColor DarkGray
        if (-not $KeepWorkspaces) { Remove-Item -Recurse -Force $ws }
        continue
    }

    # Resolve model for this task
    $model = $ClaudeModel
    if ($ClaudeModel -eq "Auto") { $model = Get-AutoModel $ws }

    # Build claude arguments
    $claudeArgs = @("-p", $Prompt)
    if ($PermissionMode -eq "skip") {
        $claudeArgs += "--dangerously-skip-permissions"
    } else {
        $claudeArgs += @("--permission-mode", "acceptEdits")
    }
    if ($model) { $claudeArgs += @("--model", $model) }

    $modelLabel = if ($model) { " (model: $model)" } else { "" }
    Write-Host "-> running agent on $taskId$modelLabel..." -ForegroundColor DarkGray

    Push-Location $ws
    try { & claude @claudeArgs }
    finally { Pop-Location }

    # Submit: commit, push, open PR, write receipt
    Write-Host "-> submitting $taskId..." -ForegroundColor DarkGray
    $submitArgs = @("submit", $taskId, "--repo", $repoUsed, "--agent", $Agent)
    $submitOut  = (Invoke-Hee-Lee Oss @submitArgs 2>&1 | Out-String)
    Write-Host $submitOut

    $prMatch = [regex]::Match($submitOut, 'https://github\.com/\S+?/pull/\d+')
    if ($prMatch.Success) {
        Write-Host "PR opened: $($prMatch.Value)" -ForegroundColor Green
        $prUrls += $prMatch.Value
        $done++
        if (-not $KeepWorkspaces) { Remove-Item -Recurse -Force $ws }
    } else {
        Write-Warning "No PR reported for $taskId. Workspace kept at $ws for inspection."
    }

    Write-Host ""
}

# Summary
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Done. $done deed(s) completed." -ForegroundColor Green
if ($prUrls.Count) {
    Write-Host "PRs opened:"
    $prUrls | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
}
Write-Host ""
Invoke-Hee-Lee Oss status
