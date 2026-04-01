---
name: proof-loop
description: Check the proof loop funnel — artifact created, shared, clicked, signup, paid
---

# Proof Loop Check

The proof loop must complete ONE full cycle before anything else matters:

```
Artifact created -> Shared publicly -> Someone clicks -> Someone signs up -> Someone pays
```

If any stage is zero, that stage is the day's #1 priority.

## How to Check Each Stage

**Artifacts created (last 24h):**
```bash
curl -s -X POST "https://us.posthog.com/api/projects/$POSTHOG_PROJECT_ID/query" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":{"kind":"HogQLQuery","query":"SELECT count() as artifacts FROM events WHERE event = '"'"'artifact_created'"'"' AND timestamp > now() - interval 1 day"}}'
```

**Shares, share views, signups** — same pattern, swap event name:
- `share_created`
- `$pageview` with pathname LIKE `/share/%`
- `user_signed_up`

**Traffic (7-day trend):**
```bash
curl -s -X POST "https://us.posthog.com/api/projects/$POSTHOG_PROJECT_ID/query" \
  -H "Authorization: Bearer $POSTHOG_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query":{"kind":"HogQLQuery","query":"SELECT toDate(timestamp) as day, count() as views, uniq(distinct_id) as visitors FROM events WHERE event = '"'"'$pageview'"'"' AND timestamp > now() - interval 7 day GROUP BY day ORDER BY day"}}'
```

If events don't exist in PostHog, tell Muqsit — instrumentation is blocking.

## Output Format

```
Loop: Artifact [Y/N] | Share [Y/N] | Click [Y/N] | Signup [Y/N] | Pay [Y/N]
Blocker: [first N stage] — [what to do about it]
```

Two lines. The blocker line only appears if a stage is N.
