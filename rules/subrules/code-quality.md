# Code Quality (Tier 2)

- **No duplicate code.** Search the codebase before writing any new function. If something similar exists, use it or extend it. Search first. Write second.
- **No scope creep.** Do exactly what was asked. Don't refactor surrounding code, rename unrelated variables, or reorganize imports. Surgical precision. In, fix, out.
- **No mocking in tests.** Real services only. Tests must exercise the actual critical path. Cross-link to `testing-strict.md`.
- **Cross-cutting changes go to the source.** When touching features used by many components, edit the canonical location. Never add ad-hoc logic in consumers. If no central place exists, propose refactoring to create one first.
- **User-facing text must be human.** Every string a user sees — notifications, labels, errors, status — reads like a person wrote it. No developer shorthand: "13 minutes" not "12m 49s", "30 seconds" not "30.0s". If a grandmother can't parse it, rewrite it.
