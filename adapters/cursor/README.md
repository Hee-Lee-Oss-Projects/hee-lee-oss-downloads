# Hee-Lee Oss — Cursor

Use Cursor to do Hee-Lee Oss good-deed tasks on your own subscription.

## Setup

```bash
npm install -g @hee-lee-oss/cli
hee-lee-oss init && hee-lee-oss doctor
```

## Run a deed

```bash
# 1. Browse and pull a task
hee-lee-oss browse
hee-lee-oss pull --task-file <path/to/task.json>

# 2. Open the workspace in Cursor
cursor ~/Hee-Lee Oss/queue/<task-id>

# 3. In Cursor: open the AI chat and paste this prompt
#    "Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable
#     at the output path. Meet every acceptance criterion. Honor the guardrails
#     in CONTEXT.md."

# 4. When done, submit from the terminal
hee-lee-oss submit <task-id> --repo <owner>/<repo> --agent cursor
```

See [`docs/getting-started.md`](../../docs/getting-started.md) for the full walkthrough.
