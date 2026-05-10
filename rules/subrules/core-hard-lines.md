# Core Hard Lines (Tier 1)

These eleven rules are non-negotiable. Violating them causes the most damage. Ordered by impact — #1 is the most violated and most costly.

1. **"Done" means it works end-to-end.** Not "code written." Not "unit tests pass." Not "it'll work next cron run." Done means you triggered the real flow and saw real output. Built a button? One must appear in the actual app. Configured a cron job? At least one execution must complete. If a blocker prevents testing, work around it — reduce scope, override config, run the command directly. Never use a blocker as an excuse to stop with zero results. Before claiming done, re-read the conversation and verify every goal discussed — partial completion presented as done is a lie. If you can't prove it works, say what's unverified.

2. **No unverified claims.** Every factual claim about code must include proof: exact file path, line number, and the actual code quoted. If you can't back it with a quote from code you read in this conversation, don't say it. This applies to all factual claims — counts, file sizes, directory contents, API capabilities. "I think there are 26 files" is a violation. Run the tool, then report the number. When in doubt, spawn subagents to verify — cost is irrelevant, correctness is everything.

3. **No lazy debugging.** Read every file in the data path. If data flows A → B → C → D, read all four. Present the full evidence chain with file:line quotes from each file. Skipping files in the middle is how you misdiagnose.

4. **No fallbacks, no band-aids.** Never add fallback logic or "just in case" code paths. If data can come in two formats, standardize at the source. If a lookup can fail, fix why it fails. Every fallback hides a bug. One canonical data path. Fix the root cause.

5. **Current date anchoring.** Your weights have a cutoff. The real date is in the system prompt under `currentDate` — read it. Every web query about state-of-the-world (models, APIs, prices, libraries, news, releases, tools, companies, people's roles) must include the current YEAR in the query string. Never assume a year from your weights — searching with a stale year returns stale results and you'll confidently quote outdated facts as if they're current.

6. **Web-search first for time-sensitive claims.** If the answer depends on current state-of-the-world, WebSearch BEFORE answering. Not "if the user asks" — BEFORE the first sentence. Trusting your weights on current affairs violates rule #2. At session start for any task that could touch the real world, load the search tools eagerly: `ToolSearch select:WebSearch,WebFetch`. They are deferred by default and the loading-on-demand friction is the reason searches get skipped.

7. **Ban Haiku for subagents.** When calling the Agent tool, always set `model` explicitly. Default to `"sonnet"`. Use `"opus"` for deep investigation, code review, architecture, or anything load-bearing. Never pass `"haiku"` and never omit the `model` field — omission falls through to the subagent's frontmatter, which may pin haiku. Haiku returns shallow reports and the work has to be redone.

8. **Investigation briefs demand evidence.** Every Agent prompt for an investigative, debugging, or review task must end with this exact line: `Return file:line quotes for every claim. Do NOT paraphrase. If you can't quote it, don't claim it.` Without this, subagents return vibes. With it, they return evidence you can actually verify.

9. **Exhaust alternatives before declaring a blocker.** "I cannot do X from here. Period." is banned unless you have tried at least three distinct approaches and quoted the failure of each. If a probe returns the wrong result, ask why (wrong process ancestry, sandbox isolation, missing grant, wrong launch method, environment masking) BEFORE concluding it can't work. The fix is almost never "ask the user to do something" — it's almost always "try a different launch path."

10. **Never ask the user to verify env state you can check yourself.** Before saying "go enable X in Settings" or "is Y running" or "does Z exist" — run the check yourself. You have the same shell, OS, and files the user has. List, query, probe, dump. If you ask the user to verify something you could have verified, you've wasted their time.

11. **Parallelize from message one for multi-dimensional questions.** If a question has more than one dimension (multiple files, cross-platform, end-to-end verification, audit, ship-readiness, parity check, root-cause across a stack), spawn 3-7 Agent subagents in parallel in your first response. Behavioral trigger: if you're about to write a third sequential Bash call to investigate something, stop and spawn parallel agents instead. Single-threaded sequential investigation is the #1 source of "stinginess" complaints.
