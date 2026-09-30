# Rolling back a bad release

Three things ship separately and roll back separately:
- the **Android apps**, through Play Console
- the **Cloud Functions**
- the **rules, indexes and hosting**

The last two are both deployed by `.github/workflows/deploy-firebase.yml` from a `vX.Y.Z` tag.

**First decide: roll back, or fix forward** ([hotfix.md](hotfix.md))?
- **Roll back** when users are being harmed now and the previous version was fine.
- **Fix forward** when the previous version can't work with the current data.

## Android app

1. **Play Console → the app → Release → Production → Halt rollout.** Users who haven't updated stay on
   the old version; those who have keep the new one.
2. You can't un-publish a version. To move people off it:
   - **Fix forward** with a hotfix build that has a higher version code ([hotfix.md](hotfix.md)).
   - **Force the update:** once the fixed build is live, set `minSupportedBuild` in A6 to the fixed
     build number. Never set it higher than the build that's actually live in Play.
3. If the bad build breaks the server contract, keep the server compatible with it until the fixed
   build reaches most users.

## Cloud Functions, rules, indexes, hosting (prod)

Redeploy the last good tag, `v1.2.2` in this example. Anyone with write access can start it, so check
with the incident lead first:

```bash
gh workflow run deploy-firebase.yml --repo CODER7657/roadside-app --ref v1.2.2 -f target=prod
```

```bash
gh run watch --repo CODER7657/roadside-app
```

That deploys that tag's functions, rules, indexes and both hosting sites.

- **Functions** only deploy once the project is on Blaze (`FIREBASE_BLAZE=true`).
- **Rules only?** The same command works; rules deploy in under a minute.
- **Indexes:** a deploy never deletes indexes, so an older index set is safe.
- **Data changed by the bad release:** Firestore point-in-time recovery (7 days, prod) can read the
  database as it was before the release. Restore only the affected documents, with a script reviewed
  by P2 and P3. The weekly export is the fallback.

## dev

Dev deploys on every merge to `main`. Revert the PR (the **Revert** button on GitHub, or
`gh pr revert`) and merge the revert.

## Afterwards

The report in the incident issue, and a test that would have caught it.
