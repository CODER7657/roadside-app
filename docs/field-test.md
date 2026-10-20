# Field test: Ahmedabad, Ankleshwar, Bharuch (PLAN §16 days 17–18, #59)

Two days of real bookings with real mechanics on real roads, on the **closed-test build against the prod
project** (or dev if prod isn't ready: say which in the report). The goal is to find what breaks outside
the office: GPS on highways, sunlight, night, weak network, low battery, mechanics' own phones.

## Before the test

- [ ] 5–10 mechanics per city, recruited with the client (#64), registered, approved in A2, and online
      during the test hours. Mix workshops and independents; at least 2 independents in Ankleshwar and
      Bharuch (highway coverage).
- [ ] Mechanics know it's a test: agreed pay for their time, and no real repair unless the "customer" wants it.
- [ ] Customers: team members and the client's staff, 2–3 phones per city, including **one low-end phone**
      (2–3 GB RAM) and at least two Android versions.
- [ ] Prices for all three cities in A4; service areas active in A6 for the city under test only.
- [ ] Alerts on (#62); someone watches A3 during every session.
- [ ] Each tester has the scenario sheet below and a way to note times.

**Safety first:** do highway scenarios from a safe stop (fuel station, service road, dhaba parking),
never from a live lane. Night sessions in pairs.

## Scenarios

Run each at least once per city. Record the booking id, the time and the result.

| # | Scenario | Look for |
| --- | --- | --- |
| 1 | Standard booking in the city centre: book → accept → track → start code → complete → UPI pay → rate | End to end without help; arrival time vs ETA |
| 2 | **NH-48 highway pickup** (Ankleshwar–Bharuch stretch, and Ahmedabad–Vadodara Expressway approach) | Pin accuracy with no address (Plus Code), cross-city matching at 10 km (PLAN §11), mechanic finds the spot |
| 3 | **Night** after sunset | Night mode switches on by itself; map and rail readable; mechanic's notification wakes the phone |
| 4 | **Midday sun**, outdoors | Glare mode (☀ in the dock) readable at arm's length; buttons easy to hit |
| 5 | **Low battery** (≤ 15%) on both phones | Saver mode; mechanic tracking keeps going; battery drop over a 30-minute job |
| 6 | **Weak network**: 2G or a basement, then back online | Offline banners; nothing lost; booking state catches up |
| 7 | **No mechanic available** (ask mechanics to go offline) | Radius widens 3 → 5 → 10 km, then "no mechanic found" with Try again / Call / SMS |
| 8 | Mechanic **declines** / lets the offer time out | Next mechanic gets it within about 30 s |
| 9 | Customer **cancels** before and after arrival; mechanic cancels before arrival | Re-dispatch; both sides informed; reasons recorded |
| 10 | **Share trip** link opened on another phone; **SOS** | Link shows first name, rough position, ETA; expires after the job |
| 11 | **Payment dispute**: customer taps paid, mechanic says not received | Complaint appears in A5 |
| 12 | Languages: one full booking in **हिन्दी** and one in **ગુજરાતી** | No clipped or wrong text; the terms read naturally |
| 13 | Mechanic phone **locked** when an offer arrives | Full-screen offer, or the heads-up fallback, with sound |
| 14 | Pickup **outside** the service area | "Not in your area yet" screen |

## During the test

- Log every problem as a GitHub issue labelled `field-test`, with the city, scenario number, phone model,
  Android version, time and booking id. **No names, phone numbers or addresses** in issues.
- P0 (booking, payment or safety broken, or data shown to the wrong person): tell the group immediately.

## Report (fill in after the test, in the #59 PR)

### Summary
- Dates, build version, project (prod or dev), cities, number of bookings, mechanics and phones

### Results per city

| City | Bookings | Completed | No mechanic found | Median arrival (min) | Worst problem |
| --- | --- | --- | --- | --- | --- |
| Ahmedabad | | | | | |
| Ankleshwar | | | | | |
| Bharuch | | | | | |

### Scenarios

| # | Ahmedabad | Ankleshwar | Bharuch | Issues |
| --- | --- | --- | --- | --- |
| 1–14 | ✅ / ⚠️ / ❌ | | | #… |

### Changes decided
- Service area radius per city (feeds #64), price changes, dispatch timing, copy changes
- Launch blockers (P0/P1 issues that must be fixed before the production release, #61)
