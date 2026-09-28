# How we work

Personal step-by-step guides are in [docs/onboarding/](docs/onboarding/):
- [P1 (repo owner)](docs/onboarding/P1-customer-and-lane.md)
- [P2 (Hem)](docs/onboarding/P2-mechanic-and-functions.md)
- [P3 (Ayush)](docs/onboarding/P3-admin-firebase-security.md)

**Golden rule: one issue = one branch = one PR.** Every PR closes exactly one issue, and every issue is closed by exactly one PR. The **Linked issue** check enforces this. If an issue is too big for one PR, ask P3 to split it into smaller issues first; don't open a second PR for it.

The short version:

1. **Pick an issue** assigned to you (labels `P1` / `P2` / `P3`, milestones `Day 2 … Day 20`). Move it to *Doing* on the board.
2. **Branch** from an up-to-date `main`:
   ```bash
   git switch main
   git pull
   git switch -c p2/31-incoming-offer      # <owner>/<issue-number>-<short-name>
   ```
3. **Build it with Claude Code** from the repo root (`claude`). It reads `CLAUDE.md` plus the `CLAUDE.md` in your folder.
4. **Check locally** before pushing:
   - `dart format .`
   - `flutter analyze`
   - `flutter test`
   - `bash tool/lint_design.sh <app>/lib`
   - for Functions: `npm run lint && npm test`
5. **Commit** with Conventional Commits: `feat:`, `fix:`, `ui:`, `lane:`, `sec:`, `docs:`, `chore:`, `test:`, `ci:`.
6. **Open a PR**:
   ```bash
   gh pr create --fill
   ```
   - Fill in the template.
   - Add screenshots for UI.
   - Put exactly one `Closes #<issue>` in the description.
7. **Checks must be green.** Required: **CI result**, **PR title** (it becomes the squash commit) and **Linked issue** (exactly one issue, no other PR for it).
8. **Review:**
   - 1 approval.
   - 2 for `PLAN.md`, `packages/*` and `firebase/*.rules` (CODEOWNERS).
   - Reply to every comment.
9. **Squash-merge**, delete the branch, and move the issue to *Done*.

Merge small PRs every day. `main` must stay green because it is what we demo on day 10 and ship on day 20.
