# Tooling & Stack Conventions

## Right tool for the job

| Task | Tool | When |
| --- | --- | --- |
| Query large docs (.md, .html, .pdf) | `mq` | File is 100+ lines. Probe structure first, extract surgically. |
| Issue tracker (auto-detect) | `/issues` command | Generic ticket operations across Linear/GitHub/Jira; auto-detects whichever CLI/skill is available. |
| Browser automation | `browser` skill | Driving websites, filling forms, taking screenshots. Part of `agents-cli` (`browser` is shorthand for `agents browser`). |
| Interactive terminal programs | `agents pty` | REPLs, TUIs, interactive CLIs needing a real PTY. |
| Parallel coding agents | `agents teams` | Multi-surface implementation work. |
| Credentials | `agents secrets` | All auth tokens, API keys. Never env vars or plaintext. |

## Interactive terminal (`agents pty`)

Regular Bash is non-interactive. For REPLs, TUIs, interactive prompts, or other agent CLIs, use `agents pty`:

```bash
SID=$(agents pty start)
agents pty exec $SID "python3"
sleep 1 && agents pty screen $SID    # clean text output
agents pty write $SID "exit()\n"
agents pty stop $SID
```

Run `agents pty --help` for full usage.

## Agent spawning

For parallel work, use `agents teams` (see `parallel-teams.md`). For single-agent dispatch, use `agents run`. When spawning, include:

- Specific file paths with line numbers.
- Code patterns inline (not vague instructions).
- Concrete examples of the expected output.

## LLM tool design

When building tools that LLMs will consume:

- Match how LLMs think (`read` should handle files AND directories — not two tools).
- Absorb complexity internally — minimize decision points the LLM has to make.
- No overlapping tools — exactly one way to do each thing.
- Names are documentation — a good tool name explains its purpose without docs.
