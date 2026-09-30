# Hotfix

A fix that must reach production **without** the unreleased work that has piled up on `main`. If
`main` is releasable anyway, merge the fix and tag `main` as usual.

Same rules as always: one issue, one branch, one PR, full CI. No commits straight to a tag or `main`.

The example fixes `v1.2.2` as `v1.2.3`.

## Steps

1. Open an issue for the fix (label `incident` if it is one). For a **security** fix, the repo is
   public: word the issue, PR and commits neutrally ("tighten bookings read rule"), or make the fix in
   the draft security advisory's private fork, and describe the hole only after it's deployed.
2. Create the hotfix branch from the **released tag**, not from `main`, and push it:

   ```bash
   git fetch --tags origin
   ```
   ```bash
   git switch -c hotfix/v1.2.3 v1.2.2
   ```
   ```bash
   git push -u origin hotfix/v1.2.3
   ```

3. Make the fix on a normal working branch off it (`<owner>/<issue>-short-name`), with a test that
   fails without the fix.
   - Bump the version of each app that changes: `version: 1.2.3+<build>` in its `pubspec.yaml`.
   - `<build>` must be **higher than any build ever uploaded to Play**. Play rejects a reused version
     code.
4. Open the PR **into `hotfix/v1.2.3`** with `Closes #<issue>`. CI runs the same checks, and it gets
   the usual review.
5. After it merges, a repo admin tags the head of the hotfix branch:

   ```bash
   git tag -a v1.2.3 -m "hotfix: one line" origin/hotfix/v1.2.3
   ```
   ```bash
   git push origin v1.2.3
   ```

   The tag runs two workflows:
   - `deploy-firebase.yml`: functions, rules and hosting to prod
   - `release-android.yml`: signed AABs in a draft GitHub release
6. Upload the AAB in Play Console with a staged rollout. For an urgent fix: 20 %, then 100 % after a
   few hours if vitals are fine.
7. **Bring the fix back to `main`:** a PR from `hotfix/v1.2.3` into `main`, or cherry-pick the fix
   commit onto a normal branch. Otherwise the next release loses the fix.
8. Delete `hotfix/v1.2.3` once the fix is on `main`.

## Notes

- Hotfix branches need the same protection as `main`. Ask the repo owner to add `hotfix/*` to the
  branch ruleset (#40).
- A functions-only or rules-only hotfix skips the version bump in step 3 and all of step 6.
