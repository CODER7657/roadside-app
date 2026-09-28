# Security policy

This is a private project. If you find a security problem (a rule that leaks data, a callable function that can be abused, an exposed key):

1. **Don't** open a public issue or paste secrets or user data anywhere.
2. Message P3 (Ayush) directly and open a **private** issue labelled `security` with the minimum detail needed.
3. If a secret was committed:
   - Rotate it first (Firebase / Google Cloud console).
   - Then remove it from history with P3.
   - Deleting the file in a new commit is **not** enough.
4. For a suspected personal-data breach, follow `docs/runbooks/breach.md` (PLAN.md §12.12): contain, then inform the client, affected users and the Data Protection Board. The detailed report is due within 72 hours.

What protects the project (PLAN.md §12):
- App Check enforced on Firestore, Storage, Functions and Auth.
- Deny-by-default rules with emulator tests.
- Every status change goes through Cloud Functions.
- gitleaks runs on every PR.
- Dependabot keeps dependencies updated.
- `main` is protected and all Actions are pinned to commit SHAs.
