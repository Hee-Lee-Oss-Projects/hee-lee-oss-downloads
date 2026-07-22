#!/usr/bin/env bash
# hee-lee-oss-loop.sh — loop through Hee-Lee Oss good-deed tasks using your own AI agent (donated-compute lane)
#
# Usage:
#   bash hee-lee-oss-loop.sh [options]
#
# Options:
#   --count N          Number of deeds to attempt (default: 5)
#   --repo OWNER/NAME  Target project repo (omit to auto-pick from registry)
#   --model MODEL      Model for claude -p: sonnet, opus, haiku, or "auto" (recommended)
#                      "auto" picks per task: large/high-risk=opus, medium=sonnet, small=haiku
#   --agent NAME       Agent name in receipt (default: claude-code)
#   --lane LANE        donated (default) or funded
#   --permission-mode  acceptEdits (default) or skip (fully unattended)
#   --no-fork          Push directly to project repo (only if you have write access)
#   --keep-workspaces  Keep workspaces after submit (default: delete on success)
#   --dry-run          Prepare workspaces only; skip agent and submit
#   --work-dir DIR     Root workspace directory (default: ~/Hee-Lee Oss)
#   --help             Show this help
#
# Prerequisites:
#   npm install -g @hee-lee-oss/cli
#   hee-lee-oss init && hee-lee-oss doctor
#   gh auth login
#
# Examples:
#   bash hee-lee-oss-loop.sh --count 10 --model auto
#   bash hee-lee-oss-loop.sh --repo Hee-Lee-Oss-Projects/open-coding-curriculum --count 20 --model sonnet
#   bash hee-lee-oss-loop.sh --count 3 --dry-run
#   bash hee-lee-oss-loop.sh --count 50 --model auto --permission-mode skip

set -euo pipefail

# Defaults
COUNT=5
REPO=""
MODEL=""
AGENT="claude-code"
LANE="donated"
PERMISSION_MODE="acceptEdits"
NO_FORK=false
KEEP_WORKSPACES=false
DRY_RUN=false
WORK_DIR="${HOME}/Hee-Lee Oss"
PROMPT="Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable at the task's output path. Meet every acceptance criterion. Honor the refusal guardrails in CONTEXT.md — if the task would cause harm, mislead, give unqualified high-stakes advice without required review, primarily benefit a for-profit, or violate a license or privacy, STOP and write nothing."

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --count)           COUNT="$2";           shift 2 ;;
    --repo)            REPO="$2";            shift 2 ;;
    --model)           MODEL="$2";           shift 2 ;;
    --agent)           AGENT="$2";           shift 2 ;;
    --lane)            LANE="$2";            shift 2 ;;
    --permission-mode) PERMISSION_MODE="$2"; shift 2 ;;
    --no-fork)         NO_FORK=true;         shift ;;
    --keep-workspaces) KEEP_WORKSPACES=true; shift ;;
    --dry-run)         DRY_RUN=true;         shift ;;
    --work-dir)        WORK_DIR="$2";        shift 2 ;;
    --help|-h)
      sed -n '3,40p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

# --- Safety: donated lane must not use ANTHROPIC_API_KEY ---
if [[ "$LANE" == "donated" ]] && [[ -n "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "ERROR: ANTHROPIC_API_KEY is set." >&2
  echo "The donated lane runs on your Claude subscription, not the API." >&2
  echo "Unset it first:  unset ANTHROPIC_API_KEY" >&2
  echo "Or re-run with: --lane funded" >&2
  exit 1
fi

# --- Check prerequisites ---
if ! command -v hee-lee-oss &>/dev/null; then
  echo "ERROR: hee-lee-oss not found. Install with: npm install -g @hee-lee-oss/cli" >&2
  exit 1
fi
if ! command -v claude &>/dev/null; then
  echo "ERROR: claude not found. Install Claude Code: https://claude.ai/code" >&2
  exit 1
fi

# --- Auto model: read task.json to pick the right model tier ---
get_auto_model() {
  local ws="$1"
  local task_file="$ws/.hee-lee-oss/task.json"
  local effort="medium" risk="medium"
  if [[ -f "$task_file" ]]; then
    effort=$(python3 -c "import json,sys; d=json.load(open('$task_file')); print(d.get('tokenEstimate','medium'))" 2>/dev/null || echo "medium")
    risk=$(python3   -c "import json,sys; d=json.load(open('$task_file')); print(d.get('riskTier','medium'))"    2>/dev/null || echo "medium")
  fi
  if [[ "$risk" == "high"   || "$effort" == "large"  ]]; then echo "opus";   return; fi
  if [[ "$risk" == "medium" || "$effort" == "medium" ]]; then echo "sonnet"; return; fi
  echo "haiku"
}

# --- Build hee-lee-oss next args ---
NEXT_ARGS=("next" "--lane" "$LANE")
[[ -n "$REPO" ]]   && NEXT_ARGS+=("--repo" "$REPO")
[[ "$NO_FORK" == true ]] && NEXT_ARGS+=("--no-fork")

DONE=0
PR_URLS=()

echo ""
echo "Hee-Lee Oss loop starting — up to $COUNT deed(s), lane: $LANE"
[[ "$DRY_RUN" == true ]] && echo "[DRY RUN — agent and submit steps will be skipped]"
echo ""

for ((i=1; i<=COUNT; i++)); do
  echo "=== deed $i / $COUNT ==="

  # Pick and prepare the next task
  NEXT_OUT=$(hee-lee-oss "${NEXT_ARGS[@]}" 2>&1) || true
  echo "$NEXT_OUT"

  # Parse the machine-readable output line
  if ! echo "$NEXT_OUT" | grep -q "HEE_LEE_OSS_NEXT"; then
    if echo "$NEXT_OUT" | grep -q "session cap"; then
      echo "Session cap reached. Raise maxTasksPerSession in ~/Hee-Lee Oss/config.yaml, or submit/clear ready work."
    else
      echo "No more eligible tasks — stopping."
    fi
    break
  fi

  TASK_ID=$(echo "$NEXT_OUT"  | grep -oP 'taskId=\K\S+')
  REPO_USED=$(echo "$NEXT_OUT" | grep -oP 'repo=\K\S+')
  WS=$(echo "$NEXT_OUT"       | grep -oP 'workspace=\K[^ ]+')

  if [[ ! -d "$WS" ]]; then
    echo "WARNING: workspace not found at $WS — stopping." >&2
    break
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "[dry run] prepared $TASK_ID at $WS"
    [[ "$KEEP_WORKSPACES" != true ]] && rm -rf "$WS"
    continue
  fi

  # Resolve model
  RESOLVED_MODEL="$MODEL"
  if [[ "${MODEL,,}" == "auto" ]]; then
    RESOLVED_MODEL=$(get_auto_model "$WS")
  fi

  # Build claude arguments
  CLAUDE_ARGS=("-p" "$PROMPT")
  if [[ "$PERMISSION_MODE" == "skip" ]]; then
    CLAUDE_ARGS+=("--dangerously-skip-permissions")
  else
    CLAUDE_ARGS+=("--permission-mode" "acceptEdits")
  fi
  [[ -n "$RESOLVED_MODEL" ]] && CLAUDE_ARGS+=("--model" "$RESOLVED_MODEL")

  MODEL_LABEL=${RESOLVED_MODEL:+" (model: $RESOLVED_MODEL)"}
  echo "-> running agent on $TASK_ID$MODEL_LABEL..."

  (cd "$WS" && claude "${CLAUDE_ARGS[@]}")

  # Submit: commit, push, open PR, write receipt
  echo "-> submitting $TASK_ID..."
  SUBMIT_OUT=$(hee-lee-oss submit "$TASK_ID" --repo "$REPO_USED" --agent "$AGENT" 2>&1) || true
  echo "$SUBMIT_OUT"

  PR_URL=$(echo "$SUBMIT_OUT" | grep -oP 'https://github\.com/\S+?/pull/\d+' | head -1)
  if [[ -n "$PR_URL" ]]; then
    echo "PR opened: $PR_URL"
    PR_URLS+=("$PR_URL")
    ((DONE++))
    [[ "$KEEP_WORKSPACES" != true ]] && rm -rf "$WS"
  else
    echo "WARNING: No PR reported for $TASK_ID. Workspace kept at $WS for inspection."
  fi

  echo ""
done

# Summary
echo "============================="
echo "Done. $DONE deed(s) completed."
if [[ ${#PR_URLS[@]} -gt 0 ]]; then
  echo "PRs opened:"
  for url in "${PR_URLS[@]}"; do echo "  $url"; done
fi
echo ""
hee-lee-oss status
