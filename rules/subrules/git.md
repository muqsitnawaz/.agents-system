# Git Rules

## Allowed Commands

Read-only plus the forward-moving trio: `status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`, `rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`, `config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`.

Everything that rewrites history or moves branches is off-limits unless the user explicitly asks: no `checkout`, `branch`, `stash`, `reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`, `filter-branch`, `gc`, `prune`, `fsck`, `config` (write), or force push.

**Why:** agents have caused real data loss with `git reset --hard`, `git checkout -- .`, and force pushes. These are fast, irreversible, and hard to audit. Gate them behind explicit user approval.

**When an obstacle appears** (merge conflict, unexpected state, lock file): investigate and resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how in-progress work disappears.

## PRs Require a Session Transcript

Every PR must attach a session transcript as a GitHub Gist — no exceptions.

```bash
agents sessions --last 50 --markdown > /tmp/session-export.md
gh gist create /tmp/session-export.md --desc "Session transcript for PR" --public
```

Add the gist URL to the PR description under `## Session Context`.
