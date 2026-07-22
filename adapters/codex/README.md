# Hee-Lee Oss — Codex CLI

Use OpenAI Codex CLI to do Hee-Lee Oss good-deed tasks.

## Setup

```bash
npm install -g @hee-lee-oss/cli
hee-lee-oss init && hee-lee-oss doctor
npm install -g @openai/codex
```

## Run a deed

```bash
# 1. Browse and pull a task
hee-lee-oss browse
hee-lee-oss pull --task-file <path/to/task.json>

# 2. Run Codex in the workspace
cd ~/Hee-Lee Oss/queue/<task-id>
codex "Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable at the output path. Meet every acceptance criterion. Honor the guardrails in CONTEXT.md."

# 3. Submit
hee-lee-oss submit <task-id> --repo <owner>/<repo> --agent codex
```

See [`docs/getting-started.md`](../../docs/getting-started.md) for the full walkthrough.
