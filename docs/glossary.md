# Glossary (en / hi / gu)

Use these translations everywhere so a term reads the same on every screen (PLAN.md §6.15).

⚠ These are **draft** translations. A native speaker must review them before release (P3 owns this).

| Key | English | हिन्दी | ગુજરાતી |
|---|---|---|---|
| mechanic | Mechanic | मैकेनिक | મિકેનિક |
| get_help | Get help | मदद लें | મદદ મેળવો |
| pickup | Pickup | पिकअप स्थान | પિકઅપ સ્થળ |
| start_code | Start code | शुरू करने का कोड | શરૂ કરવાનો કોડ |
| on_the_way | On the way | रास्ते में | રસ્તામાં |
| arrived | Arrived | पहुँच गए | પહોંચી ગયા |
| working | Working | काम चल रहा है | કામ ચાલુ છે |
| done | Done | पूरा हुआ | પૂર્ણ |
| cancel | Cancel | रद्द करें | રદ કરો |
| flat_tyre | Flat tyre | टायर पंचर | ટાયર પંચર |
| battery | Battery | बैटरी | બેટરી |
| wont_start | Won't start | गाड़ी स्टार्ट नहीं हो रही | ગાડી સ્ટાર્ટ નથી થતી |
| overheating | Overheating | गाड़ी गरम हो रही है | ગાડી ગરમ થાય છે |
| accident | Accident | दुर्घटना | અકસ્માત |
| fuel | Fuel | ईंधन | ઇંધણ |
| other | Other | अन्य | અન્ય |
| price_estimate | Estimated price | अनुमानित कीमत | અંદાજિત કિંમત |
| i_have_paid | I have paid | मैंने भुगतान कर दिया | મેં ચુકવણી કરી દીધી |
| emergency | Emergency | आपातकाल | કટોકટી |
| service_area | Service area | सेवा क्षेत्र | સેવા વિસ્તાર |
| privacy_policy | Privacy policy | गोपनीयता नीति | ગોપનીયતા નીતિ |
| terms | Terms of use | उपयोग की शर्तें | ઉપયોગની શરતો |
| delete_account | Delete account | खाता हटाएँ | એકાઉન્ટ કાઢી નાખો |
| grievance_officer | Grievance officer | शिकायत अधिकारी | ફરિયાદ અધિકારી |
| consent | Consent | सहमति | સંમતિ |
| workshop | Workshop | वर्कशॉप | વર્કશૉપ |
| independent | Independent (mechanic) | स्वतंत्र | સ્વતંત્ર |
| verification_call | Verification call | वेरिफ़िकेशन कॉल | વેરિફિકેશન કૉલ |

## Native-speaker review (#55)

Tick when a native Hindi and a native Gujarati speaker have read every string in context (on the
screen, not only in the file):

- [ ] This glossary
- [ ] `customer_app/lib/l10n/app_hi.arb`, `app_gu.arb`
- [ ] `mechanic_app/lib/l10n/app_hi.arb`, `app_gu.arb`
- [ ] `admin_panel/lib/l10n/app_hi.arb`, `app_gu.arb` (drafts written with the admin screens)
- [ ] `packages/lane_ui/lib/l10n/` (component strings)
- [ ] Hindi and Gujarati versions of the legal pages (`docs/legal/README.md`)

Known inconsistencies to settle in the review:

- **done:** this glossary says पूरा हुआ / પૂર્ણ; the admin console's booking status uses पूरा / પૂરું.
- **cancel (status):** the admin console uses रद्द / રદ for the *status* "Cancelled" and रद्द करें / રદ કરો for the *action*; confirm both.
- **Brand words** like "UPI", "KYC", "OTP" are kept in Latin script everywhere; confirm that's what users expect.
