#!/usr/bin/env bash
set -euo pipefail

# General-purpose Stop hook: blocks Claude from stopping when it claims "done"
# without verifying all conversation goals end-to-end.
#
# Exit 0 = allow stop
# Exit 2 = block stop, stderr becomes feedback to Claude

INPUT_JSON=$(cat)

# Check stop_hook_active first — prevent infinite loops
stop_active=$(echo "$INPUT_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
print(str(data.get('stop_hook_active', False)).lower())
" 2>/dev/null || echo "false")

if [ "$stop_active" = "true" ]; then
  exit 0
fi

# Extract last message and transcript path
eval "$(echo "$INPUT_JSON" | python3 -c "
import json, sys, shlex
data = json.load(sys.stdin)
tp = data.get('transcript_path', '')
lm = data.get('last_assistant_message', '')
print(f'TRANSCRIPT_PATH={shlex.quote(tp)}')
print(f'LAST_MSG_LEN={len(lm)}')
" 2>/dev/null)"

# No transcript — edge case, allow
if [ -z "${TRANSCRIPT_PATH:-}" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  exit 0
fi

# Check if Claude is claiming completion
is_claiming_done=$(echo "$INPUT_JSON" | python3 -c "
import json, sys

data = json.load(sys.stdin)
msg = data.get('last_assistant_message', '').lower()

done_signals = [
    'implementation is complete',
    'feature is complete',
    'all done',
    'that completes',
    'i have finished',
    'everything is working',
    'changes are complete',
    'the feature is ready',
    'successfully implemented',
    'implementation is done',
    'all changes have been made',
    'feature is done',
    'work is complete',
    'that should do it',
    'ready for use',
    'ready for review',
    'here\'s what was built',
    'here\'s what changed',
    'here is what changed',
    'here is what was built',
    'all tests pass',
    'all passing',
    'that covers everything',
    'everything looks good',
    'should be working now',
    'fix is in place',
    'changes are live',
    'deployed successfully',
    'done.',
    'done!',
]
for signal in done_signals:
    if signal in msg:
        print('yes')
        sys.exit(0)
print('no')
" 2>/dev/null || echo "no")

# Not claiming done — allow stop (answering a question, asking user, etc.)
if [ "$is_claiming_done" != "yes" ]; then
  exit 0
fi

# Count assistant turns to skip short Q&A sessions
turn_count=$(python3 -c "
import json, sys

turns = 0
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
            if entry.get('role') == 'assistant':
                turns += 1
        except (json.JSONDecodeError, KeyError):
            continue
print(turns)
" "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [ "${turn_count:-0}" -le 2 ]; then
  exit 0
fi

# Extract first substantive user message from transcript
first_user_msg=$(python3 -c "
import json, sys

first_user = ''
with open(sys.argv[1]) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
            if entry.get('role') != 'user':
                continue
            content = entry.get('content', '')
            if isinstance(content, list):
                texts = []
                for c in content:
                    if isinstance(c, dict) and c.get('type') == 'text':
                        texts.append(c.get('text', ''))
                content = ' '.join(texts)
            content = content.strip()
            # Skip very short messages (slash commands, 'yes', 'ok', etc.)
            if len(content) > 20:
                first_user = content
                break
        except (json.JSONDecodeError, KeyError):
            continue

# Truncate if too long
if len(first_user) > 500:
    first_user = first_user[:500] + '...'
print(first_user)
" "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

# If we couldn't extract a user message, allow stop
if [ -z "$first_user_msg" ]; then
  exit 0
fi

# Block and inject self-audit prompt
cat >&2 <<GATE
STOP GATE: You claimed this work is done, but you must verify before stopping.

The user's original request was:
"$first_user_msg"

Before you can stop, you MUST:
1. Re-read the full conversation from the beginning
2. List EVERY goal, requirement, and question the user raised
3. For each goal, state one of:
   - DONE and TESTED end-to-end (cite the tangible output — test result, screenshot, live behavior)
   - DONE but UNTESTED (state what verification is missing, then go do it)
   - NOT DONE (continue working on it now)
4. If ANY goal is UNTESTED or NOT DONE, keep working. Do not stop.

Only stop when every goal has tangible, verified results.
GATE
exit 2
