---
description: Pull and complete the NEXT Elyos good-deed task in this interactive session, continuing a session started with /elyos:start. Use when the user runs /elyos:next.
disable-model-invocation: true
---

# /elyos:next — do the next deed

Continue an Elyos session with the next task. Same rules as `/elyos:start`:

1. **Pre-flight:** refuse if `ANTHROPIC_API_KEY` is set (must stay on subscription).
2. Check the budget guard: run `elyos status`. If active claims have reached the configured
   `maxTasksPerSession`, stop and tell the user the session cap is reached.
3. Pick the next task (`elyos browse`, or the next from `$ARGUMENTS`).
4. `elyos pull --task-file <path> --dry-run`, then `elyos pull --task-file <path>`.
5. Do the work in the workspace, honoring the refusal guardrails in `CONTEXT.md`.
6. `elyos submit <task-id> --repo <owner>/<repo> --agent claude-code`; share the PR URL.
7. Offer another, or stop gracefully.

This skill is for looping through tasks while the user is present. It is interactive — never
headless, never with an API key set.
