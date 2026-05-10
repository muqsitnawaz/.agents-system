# Parallel Work via `agents teams`

Default to teams for any change that touches more than two independent surfaces. Single-threaded sequential editing is the failure mode — fight it.

## When to spawn a team

- Multi-file change with separable boundaries (different components, different test files, different scripts).
- An audit, ship-readiness check, or parity check across a stack.
- Anything where you'd otherwise queue 4+ sequential edits.

Skip teams for: exploration (use `Agent` subagents), single-surface bugs, plan-mode research.

## Boundary contracts are mandatory

Before spawning, present a distribution plan and get user approval. Each teammate must have:

- **Owns** — explicit list of files (paths, line ranges where helpful) it may modify.
- **Must NOT touch** — explicit list of files owned by other teammates.
- **Shared dependencies** — name the canonical location; only one teammate owns it, everyone else imports.

**Independence test:** if teammate A would have to wait on teammate B's output to start, the split is wrong. Either re-cut the work, or sequence with `--after` and accept that pair isn't parallel.

## Spawn pattern

```bash
agents teams create my-feature
agents teams add my-feature claude "Owns: src/auth/*. Must not touch: src/ui/*. Implement OAuth refresh." --name auth
agents teams add my-feature codex  "Owns: src/ui/login.tsx. Must not touch: src/auth/*. Wire login UI to auth." --name ui --after auth
agents teams start my-feature --watch
```

Use `--mode plan` for read-only work (audits, research). Use `--mode edit` (default) for code changes.

## Briefing each teammate

Every prompt includes:

- **Mission** — why we're doing this.
- **Full scope** — what every teammate is doing (not just this one), so each has the big picture.
- **Your assignment** — files this teammate owns.
- **Boundary contract** — files NOT to touch.
- **Pattern to apply** — concrete code patterns inline, not vague instructions.
- **Success criteria** — how this teammate knows it's done.

End every brief with the literal line: `Return file:line quotes for every claim. Do NOT paraphrase.` This matches `core-hard-lines.md` and prevents teammates returning vibes.

## After completion

- Verify with `grep` that each teammate made the expected changes — `files_modified: []` doesn't mean failure, it means a different approach was used.
- Run the test suite for affected paths.
- Don't re-run the whole team for one teammate's failure — fix the one.

## See also

The `swarm` slash command (`~/.claude/commands/swarm.md`) is the long-form playbook with full templates. Use it when designing complex distributions.
