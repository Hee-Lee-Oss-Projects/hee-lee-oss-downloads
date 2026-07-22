---
description: Start a Hee-Lee Oss good-deed session — pick a community task, do it in THIS interactive Claude Code session (on your subscription), and open a PR. Use when the user runs /hee-lee-oss:start or asks to do a Hee-Lee Oss deed.
disable-model-invocation: true
---

# /hee-lee-oss:start — run a good deed

You will help the user complete a community-approved **good deed** using *this* interactive
Claude Code session. Hee-Lee Oss's donated-compute lane runs on the user's **subscription** — so this
must stay interactive.

## 0. Billing & safety pre-flight (do this first, every time)
- **Refuse to proceed if `ANTHROPIC_API_KEY` is set** in the environment. That would bill the
  pay-as-you-go API instead of the user's subscription. Tell the user to unset it and restart.
- Confirm `hee-lee-oss` is installed: run `hee-lee-oss doctor`. If git/gh aren't ready, help fix that first.

## 1. Pick a task
- Run `hee-lee-oss browse` to show approved projects.
- Ask the user which project/task, or accept a task file path from `$ARGUMENTS`.
- If the user passes a task file, use `--task-file <path>`.

## 2. Prepare the workspace
- Preview first: `hee-lee-oss pull --task-file <path> --dry-run`.
- Then prepare it for real: `hee-lee-oss pull --task-file <path>`.
- This creates a workspace under `~/Hee-Lee Oss/queue/<task-id>/` with `TASK.md`, `CONTEXT.md`, and a
  claim file. If a claim already exists, it resumes — do not duplicate work.

## 3. Do the work (this is the deed)
- `cd` into the workspace. Read `TASK.md` and `CONTEXT.md` fully.
- **Honor the refusal guardrails in `CONTEXT.md`.** If the task would cause harm, mislead, give
  unqualified high-stakes advice without the required review, or primarily benefit a for-profit —
  **stop and tell the user** instead of proceeding.
- Produce the deliverable at the task's **Output destination**. Meet every acceptance criterion.
  For non-code deliverables (translation/document/dataset), produce the artifact itself.

## 4. Submit
- Run: `hee-lee-oss submit <task-id> --repo <project-owner>/<project-repo> --agent claude-code`
- This commits, pushes from the user's fork, opens the PR, and writes a deed receipt.
- Share the PR URL with the user.

## 5. Loop or stop
- Ask if they want another task. If yes, use `/hee-lee-oss:next`.
- Respect the budget guard — if `hee-lee-oss pull` reports the session cap is reached, stop gracefully.

Keep the user informed at each step. Never run headless; never set an API key.
