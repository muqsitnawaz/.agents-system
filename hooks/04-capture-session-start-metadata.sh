#!/usr/bin/env bash
# SessionStart hook: capture {session_id, cwd, pid, ts} for the running
# agent process. Consumers read ~/.agents/.cache/state/sessions/$PPID.json
# to recover the live session UUID — AGENT_SESSION_ID env var goes stale
# when a user exits and reruns the agent in the same terminal.
#
# Works for Claude, Codex, and Gemini: all three pass `session_id` on stdin.
set -euo pipefail

input="$(cat)"

sid="$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("session_id","") or "")
except Exception:
    pass' 2>/dev/null || true)"
[ -z "$sid" ] && exit 0

cwd="$(printf '%s' "$input" | python3 -c 'import json,sys
try:
    print(json.load(sys.stdin).get("cwd","") or "")
except Exception:
    pass' 2>/dev/null || true)"

state_dir="$HOME/.agents/.cache/state/sessions"
mkdir -p "$state_dir"

# $PPID = the agent process that spawned this hook. One file per running agent.
tmp="$(mktemp "$state_dir/.${PPID}.XXXXXX")"
python3 - "$sid" "$cwd" "$PPID" > "$tmp" <<'PY'
import json, sys, time
sid, cwd, pid = sys.argv[1], sys.argv[2], int(sys.argv[3])
json.dump({"session_id": sid, "cwd": cwd, "pid": pid, "ts": int(time.time())}, sys.stdout)
PY
mv -f "$tmp" "$state_dir/$PPID.json"

# SessionStart stdout is injected into the model context on Claude/Codex.
# Stay silent to avoid leaking state into the prompt.
exit 0
