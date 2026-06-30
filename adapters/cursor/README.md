# Elyos — Cursor

Use Cursor to do Elyos good-deed tasks on your own subscription.

## Setup

```bash
npm install -g @elyos/cli
elyos init && elyos doctor
```

## Run a deed

```bash
# 1. Browse and pull a task
elyos browse
elyos pull --task-file <path/to/task.json>

# 2. Open the workspace in Cursor
cursor ~/Elyos/queue/<task-id>

# 3. In Cursor: open the AI chat and paste this prompt
#    "Read .elyos/TASK.md and .elyos/CONTEXT.md, then produce the deliverable
#     at the output path. Meet every acceptance criterion. Honor the guardrails
#     in CONTEXT.md."

# 4. When done, submit from the terminal
elyos submit <task-id> --repo <owner>/<repo> --agent cursor
```

See [`docs/getting-started.md`](../../docs/getting-started.md) for the full walkthrough.
