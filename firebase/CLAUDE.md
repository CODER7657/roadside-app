# firebase/ — P3 (Ayush) owns config, rules, indexes and rule tests; P2 (Hem) owns `functions/`

- Project IDs: dev = `roadside-33282` (Firebase added a suffix), prod = `roadside-prod` (not created yet); aliases in `.firebaserc`; region **asia-south1** everywhere. Emulator project for tests: `demo-roadside`.
- Dev (`roadside-33282`) is on the free **Spark** plan: Firestore (asia-south1, Standard) and Hosting (`roadside-33282` share site, `roadside-33282-admin`) exist; **Functions and Storage need Blaze** and don't deploy until the repo variable `FIREBASE_BLAZE=true`. Develop and test those on the emulators.
- `firestore.rules` / `storage.rules`: deny by default, helpers from PLAN §12.4, `hasOnly` + `affectedKeys` on every client write, 🔒 fields never client-writable.
- Every rules change ships with tests in `rules_tests/` (Jest + `@firebase/rules-unit-testing`): ≥1 allow and ≥1 deny per collection × role. Run: `firebase emulators:exec --project demo-roadside --only firestore,storage "npm --prefix rules_tests test"`.
- Seed data: `serviceAreas/{ahmedabad|ankleshwar|bharuch}` (centres/radii in `design/tokens.json`), `appConfig/public`, `prices/*`.
- Deploys happen only through `.github/workflows/deploy-firebase.yml` (dev on merge, prod on tag with approval). Don't `firebase deploy` to prod from a laptop.
