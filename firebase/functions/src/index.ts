// Entry point: every deployed function is exported from here.
// Callables are built with secureCall() (src/lib/secureCall.ts); see firebase/functions/CLAUDE.md.

import { setGlobalOptions } from 'firebase-functions/v2';
import { REGION } from './lib/admin.js';

// Cost guard; raise per function when load tests show it's needed.
setGlobalOptions({ region: REGION, maxInstances: 10 });

export { assignDefaultRole } from './auth/beforeUserCreated.js';
export { cancelBooking } from './callables/cancelBooking.js';
export { createBooking } from './callables/createBooking.js';
export { respondToOffer } from './callables/respondToOffer.js';
export { markArrived, startTrip } from './callables/tripSteps.js';
export { verifyStartOtp } from './callables/verifyStartOtp.js';
export { dispatchOnBookingCreated, dispatchSweep, offerTimeout } from './dispatch/functions.js';
export { onBookingStatusChange } from './notifications/onBookingStatusChange.js';
export { onMechanicRegistered } from './triggers/onMechanicRegistered.js';
export { onReviewCreated } from './triggers/onReviewCreated.js';
export { createShareLink } from './share/shareLinks.js';
export { sharePage } from './share/sharePage.js';
