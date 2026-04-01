---
description: Verify current task is done end-to-end, then pick up the next task from Linear
---

Finish current work and move to next task. Context: $ARGUMENTS

## Step 1: Verify Current Task is Complete

Before moving on, confirm the current task is actually done:

**Code verification:**
- Read the files you changed -- is the implementation complete? No TODOs, no half-finished logic?
- Check `git diff` and `git status` -- anything uncommitted?

**Testing:**
- Run the relevant test suite (`bun test`, `go test`, or manual verification)
- Tests must cover the critical path that was changed -- not just "it compiles"
- If no tests exist for what you changed, write them before moving on

**Related cleanup:**
- Check if TODO.md has items related to this task -- mark them done
- Any Linear ticket in progress? Update its status:

```bash
LINEAR=$(find ~/.agents/versions -name linear -path '*/skills/linear/scripts/*' -type f 2>/dev/null | head -1)
$LINEAR update <ID> --done
```

Use `AskUserQuestion` to confirm: "Current task [X] verified complete. Tests pass. Move to next?"

## Step 2: Probe the Board

Pull the current task queue from Linear:

```bash
$LINEAR tasks
```

Before picking the next task, check for:
- Related tasks that should be grouped (same feature area, same component)
- Notes or comments on tickets that add context
- Dependencies between tasks (one must land before another)

## Step 3: Pick Up Next Task

Select the highest-priority task that is in Todo (not In Progress). Prefer:
1. Tasks related to what you just finished (context is warm)
2. Urgent/High priority over Medium/Low
3. Tasks with clear scope over ambiguous ones

Announce what you're picking up, mark it In Progress:

```bash
$LINEAR update <ID> --pickup
```

Then start working. Read the relevant code, understand the problem, plan, execute. Standard pattern: ACT -> SHOW -> CONTINUE.
