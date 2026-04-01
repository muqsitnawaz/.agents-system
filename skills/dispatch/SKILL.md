---
name: dispatch
description: Dispatch work to growth agents (Sergey, Paul, Emma, Marc) or spin up codex for engineering
---

# Dispatch

Assign work to the right agent. Use when a gap is identified and Muqsit can't cover it.

## Agent Roster

| Agent | Cron | Does | Dispatch when |
|-------|------|------|---------------|
| Sergey | :10, :30, :50 | Prospect enrichment, directory submissions | Need more prospects, platform gaps |
| Paul | :20, :40, :00 | Blog posts for agent microsites (SEO) | No content going out, SEO gaps |
| Emma | :30 | Twitter @GetRushOS, LinkedIn, Reddit drafts | Social quiet, launch moments |
| Marc | :40 | Personalized email drafts in Gmail | Need outreach drafts |

## Trigger Extra Run

```bash
PATH=/opt/homebrew/bin:/Users/muqsit/.agents/shims:$PATH openclaw cron run <jobName>
```

Job names: `sergey-hourly`, `paul-hourly`, `emma-hourly`, `marc-hourly`

## Spin Up Codex (Engineering)

For well-scoped engineering tasks Muqsit can't get to:

```bash
cd ~/src/github.com/muqsitnawaz/agents && PATH=/opt/homebrew/bin:/Users/muqsit/.agents/shims:$PATH codex --approval-mode full-auto -q "[task with exact file paths and context]"
```

Rules:
- Only well-scoped tasks (fix a bug, verify a flow, add a specific feature)
- Include file paths and line numbers in the prompt
- Log what you dispatched in daily memory
- Check git log after to verify the work

## Linear Board

Check all open issues:
```bash
source ~/.openclaw/workspace/.env 2>/dev/null || source ~/.openclaw/.env 2>/dev/null
curl -s -X POST https://api.linear.app/graphql \
  -H "Authorization: $LINEAR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ issues(first: 50, filter: { team: { id: { eq: \"0a82ae7e-b144-4e4f-a333-bcbaf9a2ccc2\" } }, state: { type: { neq: \"completed\" } } }) { nodes { id identifier title state { name } labels { nodes { name } } priority assignee { name } } } }"}'
```

Agent labels: `agent:sergey`, `agent:paul`, `agent:marc`, `agent:emma`, `agent:codex`

State IDs:
- Backlog: `2a5e6fea-63cc-4725-a0e6-e52c24a457c0`
- Todo: `d1c63a65-51e1-4a23-a498-ad384fe6a981`
- In Progress: `034a35aa-8f8e-455a-94da-0eeb4b09dee5`
- Done: `6e73a9ed-9a0e-4d98-b66b-449298dc66f3`
