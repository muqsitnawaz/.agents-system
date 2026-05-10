---
description: Verify work is truly done end-to-end, test, release if needed, then close or create tickets
---

You are checking whether the current work is actually done. Context: $ARGUMENTS

Do NOT skip steps. Do NOT claim done until every check passes.

## Step 1: Recall What Was Asked

Re-read the conversation from the beginning. Build a checklist of every goal, requirement, and commitment you made:

- What did the user originally ask for?
- What did you agree to do along the way?
- Were there follow-up requests or scope changes?

Write the checklist out explicitly. Every item needs a verdict: DONE, NOT DONE, or PARTIALLY DONE.

## Step 2: Verify the Code

For every file you changed:

```bash
git diff --name-only
git status
```

- Read the changed files. Is the implementation complete? No TODOs, no placeholder logic, no half-finished branches?
- Does the code do what was asked, or did you solve a slightly different problem?
- Any obvious bugs, missing error handling on critical paths, or broken imports?

If anything is incomplete, fix it now. Do not proceed to Step 3.

## Step 3: Test

This is the most important step. "It compiles" and "unit tests pass" are not done.

**Figure out what testing is appropriate:**
- Bug fix? Reproduce the original bug scenario and confirm it's fixed.
- New feature? Trigger the real flow end-to-end and see real output.
- Refactor? Run the full test suite. Confirm behavior is unchanged.
- Configuration/infra? Execute it. See the real effect.

**Check what testing was already done in this session:**
- Did you run any tests? What were the results?
- Did you trigger the actual feature/flow, or just verify the code looks right?
- Did you see real output from the thing you built?

**If E2E testing has NOT been done, do it now.** Find a way to exercise the real path:
- Run the command, hit the endpoint, trigger the flow, execute the script
- If a blocker prevents testing, work around it — override config, reduce scope, run manually
- Show the actual output

If tests are needed and don't exist, write them before proceeding.

## Step 4: Commit and PR

If there are uncommitted changes that represent completed work:

```bash
git status
git diff --staged
```

- Stage and commit with a clear message describing what was done
- Do NOT commit incomplete or broken work

**If on a feature branch and work is complete, open a PR:**

```bash
# Check if on a feature branch (not main/master)
git rev-parse --abbrev-ref HEAD
```

If on a feature branch:

1. Push the branch: `git push -u origin HEAD`
2. Create PR with summary of changes:
   ```bash
   gh pr create --title "..." --body "..."
   ```
3. Export session and attach as gist comment:
   ```bash
   agents sessions --last 50 --markdown > /tmp/session-export.md
   GIST_URL=$(gh gist create /tmp/session-export.md --desc "Session transcript for PR" --public | tail -1)
   gh pr comment --body "## Session Context
   [Session transcript]($GIST_URL)"
   ```

This creates an audit trail linking the PR to the reasoning that produced it.

## Step 5: Release (if applicable)

Check if this work involves a publishable package:

```bash
[ -f package.json ] && echo "npm package found"
[ -f Cargo.toml ] && echo "rust crate found"
[ -f pyproject.toml ] && echo "python package found"
[ -f scripts/release.sh ] && echo "release script found"
```

If a release is needed:

1. Run the build: `scripts/build.sh` or equivalent
2. Run the full test suite: `scripts/test.sh` or `bun test` / `npm test` / `cargo test`
3. If tests pass, use `AskUserQuestion` to confirm release:
   - "Release v{version} to {registry}?" with options: Yes / No / Skip release

4. If confirmed, run release: `scripts/release.sh --confirm` or equivalent
5. Verify the release landed (check the registry, not just the script output)

## Step 6: Update Task Management

Check if there's an active task for this work using the `/issues` skill or project tracker:

- If a task is In Progress for this work, mark it done with proof (PR link, release version, etc.)
- Check TODO.md at the repo root — mark off any related items

## Step 7: Handle Remaining Items

If anything from Step 1 is NOT DONE or PARTIALLY DONE:

1. Use `AskUserQuestion` to clarify requirements for each remaining item:
   - "How should we handle {item}?" with options based on context
   - "Is {item} still needed?" — Yes, create ticket / No, skip / Defer to later

2. For items that need tickets, create them via `/issues` skill with:
   - Clear title describing the remaining work
   - Context from this session (what was attempted, what blocked it)
   - Acceptance criteria

## Step 8: Recap and Verdict

**First, summarize the session in 2-3 sentences:**
- What was the original task/request?
- What was accomplished?
- Any notable decisions or tradeoffs made along the way?

**Then present the checklist:**

```
ORIGINAL TASK:
[One sentence describing what the user asked for]

ACCOMPLISHED:
- [completed items with file:line references]

TESTED:
- [what was tested and how — actual commands run, output seen]

PR:
- [PR URL with session gist attached, or "N/A" if on main]

RELEASED:
- [version published, or "N/A" if not a package]

TICKETS CREATED:
- [any new tickets for remaining work, or "None"]

REMAINING:
- [anything deferred — be honest, or "None"]
```

If everything is done and tested, use `AskUserQuestion`:
- "Pick up next task" — check the issue tracker for next priority
- "Done for now" — stop here

If critical items are NOT done, do not ask — just fix them.
