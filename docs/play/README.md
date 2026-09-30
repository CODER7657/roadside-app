# Google Play: listings, forms and declarations (PLAN §13, #58)

Everything Play Console asks for, for both apps. P3 owns this; P1 makes the graphics. Each answer
below matches what the apps actually do. If an app changes (a new permission, SDK or data type),
update this file in the same PR.

| | Customer app | Mechanic app |
| --- | --- | --- |
| Package | `com.roadside.customer` | `com.roadside.mechanic` |
| Category | Auto & Vehicles | Auto & Vehicles |
| Target API | 36 (Android 16) | 36 (Android 16) |
| Languages | en-IN (default), hi-IN, gu | en-IN (default), hi-IN, gu |

## Listing text

`listing/<app>/<locale>/` holds `title.txt`, `short_description.txt` and `full_description.txt`, one
file per Play field, in the layout Play upload tools expect.

- `bash tool/check_store_listing.sh` checks Play's limits (30 / 80 / 4000 characters). It counts
  `[[APP_NAME]]` as 12 characters, so keep the chosen name within that, or rerun with `APP_NAME_MAX`.
- Replace `[[APP_NAME]]` everywhere once the client picks the name (the legal pages use the same
  placeholder, `docs/legal/README.md`).
- The hi and gu text is a **draft**: the native-speaker review for the apps (`docs/glossary.md`) covers
  these files too.
- Play policy: no "best", "#1", prices or promotions in the title, and no emoji in the title.

## Graphics (P1)

| Asset | Size | Notes |
| --- | --- | --- |
| App icon | 512 × 512 PNG, 32-bit | From the adaptive launcher icon: the symbol on Beacon |
| Feature graphic | 1024 × 500 PNG or JPEG | Beacon background, wordmark in Instrument Serif. No text other than the name and the tagline; it's cropped on some devices |
| Phone screenshots | 4–8, 9:16, 1080 × 1920 | From the golden-test frames, Day and Night. One set per language (en, hi, gu) |

Customer screenshots, in order: home (C1), problem picker, estimate, searching, assigned (TrustPass),
tracking (JourneyRail), payment, share trip. Mechanic screenshots: dashboard online, incoming offer
(M4), navigate (M5), start code, job complete, earnings.

## App content forms

- **Privacy policy:** `https://<share domain>/privacy/` (hosted by `firebase/hosting/share`).
- **Account deletion:** in-app, plus the web URL `https://<share domain>/delete-account/`.
- **Ads:** no ads.
- **Target audience:** 18 and over only. The apps are not designed for children.
- **Content rating (IARC):** Utility/productivity category. No violence, sexual content, gambling or
  drugs. **Users can interact:** yes (in-app chat between customer and mechanic during a booking).
  **Shares user location with other users:** yes (the mechanic's live location with the customer during
  a job; the pickup point with the assigned mechanic).
- **Financial features:** "My app doesn't provide any financial features". The customer app opens the
  user's own UPI app to pay the mechanic; we don't process or hold payments.
- **Government apps, news, health, COVID-19:** not applicable.
- **Data safety:** below.

## Data safety

Answer **per app**. General answers for both:
- Data is **encrypted in transit**: yes.
- Users can **request deletion**: yes (in-app and the web page).
- **Sharing:** declare **No**. Play doesn't count as sharing: transfers to the other side of a booking
  that the user starts (booking a mechanic, accepting a job), or processing by our service providers
  (Google Firebase) on our behalf.
- No data is sold, and none is used for advertising or marketing.

### Customer app

| Play data type | Collected | Optional | Purposes |
| --- | --- | --- | --- |
| Personal info → Name | Yes | No | App functionality, Account management |
| Personal info → Phone number | Yes | No | App functionality, Account management, Fraud prevention |
| Personal info → Address (pickup address, landmark) | Yes | No | App functionality |
| Location → Precise location | Yes | No | App functionality |
| Photos and videos → Photos (problem photos) | Yes | Yes | App functionality |
| Messages → Other in-app messages (chat) | Yes | Yes | App functionality |
| Contacts (emergency contacts the user adds) | Yes | Yes | App functionality (safety) |
| App activity → Other user-generated content (ratings, reviews, complaints) | Yes | Yes | App functionality |
| App info and performance → Crash logs, Diagnostics | Yes | No | Analytics |
| Device or other IDs (FCM token, App Check) | Yes | No | App functionality, Fraud prevention, security and compliance |

### Mechanic app

| Play data type | Collected | Optional | Purposes |
| --- | --- | --- | --- |
| Personal info → Name | Yes | No | App functionality, Account management |
| Personal info → Phone number | Yes | No | App functionality, Account management, Fraud prevention |
| Personal info → Address (workshop, or independent mechanic's base area) | Yes | No | App functionality |
| Personal info → Other info (ID proof, address proof, selfie with ID) | Yes | No | Fraud prevention, security and compliance |
| Financial info → Other financial info (UPI ID and name) | Yes | No | App functionality |
| Location → Precise location (while online and during a job) | Yes | No | App functionality |
| Photos and videos → Photos (profile, tools, shop, before/after) | Yes | No | App functionality |
| Messages → Other in-app messages (chat) | Yes | Yes | App functionality |
| App activity → Other user-generated content (reviews, complaints) | Yes | Yes | App functionality |
| App info and performance → Crash logs, Diagnostics | Yes | No | Analytics |
| Device or other IDs (FCM token, App Check) | Yes | No | App functionality, Fraud prevention, security and compliance |

These tables replace the combined table in `docs/legal/README.md`, which also didn't list Address or
user-generated content.

## Permission declarations (mechanic app)

### Foreground service: location

- **Type:** `location`. **Task:** "Navigation to a customer and sharing the mechanic's live location with
  the customer during an accepted job."
- **Why it can't wait:** the customer is stranded at the roadside and watches the mechanic approach;
  location must keep updating while the mechanic uses a navigation app.
- **User-visible:** a persistent notification (the Live Update on Android 16) for the whole job, which
  ends when the job is completed or cancelled. No background-location permission is requested.
- **Video (30–60 s, unlisted YouTube link):** go online → receive and accept an offer → tap Navigate →
  switch to Maps with the notification visible → return → Arrived → the notification disappears after
  the job ends. Record on the dev build with test data; show no real phone numbers or addresses.

### Full-screen intent

- **Use:** an incoming job offer that must be answered within 30 seconds, shown like an incoming call
  when the phone is locked.
- Android 14+ grants `USE_FULL_SCREEN_INTENT` by default only to calling and alarm apps. Declare the use
  case, but the app must also work when it isn't granted: check `canUseFullScreenIntent()`, fall back
  to a high-priority heads-up notification with sound, and offer the settings screen
  (`ACTION_MANAGE_APP_USE_FULL_SCREEN_INTENT`) from the permissions explainer. (P2, mechanic app.)

### Other permissions

Both apps: fine and coarse location, camera, notifications, internet. Each shown after a prominent
in-app disclosure (the permissions explainer screens). **Not requested:** background location, SMS,
contacts (the system contact picker needs no permission).

## App access (for Google's reviewers)

Both apps need a phone sign-in, and the mechanic app needs an **approved** mechanic, so give reviewers:

- Customer: a Firebase **test phone number** on the prod project, with its fixed code.
- Mechanic: a second test number, registered and approved in the admin console as a workshop mechanic
  in Ahmedabad.
- Instructions: "Sign in with the number and code below. Outside our cities, drag the pin to Ahmedabad on
  the confirm-location screen and choose 'I'm booking for someone else'. A booking then waits for a
  mechanic; with none online it ends with 'no mechanic found', which is expected. The mechanic account
  is approved and can go online."

Keep these test numbers only while a review is pending, and never reuse real people's numbers.

## Before submitting (day 20)

- [ ] `[[APP_NAME]]` and the legal placeholders filled in; the legal pages live on the prod share domain
- [ ] Listing text reviewed by native hi and gu speakers; `tool/check_store_listing.sh` passes
- [ ] Graphics uploaded in en, hi, gu
- [ ] Data safety filled in per app from the tables above
- [ ] Mechanic app: foreground-service video and full-screen-intent declaration
- [ ] Reviewer test accounts set up on prod
- [ ] 12 testers opted in for 14 days in the closed test (#52)
- [ ] Production release with a staged rollout (#61)
