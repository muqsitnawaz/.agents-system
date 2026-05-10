# Changelog

## [0.2.0] - 2026-05-10

Public release cleanup. Streamlined commands, improved workflows, better documentation.

### Added
- **`/done` command** — comprehensive completion checklist: verify code, test E2E, commit, create PR with session gist, release if applicable, handle remaining items via tickets.
- **`/teams` command** — inline workflow for spawning parallel agents (single agent via `agents run`, teams via `agents teams`).
- **`/plan` enhancements** — web search for current best practices, user flows for UI features, primitive reuse requirement, optional early design review with agent team.

### Changed
- **Commands consolidated** — removed redundant skill redirects (`/secrets`, `/sessions`, `/teams` stubs) in favor of invoking skills directly.
- **`/spawn` removed** — use `agents run <agent> "prompt" --mode edit` for single-agent dispatch.
- **`/design`, `/redesign` removed** — covered by the `design` skill with multiple modes.
- **`/product` moved to rules** — now `rules/subrules/product-mindset.md` (opt-in, not in default preset).
- **Teams skill updated** — documents `agents run` for single-agent work.
- **README rewritten** — accurate command/skill tables, cleaner structure.

### Fixed
- Hooks documentation clarified: system uses `hooks.yaml`, user hooks go in `agents.yaml` under `hooks:` section.

## [0.1.0] - 2026-04-01

First tagged release. Consolidates agent configuration, permissions, hooks, and skills.

### Added
- **Stop completion gate hook** (`hooks/stop-completion-gate.sh`) -- blocks agents from claiming "done" without end-to-end verification. Extracts original user request from transcript, forces goal-by-goal self-audit before allowing session to end.
- **Permission rules for `2>/dev/null` redirections** -- read-only commands (`ls`, `cat`, `head`, `tail`, `wc`, `file`, `stat`, `which`, `grep`, `rg`, `readlink`, `diff`, `command -v`, `type`) now have allow patterns covering stderr suppression to `/dev/null`.

### Changed
- **AGENTS.md restructured by priority** -- rules reordered into 3 tiers by impact. "Done means it works end-to-end" promoted to Hard Line #1. Core workflow changed from `ACT -> SHOW -> CONTINUE` to `ACT -> VERIFY -> SHOW -> CONTINUE`. 8 sections consolidated to 5, 204 lines reduced to 144.
- **Private skills moved out of version control** -- skills with proprietary content (image-craft, writer, browser, linear, etc.) gitignored and managed separately.

### Fixed
- Cross-cutting changes rule promoted from buried Design Principles section to Hard Line #8.
- Testing section now cross-references Hard Line #1 to prevent "unit tests pass = done" loophole.
