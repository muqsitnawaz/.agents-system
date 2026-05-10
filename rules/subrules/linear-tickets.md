# Tickets & Cycles

For projects that use a ticket tracker (Linear, GitHub Issues, Jira), the agent owns ticket discipline. Don't wait to be reminded.

## Before starting work

1. **Check the active cycle.** If the project uses Linear, run `linear cycles` to identify the active cycle, then `linear tasks --all` and search for the topic. The `issues` skill auto-detects the right tracker.
2. **Don't create duplicates.** If a ticket already covers the work, pick it up — don't open a parallel one. Search before you create.
3. **If no ticket exists, create one before writing code.** Capture the goal in the ticket — not in your head.

## When a plan is approved

When you exit plan mode (or the user says "go ahead"), the **first action is updating the ticket with the approved plan**. Not writing code. Not running tests. Update the ticket body with the plan, then start.

Why: the ticket is where collaborators read context. If the plan only lives in the conversation, anyone else picking up the work is starting from zero.

## During work

- Mark the ticket In Progress when you start (`linear update <id> --pickup` or equivalent).
- Don't close until you have **proof** — a PR link, a screenshot, a deploy URL, a metric quote. Most ticket CLIs require it. The `linear update <id> --done --proof <evidence>` flag rejects without proof, by design.

## Anti-patterns

- Creating tickets in batches without searching the active cycle first.
- Implementing without first writing the plan into the ticket.
- Closing without evidence ("I think it's done").
- Working an issue that already has a different agent assigned without checking.
