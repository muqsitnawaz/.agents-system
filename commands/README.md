# Commands

> Layered with `~/.agents/commands/`. Same name in your user repo wins; everything else unions in.

Slash commands are prompt templates. Type `/debug the auth flow` and the command file expands into a full debugging methodology prompt, with your text replacing `$ARGUMENTS`.

## How Commands Work

Each `.md` file in this directory becomes a slash command. The file content is a prompt template:

```markdown
---
description: Debug an issue with systematic root cause analysis
---

You are debugging: $ARGUMENTS

## The Discipline

The root cause is NEVER where the error appears...
```

When you type `/debug the login is broken`, Claude receives the full prompt with "the login is broken" substituted for `$ARGUMENTS`.

## Commands vs Skills

Commands are **one-shot prompt expansions** - they fire once and are done.

Skills are **persistent capabilities** - they load into context and stay active, often with supporting scripts and reference files.

Use a command when you want a specific methodology applied once. Use a skill when you need ongoing capability with tools and context.

## Commands

These run in your current session, with optional team augmentation for complex scopes:

**Planning & Design**
- `/plan` - Feature planning with mandatory artifacts (mockups, diagrams, state machines). Forces grounded discussion. For large features, automatically validates with a team.
- `/design` - UX design with ASCII mockups and interaction flows
- `/redesign` - Improve existing screens with before/after proposals
- `/product` - Think like a product engineer - user value over technical elegance

**Debugging & Maintenance**
- `/debug` - Systematic root cause analysis. Maps the full data path, reads every file in the chain, builds evidence. For complex bugs, verifies with independent teammates.
- `/clean` - Remove tech debt, consolidate duplicate code, clean up patterns. For large codebases, parallelizes scanning across areas.
- `/recap` - Summarize current situation with facts, hypotheses (grounded in evidence), and next steps. Automatically spawns teams for actionable items.
- `/test` - Identify critical paths and validate them. For complex scopes, distributes testing across a team.

**Audit & Security**
- `/audit` - Multi-perspective audit by spawning a team of agents, each playing a different attacker or defender role

**Task Management**
- `/issues` - Auto-detect the project's tracker (Linear / GitHub / Jira / etc.) and work with it. Uses whichever tracker skill is available; falls back to repo signals (`gh issue list`, etc.) if none is loaded.
- `/continue` - Resume a previous task with context recovery
- `/commit` - Stage all changes, write a conventional commit message, and push in the background

**Utilities**
- `/secrets` - Manage named bundles of environment variables backed by macOS Keychain. Create bundles, add secrets, inject into runs.
- `/sessions` - Search, browse, and read agent conversation transcripts across Claude, Codex, Gemini, and OpenCode.
- `/teams` - Arrange agents into teams for parallel execution. Create, add members, start, monitor, and collect results.

**Delegation**
- `/spawn` - Spawn a single subagent with full context for one task

## Team Augmentation

Several commands automatically use `agents teams` when the scope is complex:

- `/debug` — Verifies root cause with independent teammates for multi-service bugs
- `/plan` — Validates approach with independent planners for large features
- `/clean` — Parallelizes scanning across frontend/backend/shared/docs for large codebases
- `/test` — Distributes testing across areas for complex scopes
- `/recap` — Spawns teams for 2+ clear, actionable items instead of listing them
- `/audit` — Always uses teams; each teammate plays a different threat perspective

Run `agents teams --help` for team management commands.

## Creating Commands

1. Create `commands/<name>.md`
2. Add frontmatter with a `description`
3. Use `$ARGUMENTS` where user input should appear
4. Commit and sync (`agents pull` on other machines)

Keep prompts focused. One methodology per command. If you need scripts or reference files, make it a skill instead.

## Patterns Worth Noting

**Forcing functions** - Commands like `/plan` require artifacts before discussion. You can't hand-wave; you must draw the mockup first.

**Evidence chains** - `/debug` builds explicit chains: "file_a.ts:45 receives X, transforms to Y, passes to B" - making reasoning visible and verifiable.

**Grounded hypotheses** - `/recap` distinguishes facts from hypotheses, and requires evidence for each hypothesis.

These patterns prevent the most common failure mode: talking about code without reading it.
