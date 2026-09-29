// Entry point: every deployed function is exported from here.
// Callables are built with secureCall() (src/lib/secureCall.ts); see firebase/functions/CLAUDE.md.

import { setGlobalOptions } from 'firebase-functions/v2';
import { REGION } from './lib/admin.js';

// Cost guard; raise per function when load tests show it's needed.
setGlobalOptions({ region: REGION, maxInstances: 10 });

export { assignDefaultRole } from './auth/beforeUserCreated.js';
export { createBooking } from './callables/createBooking.js';
export { respondToOffer } from './callables/respondToOffer.js';
export { dispatchOnBookingCreated, dispatchSweep, offerTimeout } from './dispatch/functions.js';
export { onBookingStatusChange } from './notifications/onBookingStatusChange.js';
