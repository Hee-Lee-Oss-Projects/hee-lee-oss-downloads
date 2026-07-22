---
description: Show the user's Hee-Lee Oss status — active task claims and completed deeds (receipts). Use when the user runs /hee-lee-oss:status or asks how many deeds they've done.
disable-model-invocation: true
---

# /hee-lee-oss:status — show progress

1. Run `hee-lee-oss status` and show the result (active claims + completed deeds).
2. If the user wants detail, list recent receipts from `~/Hee-Lee Oss/logs/` (each is a JSON file with
   task id, project, agent, duration, PR URL, and — for funded tasks — cost).
3. Summarize impact in plain language (e.g. "you've completed N deeds across M projects").

Read-only — this skill never modifies anything.
