// onReviewCreated (PLAN §11 Dispatch step 8): keeps mechanics/{uid}.rating and ratingCount
// in step with the mechanic's reviews.
//
// The average is recomputed from all of the mechanic's reviews inside a transaction instead of
// being nudged by one review, so a retried trigger can't count a review twice and a missed
// one is picked up by the next. The rules already guarantee one review per completed booking,
// from its customer, naming its mechanic, with 1–5 stars.

import * as logger from 'firebase-functions/logger';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from '../lib/admin.js';

export interface RatingSummary {
  rating: number;
  ratingCount: number;
}

/** Average of the valid star values, to 2 decimals. 0 when there are none. */
export function summarise(stars: readonly unknown[]): RatingSummary {
  const valid = stars.filter((s): s is number => Number.isInteger(s) && (s as number) >= 1 && (s as number) <= 5);
  if (valid.length === 0) return { rating: 0, ratingCount: 0 };
  const avg = valid.reduce((a, b) => a + b, 0) / valid.length;
  return { rating: Math.round(avg * 100) / 100, ratingCount: valid.length };
}

export async function recomputeRating(mechanicId: string): Promise<RatingSummary | null> {
  const fs = db();
  const mechanicRef = fs.doc(`mechanics/${mechanicId}`);
  const reviews = fs.collection('reviews').where('mechanicId', '==', mechanicId);

  return fs.runTransaction(async (tx) => {
    const mechanic = await tx.get(mechanicRef);
    if (!mechanic.exists) return null;
    const summary = summarise((await tx.get(reviews)).docs.map((d) => d.get('stars')));
    tx.update(mechanicRef, { ...summary, updatedAt: FieldValue.serverTimestamp() });
    return summary;
  });
}

export const onReviewCreated = onDocumentCreated('reviews/{bookingId}', async (event) => {
  const mechanicId = event.data?.get('mechanicId') as string | undefined;
  if (!mechanicId) return;
  const summary = await recomputeRating(mechanicId);
  logger.info('onReviewCreated', { uid: mechanicId, bookingId: event.params.bookingId, updated: summary !== null });
});
