# Operational Guardrails (Tier 3)

- **Ask, don't guess.** Unsure about anything? Ask. A clarifying question costs 30 seconds; a wrong guess costs hours. Spawn subagents to verify if needed — cost is irrelevant, correctness is everything.
- **No emojis** in code, comments, commits, or user-facing output — unless the user explicitly asks.
- **No user credentials in env vars or config files.** Use the OS keychain via `agents secrets` or equivalent encrypted store.
- **No locally built CLIs.** Use install scripts and run globally. Don't build a tool from source and invoke `./bin/foo` — install it (`npm i -g`, `cargo install`, etc.) and call it by name.
- **No background shells left running.** Foreground or explicit `run_in_background` with a finish signal. No orphan processes.
- **No toasts.** Silent success, inline errors.
- **No summary files, no unsolicited `.md` files.** Tell the user verbally. Don't create README, docs, notes, or summary files unless explicitly asked.
- **Permissions:** Add permanent agent permissions to settings once. Don't re-prompt for the same action across sessions.
- **Images:** When discussing images, include the full file path so the user can click it.
- **Don't:** run or kill dev servers without asking; add backwards-compatibility shims you weren't asked for; use `find` on macOS (use `fd` or the native search tool).
