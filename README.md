# .agents-system

> The **system repo** for [agents-cli](https://www.npmjs.com/package/@swarmify/agents-cli) — npm-shipped defaults for commands, skills, hooks, rules, and permissions.

<p align="center">
  <img src=".assets/claude.png" height="60" alt="Claude" style="margin: 0 10px;">
  <img src=".assets/cursor.png" height="60" alt="Cursor" style="margin: 0 10px;">
  <img src=".assets/gemini.png" height="60" alt="Gemini" style="margin: 0 10px;">
</p>

## What this is

`agents-cli` uses layered configuration. Three repos with the same shape but different roles:

| Repo | Role | Edited by |
|---|---|---|
| `<project>/.agents/` | **Project** — repo-specific overrides | Project maintainers |
| `~/.agents/` | **User** — your personal additions and overrides | You |
| `~/.agents-system/` (this one) | **System** — npm-shipped defaults | Upstream PRs |

Resources resolve **project > user > system**. Same-named resource at a higher layer wins, everything else unions.

## Quick start

```bash
npm install -g @swarmify/agents-cli
agents view          # show what's installed
```

## What's tracked

```
.agents-system/
  commands/        # slash commands (/plan, /debug, /done, ...)
  skills/          # capabilities (agents-cli, browser, teams, ...)
  hooks/           # lifecycle scripts + hooks.yaml manifest
  rules/           # AGENTS.md + modular rule fragments
  permissions/     # permission groups + presets
```

Each directory has its own README.

## Commands

Slash commands are prompt templates. `commands/<name>.md` becomes `/<name>`.

| Command | Purpose |
|---------|---------|
| `/plan` | Plan with research, code reading, artifacts, optional team review |
| `/debug` | Root-cause analysis with full evidence chain |
| `/done` | Verify work is complete, test, release, create tickets for remaining |
| `/audit` | Multi-perspective security audit using agent teams |
| `/clean` | Remove tech debt, consolidate duplicates |
| `/test` | Test critical paths with parallel validation |
| `/recap` | Summarize state — facts first, hypotheses grounded |
| `/commit` | Stage, conventional commit, push in background |
| `/continue` | Resume previous session with context recovery |
| `/issues` | Work with issue tracker (auto-detects Linear/GitHub/Jira) |
| `/teams` | Spawn parallel agents for a task |

Several commands use `agents teams` for complex scopes (audit, debug, plan, clean, test, recap).

## Skills

Skills are richer than commands — multi-file capabilities with persistent context.

| Skill | Purpose |
|-------|---------|
| `agents-cli` | Manage agent CLIs, versions, config |
| `browser` | Drive browsers for automation |
| `teams` | Organize agents into parallel teams |
| `mcporter` | Configure and call MCP servers |

Invoke with `/skillname` or let Claude invoke when relevant.

## Rules

`rules/AGENTS.md` is the canonical instruction file. Synced as `CLAUDE.md`, `GEMINI.md`, `.cursorrules` per agent. Modular fragments in `rules/subrules/` for composition.

## Hooks

`hooks.yaml` registers scripts against agent lifecycle events (`SessionStart`, `UserPromptSubmit`, `Stop`). Key hooks:
- Expand `#shortcut` tokens via `promptcuts.yaml`
- Execute inline `! cmd` bang commands
- Inject context at session start

User overrides go in `~/.agents/agents.yaml` under the `hooks:` section.

## Local-only (gitignored)

Runtime state written to this directory but never committed:
- `versions/`, `shims/` — installed CLIs
- `sessions/`, `teams/`, `swarm/` — execution state
- `agents.yaml`, `*.log`, `*.pid` — local config and logs

## Customization

Fork this repo, make changes, set as upstream:

```bash
agents repo set gh:your-handle/.agents-system
agents pull
```

Or just add overrides to `~/.agents/` — same structure, user layer wins.

## License

MIT
