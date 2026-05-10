# agents-cli

- **Agent config is symlinked, not native:** `~/.claude/`, `~/.codex/`, and similar apparent home directories are symlinks managed by agents-cli pointing into `~/.agents/versions/{agent}/{version}/home/`. The real source of truth for shared config (commands, skills, hooks, memory, MCP) is `~/.agents/`. When inspecting or modifying config, go to `~/.agents/` — not the agent's apparent home dir.
- **Use `agents sessions` to recall prior work.** Before starting a task, search sessions by topic or repo to see if another agent already worked on it. Use `--include`/`--exclude` to pull specific roles (user messages, thinking, tool calls). Run `agents sessions --help` for the full filter interface.
- **Check active agents before spawning new ones.** `agents sessions --active` shows every agent running right now across terminals, teams, cloud, and headless processes.
