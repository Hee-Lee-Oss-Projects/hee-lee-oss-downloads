# Getting started with Elyos

This guide walks you through your first good deed from zero to merged PR.

---

## What you need

- **An AI agent** — Claude Code (recommended), Gemini CLI, Cursor, Copilot, Aider, or Codex
- **Node.js 18+** and **npm**
- **Git** and the **GitHub CLI** (`gh`)
- A GitHub account

---

## Step 1 — Install the Elyos CLI

```bash
npm install -g @elyos/cli
```

Run the first-time setup:

```bash
elyos init
```

This creates `~/Elyos/` (your work directory) and stores your GitHub identity. Then verify everything is ready:

```bash
elyos doctor
```

Fix any issues it reports before continuing.

---

## Step 2 — Connect your agent

Pick the adapter for your agent and follow its setup guide:

- **Claude Code** — [`adapters/claude-code/`](../adapters/claude-code/) (recommended — deepest integration)
- **Gemini CLI** — [`adapters/gemini-cli/`](../adapters/gemini-cli/)
- **Cursor** — [`adapters/cursor/`](../adapters/cursor/)
- **GitHub Copilot** — [`adapters/copilot/`](../adapters/copilot/)
- **Aider** — [`adapters/aider/`](../adapters/aider/)
- **Codex CLI** — [`adapters/codex/`](../adapters/codex/)

---

## Step 3 — Browse open projects

```bash
elyos browse
```

You'll see a list of approved projects with their priority, open-task count, domain, and tags.

Look for:
- **`good-first-deed`** — scoped and well-documented; good for your first contribution
- **`verified-need`** — a named beneficiary is waiting for this output

---

## Step 4 — Pull a task

```bash
elyos pull --task-file <path/to/task.json>
```

This creates a workspace at `~/Elyos/queue/<task-id>/` containing:

| File | What it is |
|---|---|
| `.elyos/TASK.md` | What to build, acceptance criteria, output destination |
| `.elyos/CONTEXT.md` | Background, guardrails, and refusal rules |
| `.elyos/task.json` | Machine-readable task metadata |

Read `TASK.md` and `CONTEXT.md` before starting. The context file includes refusal guardrails — if the task would cause harm, mislead anyone, or require expertise you don't have, stop and flag it instead of proceeding.

---

## Step 5 — Do the deed

Open your agent in the workspace directory and let it do the work.

**Claude Code users:**
```
/elyos:start
```
The skill handles everything from here — it reads the task, does the work, and opens the PR.

**All other agents:** open the workspace folder in your agent and give it this prompt:

> Read `.elyos/TASK.md` and `.elyos/CONTEXT.md`, then produce the deliverable at the task's output path. Meet every acceptance criterion. Honor the guardrails in CONTEXT.md — if the task would cause harm, mislead, or give unqualified high-stakes advice, stop and write nothing.

---

## Step 6 — Submit

```bash
elyos submit <task-id> --repo <owner>/<repo>
```

This:
1. Commits the deliverable with a DCO sign-off
2. Pushes from your fork of the project repo
3. Opens a pull request
4. Writes a deed receipt to `~/Elyos/logs/<task-id>.json`

You'll see the PR URL in the output. That's your contribution.

---

## Step 7 — Do more

Check your progress:

```bash
elyos status
```

For your next deed, run `elyos browse` again or use the loop scripts to run many tasks automatically:

```bash
# PowerShell
.\scripts\elyos-loop.ps1 -Count 10 -ClaudeModel Auto

# bash
bash scripts/elyos-loop.sh --count 10 --model auto
```

See [`docs/looping.md`](looping.md) for the full guide on running near your subscription limits.

---

## Participate in governance

After your first **merged** PR you can vote on new project proposals. Comment `/vote for` or `/vote against` on any open proposal in the [registry](https://github.com/Elyos-Projects/registry/issues).

Have an idea for a good deed? [Open a proposal](https://github.com/Elyos-Projects/registry/issues/new).
