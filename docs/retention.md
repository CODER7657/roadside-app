# Data retention: how each row of PLAN §12.10 is enforced (#56)

The privacy policy (`firebase/hosting/share/privacy/`) promises these periods to users, so each one
must be enforced by something that runs without anyone remembering to do it.

| Data | Kept for | Enforced by | Owner | Status |
| --- | --- | --- | --- | --- |
| `liveLocations/{bookingId}` | 24 h after the job ends | Firestore **TTL** on `expireAt` (`firebase/firestore.indexes.json`). The mechanic app keeps `expireAt` under 48 h ahead during a job (rules); `completeJob` sets it to end + 24 h | P3 (TTL), P2 (`completeJob`, `cancelBooking`) | TTL in this PR. `cancelBooking` doesn't set `expireAt` yet, so a cancelled job's track lives up to 48 h (P2) |
| `shareLinks/{token}` | Until the job ends or 3 h | Firestore **TTL** on `expiresAt`. `sharePage` already answers "expired" once the document is gone | P3 | This PR |
| `presence/{uid}.location` | Overwritten; cleared when offline | Mechanic app on going offline; the server marks stale presence offline after 2 min | P2 | Check in #120 |
| Chat messages and photos | 90 days | Scheduled function, daily: delete `bookings/*/messages` and their Storage files older than 90 days | P2 | To do |
| Draft problem photos (`users/{uid}/bookings/{draftId}/`) | 24 h unless a booking uses them | The same scheduled function (review of #102) | P2 | To do |
| Bookings (without live location) | 3 years; anonymised after account deletion | `requestAccountDeletion` anonymises the caller's bookings; a yearly job deletes bookings older than 3 years | P2 | To do |
| Mechanic KYC documents | 180 days after the mechanic leaves | Scheduled function: delete KYC files of mechanics whose account was deleted or blocked more than 180 days ago | P2 | To do |
| Crash logs | Crashlytics default, no PII | `LaneLog` redaction + `crashReporterSink` (#48) | P3 | #154 |
| Backups | 7 days (point-in-time) and 14 weekly backups | `tool/gcp/setup_backups.sh` on prod (needs Blaze) | P3 | Script in this PR; run it when prod exists |

## Notes

- **TTL is not instant.** Firestore deletes expired documents typically within 24 hours of the
  expiry time. The periods above include that delay, and rules and functions must treat an expired
  document as gone even while it still exists (`sharePage` already does).
- **TTL doesn't delete subcollections or Storage files.** Anything with files or children needs the
  scheduled function.
- **Backups contain deleted data.** A document removed for retention or account deletion stays in
  backups until they expire (up to 14 weeks). The privacy policy's "within 30 days" for deletion covers
  the live database; if the client's lawyer wants backups covered too, shorten backup retention to 4 weeks.
- Everything in this table runs on dev too, except the backups, and, until the project is on Blaze,
  the scheduled functions.
