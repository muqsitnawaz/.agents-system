#!/usr/bin/env bash
# SessionStart hook: inject runtime context (Linear queue + browser profiles)
# into Claude's session. Each section is independent — emits nothing when its
# data source is unavailable, so no empty headers/lines reach the model.
set -euo pipefail

# Discard stdin (Claude passes JSON: session_id, cwd, etc. — not needed here).
cat >/dev/null 2>&1 || true

sections=()

# ---- Linear queue (top 10 by due date, then priority) ---------------------
# linear-cli has no --limit flag, so we sort + slice client-side from --json.
if command -v linear >/dev/null 2>&1; then
  linear_json="$(linear tasks --agent claude --cycle active --json 2>/dev/null || true)"
  if [ -n "$linear_json" ]; then
    linear_section="$(printf '%s' "$linear_json" | python3 -c '
import json, sys
try:
    d = json.load(sys.stdin)
    issues = d.get("issues") or []
    if not issues:
        sys.exit(0)
    cycle = (d.get("cycle") or {}).get("name", "active cycle")

    # Linear priority: 1=Urgent, 2=High, 3=Medium, 4=Low, 0=None.
    # Sort: dated items first (asc due date), then by priority (urgent first);
    # undated items last, sorted by priority. Priority 0 (None) sorts last.
    def pri_key(p):
        return 99 if not p else p
    def sort_key(i):
        due = i.get("dueDate")
        return (0 if due else 1, due or "9999-12-31", pri_key(i.get("priority")))

    issues.sort(key=sort_key)
    top = issues[:10]
    total = len(issues)

    pri_name = {0: "None", 1: "Urgent", 2: "High", 3: "Medium", 4: "Low"}
    print(f"# Your Linear queue — {cycle} (top {len(top)} of {total} by due date + priority)")
    print()
    for i in top:
        ident = i["identifier"]
        title = i["title"]
        state = (i.get("state") or {}).get("name", "?")
        pri = pri_name.get(i.get("priority", 0), "None")
        due = i.get("dueDate") or "no due date"
        print(f"- **{ident}** [{state}] (P:{pri}, due:{due}): {title}")
    if total > len(top):
        print()
        print(f"_{total - len(top)} more not shown. Run `linear tasks --agent claude --cycle active` for the full list._")
except Exception:
    pass
' 2>/dev/null || true)"
    [ -n "$linear_section" ] && sections+=("$linear_section")
  fi
fi

# ---- Browser profiles -----------------------------------------------------
if command -v agents >/dev/null 2>&1; then
  profiles="$(agents browser profiles list 2>/dev/null || true)"
  # `profiles list` emits a 2-line header even when zero profiles exist;
  # only emit the section if there's at least one data row.
  if printf '%s\n' "$profiles" | awk 'NR>2 && NF{found=1} END{exit !found}' 2>/dev/null; then
    status="$(agents browser status 2>/dev/null || true)"
    [ -z "$(printf '%s' "$status" | tr -d '[:space:]')" ] && status="(no running tasks)"
    browser_section="$(cat <<EOF
# Browser profiles (live)

Use \`agents browser start --profile <name>\` — there is no \`default\` profile. Full reference: \`~/.agents/skills/browser/SKILL.md\`.

\`\`\`
$profiles
\`\`\`

Current tasks:
\`\`\`
$status
\`\`\`
EOF
)"
    sections+=("$browser_section")
  fi
fi

# Emit only when at least one section has content. Blank line between sections.
[ ${#sections[@]} -eq 0 ] && exit 0
printf '%s\n\n' "${sections[@]}"
