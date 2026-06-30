# Looping through tasks — running near your limits

The Elyos loop scripts (`elyos-loop.ps1` / `elyos-loop.sh`) are designed to let you run many good-deed tasks end-to-end in a single session, automatically, without manually managing each one.

This guide explains how to get the most out of a session without blowing past your API limits.

---

## How the loop works

Each iteration does four things:

1. **`elyos next`** — picks the next eligible task and prepares a workspace (`~/Elyos/queue/<task-id>/`) with `TASK.md`, `CONTEXT.md`, and a claim file
2. **`claude -p`** (or your chosen agent) — runs in the workspace and produces the deliverable
3. **`elyos submit`** — commits the output, pushes from your fork, opens the PR, and writes a deed receipt
4. **Workspace cleanup** — deletes the workspace (freeing the session-cap slot) and moves to the next task

Each task is a fresh agent invocation. Context is reset between tasks, so you never hit the per-conversation limit regardless of how many deeds you run.

---

## Understanding your limits

### Subscription context window (the main limit)

Each `claude -p` call gets its own context window. Most Elyos tasks are scoped to fit comfortably within a single invocation. The loop handles the reset automatically — when one task finishes, the next starts with a clean slate.

**You do not need to worry about hitting conversation limits.** The loop design prevents it.

### Session cap (your configurable ceiling)

Elyos tracks how many active task claims you hold at once. The default cap is in `~/Elyos/config.yaml`:

```yaml
maxTasksPerSession: 10
```

When the cap is reached, `elyos next` stops returning tasks and the loop exits gracefully. Raise this number to run longer sessions:

```yaml
maxTasksPerSession: 100
```

The session cap is a safety rail, not a limit imposed by your subscription. It exists to prevent one session from claiming all available tasks and starving other contributors.

### Rate limits

If you are running many fast tasks (small content tasks on Haiku), you may hit Claude's rate limits. Signs: the agent starts returning errors or truncated output. Solutions:

- Use `--model sonnet` instead of `haiku` (fewer requests per task)
- Reduce `--count` and run multiple shorter sessions
- Add a brief manual pause between sessions

---

## Choosing your count

| Session goal | Recommended count |
|---|---|
| First try / test setup | `3` with `--dry-run` |
| A quick afternoon session | `5–10` |
| An unattended evening run | `20–50` |
| Maximize a full subscription cycle | `100+` (raise `maxTasksPerSession` first) |

The loop stops cleanly when it runs out of tasks, so setting a high count is safe — it just means "run until the queue is empty or you hit this number."

---

## Auto model selection (recommended)

Pass `--model auto` (`-ClaudeModel Auto` on PowerShell) to let Elyos pick the right model tier per task:

| Task characteristics | Model chosen | Why |
|---|---|---|
| `riskTier: high` OR `tokenEstimate: large` | **opus** | High-stakes or complex tasks need the most capable model |
| `riskTier: medium` OR `tokenEstimate: medium` | **sonnet** | Balanced quality and speed |
| `riskTier: low` AND `tokenEstimate: small` | **haiku** | Fast, cheap, fine for simple content tasks |

This means a session with 50 tasks might use Haiku for 30 of them, Sonnet for 15, and Opus for 5 — dramatically extending how much you can do on a fixed subscription.

```powershell
# PowerShell
.\elyos-loop.ps1 -Count 50 -ClaudeModel Auto

# bash
bash elyos-loop.sh --count 50 --model auto
```

---

## Permission modes

| Mode | What it does | Best for |
|---|---|---|
| `acceptEdits` (default) | Auto-approves file writes; prompts for shell commands | Most content and documentation tasks |
| `skip` | Fully unattended (`--dangerously-skip-permissions`) | Trusted content tasks where you want zero interruptions |

For `skip` mode: review a few tasks first with `--dry-run` to confirm the task types are appropriate before going fully unattended.

```powershell
.\elyos-loop.ps1 -Count 20 -ClaudeModel Auto -PermissionMode skip
```

---

## Targeting a specific project

```powershell
# PowerShell — run 30 deeds on the open coding curriculum
.\elyos-loop.ps1 -Repo Elyos-Projects/open-coding-curriculum -Count 30 -ClaudeModel Auto

# bash
bash elyos-loop.sh --repo Elyos-Projects/open-coding-curriculum --count 30 --model auto
```

Omit `--repo` to let Elyos auto-pick the highest-priority task across all projects.

---

## Safe testing before a long run

Always test with `--dry-run` first. It prepares each workspace but skips the agent and submit:

```powershell
.\elyos-loop.ps1 -Count 3 -DryRun
```

Check that `~/Elyos/queue/` contains the workspaces and that `TASK.md` looks sensible. Then run for real.

---

## If the loop stops early

| Message | Cause | Fix |
|---|---|---|
| `Session cap reached` | `maxTasksPerSession` hit | Raise the cap in `~/Elyos/config.yaml` |
| `No more eligible tasks` | Queue empty for this project/lane | Try without `--repo` to pick from the full registry |
| `No PR reported for <task-id>` | Agent produced no changes | Inspect workspace; the deliverable may need manual review |
| `ANTHROPIC_API_KEY is set` | API key detected | Unset it: `$env:ANTHROPIC_API_KEY = $null` (PowerShell) or `unset ANTHROPIC_API_KEY` (bash) |

---

## Checking your progress

At any time:

```bash
elyos status
```

Shows active claims, completed deeds, and the URLs of PRs you've opened. Each deed also writes a receipt to `~/Elyos/logs/<task-id>.json` with the PR URL, duration, and model used.

---

## Full example: maximize an evening session

```powershell
# PowerShell — 100 deeds, auto model, no prompts, raise the cap first
# 1. Raise the session cap
(Get-Content ~/Elyos/config.yaml) -replace 'maxTasksPerSession: \d+', 'maxTasksPerSession: 200' |
  Set-Content ~/Elyos/config.yaml

# 2. Run
.\elyos-loop.ps1 -Count 100 -ClaudeModel Auto -PermissionMode skip
```

```bash
# bash — same thing
sed -i 's/maxTasksPerSession: [0-9]*/maxTasksPerSession: 200/' ~/Elyos/config.yaml
bash elyos-loop.sh --count 100 --model auto --permission-mode skip
```

Leave it running. Come back to a list of PRs.
