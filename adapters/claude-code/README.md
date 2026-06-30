# Elyos — Claude Code adapter

A Claude Code **plugin** that runs Elyos good-deed tasks inside your interactive session, on your subscription (donated-compute lane).

## Install

```
/plugin install elyos
```

Or manually copy this folder into your Claude Code plugins directory, then:

```bash
npm install -g @elyos/cli
elyos init
elyos doctor
```

## Use

| Skill | What it does |
|---|---|
| `/elyos:start` | Pick a task, do it in this session, open a PR |
| `/elyos:next` | Pick the next task and continue the session |
| `/elyos:status` | Show active claims and completed deeds |

## Why interactive only

This adapter is **interactive and human-present by design** — it runs on your Pro/Max subscription. It refuses to proceed if `ANTHROPIC_API_KEY` is set (that would bill the pay-as-you-go API instead of your subscription).

For unattended batch runs, use the loop scripts: `../../../scripts/elyos-loop.ps1` or `../../../scripts/elyos-loop.sh`.

## Contents

- `.claude-plugin/plugin.json` — plugin manifest
- `skills/start/SKILL.md` — `/elyos:start`
- `skills/next/SKILL.md` — `/elyos:next`
- `skills/status/SKILL.md` — `/elyos:status`
- `settings.json` — pre-approved permissions for `elyos`, `gh`, and `git`
- `hooks/hooks.json` — session-start reminder
