# Mechanic supply: recruiting, onboarding and approving (PLAN §8, §10.0; #64)

Launch needs **enough approved mechanics online during launch hours** in each city. Customers who get
"no mechanic found" on day one don't come back.

| City | Target approved | Of which independent | Launch hours covered by ≥ 3 online |
| --- | --- | --- | --- |
| Ahmedabad | ≥ 10 | any | 08:00–22:00 |
| Ankleshwar | ≥ 5 | ≥ 2 (highway) | 08:00–22:00 |
| Bharuch | ≥ 5 | ≥ 2 (highway) | 08:00–22:00 |

Track progress in the admin console (A1 counts by city and type, A2 queue), **not in a spreadsheet of
names and numbers**: that's personal data we'd have to protect and delete (DPDP).

## 1. Recruiting (the client leads, the team supports)

- Where: garages and tyre shops along the main roads, the NH-48 stretch between Ankleshwar and Bharuch,
  two-wheeler mechanics near colleges and markets, and referrals from mechanics who have joined.
- What to say, in their language: jobs from nearby customers, the price range is agreed before the
  customer books, the customer pays them directly by UPI, they go online only when they want.
- Before they leave: install the app from the closed test (#52) or production, and start registering on
  the spot. Most drop-offs happen when they're asked to "do it later".

## 2. What each mechanic needs ready

| | Workshop mechanic | Independent mechanic |
| --- | --- | --- |
| Phone | Android 7+ with mobile data, the number they'll use for the app | Same |
| Profile | Name, services, vehicle types | Same, plus profile photo, base area, years of experience |
| Shop | Shop name, address, shop photo | — |
| Tools | — | At least 2 photos of their toolkit |
| Travel | — | Bike or scooter and its registration plate |
| ID | ID proof photo | ID proof photo, **selfie holding the ID**, **address proof** |
| Payment | UPI ID and the name on it | Same |
| Optional | — | A reference contact |

Photos must be clear and in good light; blurred IDs are the main reason for sending a registration back.

## 3. Approving in A2 (admins)

For every mechanic in the A2 queue, filtered by city and type:

**Both types**
- [ ] ID photo is clear; the name matches the profile
- [ ] Services and vehicle types make sense for what they told the recruiter
- [ ] UPI ID looks right, and the name on it matches (the customer sees it when paying)
- [ ] City is right (dispatch only matches within `cityId`)

**Workshop:** the shop photo shows a real shop, matching the address.

**Independent:**
- [ ] The selfie matches the ID photo
- [ ] Address proof is readable and plausible
- [ ] Toolkit photos show real tools
- [ ] **Verification call** made and logged in A2 (Approve stays disabled until it is): confirm their name, experience, base area and travel vehicle, and explain start codes and payment

Then **Approve**, or **Block** with a reason if something is wrong. Every action is written to `auditLogs`.
KYC documents open through short-lived links: never download or screenshot them.

## 4. Before launch

- [ ] Prices for every vehicle and problem in all three cities (A4), from the client's price chart,
      including any highway call-out overrides for Ankleshwar and Bharuch
- [ ] Service area radius per city (A6), set from the field test (#59). Defaults: Ahmedabad 25 km,
      Ankleshwar 12 km, Bharuch 12 km (`design/tokens.json`)
- [ ] A quick test booking per city with an approved mechanic
- [ ] A WhatsApp group (or call list, kept by the client) to reach online mechanics during launch week

## Status (fill in, in the #64 PR)

| Date | Ahmedabad approved (W / I) | Ankleshwar (W / I) | Bharuch (W / I) | Pending in A2 | Notes |
| --- | --- | --- | --- | --- | --- |
| | | | | | |
