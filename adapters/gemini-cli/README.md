# Hee-Lee Oss — Gemini CLI

Use Gemini CLI to do Hee-Lee Oss good-deed tasks on your own Google subscription.

## Setup

```bash
npm install -g @hee-lee-oss/cli
hee-lee-oss init && hee-lee-oss doctor
```

Make sure `gemini` is installed and authenticated:

```bash
gemini --version
```

## Run a single deed

```bash
# 1. Browse and pick a task
hee-lee-oss browse

# 2. Pull the workspace
hee-lee-oss pull --task-file <path/to/task.json>

# 3. Run Gemini in the workspace
cd ~/Hee-Lee Oss/queue/<task-id>
gemini "Read .hee-lee-oss/TASK.md and .hee-lee-oss/CONTEXT.md, then produce the deliverable at the output path. Meet every acceptance criterion."

# 4. Submit
hee-lee-oss submit <task-id> --repo <owner>/<repo> --agent gemini-cli
```

## Loop through many tasks

Use the loop scripts with `--agent gemini-cli` and replace the claude invocation with gemini in the script, or run each deed manually with the steps above.

See [`docs/getting-started.md`](../../docs/getting-started.md) and [`docs/looping.md`](../../docs/looping.md).
