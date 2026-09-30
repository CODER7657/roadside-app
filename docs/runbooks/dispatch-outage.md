# Dispatch outage

Bookings are created but no mechanic gets an offer, offers never expire, or the apps can't book at
all. A stranded driver is waiting: **talk to customers first, debug second.**

## Signs

- A3 shows bookings stuck in `requested` for more than 2 minutes.
- Many `no_mechanic_found` in a city that has online mechanics.
- Customers call the support phone; mechanics say they're online but get nothing.
- A Cloud Monitoring alert: function error rate > 2 %, or the dispatch sweep failing.

## First 15 minutes

1. Declare the incident. Note which cities are affected.
2. Check it isn't just supply: are approved mechanics online in that city (A1, A3)? If none are, it's
   not an outage. Ask the client to call mechanics in that city.
3. **Kill switch,** if bookings fail or go nowhere. In A6, either:
   - turn off `dispatchEnabled` for the whole service, or
   - switch off the affected city's service area.

   New bookings then get the friendly "service paused" message instead of waiting in vain. Set a
   `maintenanceMessage` with the support phone.
4. **Help the people already waiting.** For each booking stuck in `requested`, the support phone
   calls the customer (A3 shows the booking and the customer's number), then either:
   - phones approved mechanics near the pickup and gives the customer the mechanic's name and number,
     **or**
   - tells them honestly that no one is available.

   Either way, cancel the in-app booking in A3 with the reason "dispatch outage", so it doesn't sit in
   `requested`.

   There is **no manual assignment in the app yet.** A callable to assign a mechanic from A3 is a
   follow-up for P2. Until it exists, bookings arranged by phone happen outside the app.

## Diagnose (P2 leads)

- **Function errors:** Cloud Logging for `dispatchOnBookingCreated`, `dispatchSweep`, `offerTimeout`
  and `respondToOffer`. Look for errors, timeouts and `permission-denied`.
- **Push:** are offers written to `offers/` but mechanics get no notification? Then FCM or the
  mechanic app's notification permission is the problem. Mechanics can still see offers in the app.
- **A recent release?** Then [rollback.md](rollback.md).
- **App Check enforcement just changed?** Unenforce and check again.
- **Billing:** Firestore quota, or a disabled billing account, stops everything.

## Recover

1. Fix or roll back.
2. Test with a real booking in a quiet city, with a team member as the mechanic.
3. Turn `dispatchEnabled` and the cities back on, and clear the `maintenanceMessage`.
4. Watch A3 for 30 minutes.
