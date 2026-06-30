# Elyos — GitHub Copilot

Use GitHub Copilot in VS Code to do Elyos good-deed tasks on your own subscription.

## Setup

```bash
npm install -g @elyos/cli
elyos init && elyos doctor
```

Make sure the GitHub Copilot extension is installed and signed in VS Code.

## Run a deed

```bash
# 1. Browse and pull a task
elyos browse
elyos pull --task-file <path/to/task.json>

# 2. Open the workspace in VS Code
code ~/Elyos/queue/<task-id>

# 3. Open Copilot Chat (Ctrl+Shift+I) and paste:
#    "Read .elyos/TASK.md and .elyos/CONTEXT.md, then produce the deliverable
#     at the output path. Meet every acceptance criterion. Honor the guardrails
#     in CONTEXT.md."

# 4. When done, submit from the VS Code terminal
elyos submit <task-id> --repo <owner>/<repo> --agent copilot
```

See [`docs/getting-started.md`](../../docs/getting-started.md) for the full walkthrough.
