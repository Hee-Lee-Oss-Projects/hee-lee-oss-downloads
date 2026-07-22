---
description: Pull and complete the NEXT Hee-Lee Oss good-deed task in this interactive session, continuing a session started with /hee-lee-oss:start. Use when the user runs /hee-lee-oss:next.
disable-model-invocation: true
---

# /hee-lee-oss:next — do the next deed

Continue a Hee-Lee Oss session with the next task. Same rules as `/hee-lee-oss:start`:

1. **Pre-flight:** refuse if `ANTHROPIC_API_KEY` is set (must stay on subscription).
2. Check the budget guard: run `hee-lee-oss status`. If active claims have reached the configured
   `maxTasksPerSession`, stop and tell the user the session cap is reached.
3. Pick the next task (`hee-lee-oss browse`, or the next from `$ARGUMENTS`).
4. `hee-lee-oss pull --task-file <path> --dry-run`, then `hee-lee-oss pull --task-file <path>`.
5. Do the work in the workspace, honoring the refusal guardrails in `CONTEXT.md`.
6. `hee-lee-oss submit <task-id> --repo <owner>/<repo> --agent claude-code`; share the PR URL.
7. Offer another, or stop gracefully.

This skill is for looping through tasks while the user is present. It is interactive — never
headless, never with an API key set.
