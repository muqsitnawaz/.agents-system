# Agentic Git Workflow

Rules for agent-driven git operations that go beyond basic read-only + commit/push.

## Session Export on PRs

Every PR must include a session transcript as a GitHub Gist — no exceptions.

### Workflow

1. **Export session** — Run `agents sessions --last 50 --markdown` to capture the conversation
2. **Create gist** — Use `gh gist create`:
   ```bash
   agents sessions --last 50 --markdown > /tmp/session-export.md
   gh gist create /tmp/session-export.md --desc "Session transcript for PR" --public
   ```
3. **Attach to PR** — Add the gist URL to the PR description

### PR Description Format

```
## Session Context
[Session transcript](https://gist.github.com/...)
```

This creates an audit trail linking code changes to the reasoning that produced them.
