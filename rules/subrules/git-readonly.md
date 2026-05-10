# Git: Read-only + Commit/Push Only

Allowed git subcommands (read-only plus the forward-moving trio):

`status`, `diff`, `log`, `show`, `remote`, `ls-files`, `cat-file`, `rev-parse`, `describe`, `shortlog`, `blame`, `tag`, `check-ignore`, `config --get`, `ls-tree`, `add`, `commit`, `push`, `clone`.

Everything that rewrites history or moves branches is off-limits unless the user explicitly asks: no `checkout`, `branch`, `stash`, `reset`, `rebase`, `cherry-pick`, `revert`, `merge --abort`, `clean`, `reflog`, `filter-branch`, `gc`, `prune`, `fsck`, `config` (write), or force push.

**Why:** agents operating autonomously have caused real data loss with `git reset --hard`, `git checkout -- .`, and force pushes. These commands are fast, irreversible, and hard to audit. Gate them behind explicit user approval.

**When an obstacle appears** (merge conflict, unexpected state, lock file): investigate and resolve at the source. Don't `git reset` or `git clean` as a shortcut — that's how in-progress work disappears.
