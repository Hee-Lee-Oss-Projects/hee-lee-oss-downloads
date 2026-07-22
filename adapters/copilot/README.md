# Hee-Lee Oss — GitHub Copilot

Use GitHub Copilot in VS Code to do Hee-Lee Oss good-deed tasks on your own subscription.

## Setup

```bash
npm install -g @hee-lee-oss/cli
hee-lee-oss init && hee-lee-oss doctor
```

Make sure the GitHub Copilot extension is installed and signed in VS Code.

## Run a deed

```bash
# 1. Browse and pull a task
hee-lee-oss browse
hee-lee-oss pull --task-file <path/to/task.json>

# 2. Open the workspace in VS Code
code ~/Hee-Lee Oss/queue/<task-id>

# 3. Open Copilot Chat (Ctrl+Shift+I) and paste:
#    "Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable
#     at the output path. Meet every acceptance criterion. Honor the guardrails
#     in CONTEXT.md."

# 4. When done, submit from the VS Code terminal
hee-lee-oss submit <task-id> --repo <owner>/<repo> --agent copilot
```

See [`docs/getting-started.md`](../../docs/getting-started.md) for the full walkthrough.
