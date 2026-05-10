---
description: Spawn parallel agents to work on a task together
---

You are organizing a team for: $ARGUMENTS

## Single Agent vs Team

First decide: do you need one agent or multiple?

- **One agent**: `agents run <agent> "prompt" --mode edit --timeout 30m`
- **Multiple agents**: continue below

## Create Team

```bash
agents teams create <team-name>
```

## Add Teammates

For each independent piece of work:

```bash
agents teams add <team-name> <agent> "prompt" --name <role> --mode edit
```

**Agent selection:**
| Agent | Best for |
|-------|----------|
| claude | Deep analysis, architecture, complex code |
| codex | Fast implementation, straightforward tasks |
| cursor | Debugging, tracing, bug fixes |
| gemini | Multi-system features, large context |

**Prompt must include:**
- Background: what and why
- File paths with line numbers
- Code patterns inline (don't just reference)
- Success criteria
- End with: `Return file:line quotes for every claim.`

## Dependencies (if needed)

```bash
agents teams add <team> claude "Build API" --name backend
agents teams add <team> codex "Build UI" --name frontend --after backend
```

## Start

```bash
agents teams start <team-name> --watch
```

## Monitor

```bash
agents teams status <team-name>
agents teams logs <team-name> <role>
```

## Cleanup

```bash
agents teams disband <team-name>
```
