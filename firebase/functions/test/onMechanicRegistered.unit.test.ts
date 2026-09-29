import assert from 'node:assert/strict';
import { describe, it } from 'node:test';
import { decideClaims, missingLockedFields } from '../src/triggers/onMechanicRegistered.js';
import { WORKSHOP } from './fixtures.js';

describe('decideClaims', () => {
  it('makes a new user a pending mechanic and keeps their other claims', () => {
    const d = decideClaims({ role: 'customer', beta: true });
    assert.equal(d.outcome, 'granted');
    assert.deepEqual(d.claims, { role: 'mechanic', mechanicStatus: 'pending', beta: true });
    assert.equal(d.defaultStatus, 'pending');
  });

  it('works for a user with no claims yet', () => {
    assert.deepEqual(decideClaims({}).claims, { role: 'mechanic', mechanicStatus: 'pending' });
  });

  it('leaves an existing mechanic alone, so a retry after approval changes nothing', () => {
    const d = decideClaims({ role: 'mechanic', mechanicStatus: 'approved' });
    assert.equal(d.outcome, 'already_mechanic');
    assert.equal(d.claims, null);
    assert.equal(d.defaultStatus, 'approved');
  });

  it('keeps a blocked mechanic blocked', () => {
    assert.equal(decideClaims({ role: 'mechanic', mechanicStatus: 'blocked' }).defaultStatus, 'blocked');
  });

  it('never turns an admin into a mechanic', () => {
    const d = decideClaims({ role: 'admin' });
    assert.equal(d.outcome, 'admin_skipped');
    assert.equal(d.claims, null);
  });
});

describe('missingLockedFields', () => {
  it('fills every 🔒 field the app left out', () => {
    assert.deepEqual(missingLockedFields(WORKSHOP, 'pending'), {
      status: 'pending',
      rating: 0,
      ratingCount: 0,
      jobsCompleted: 0,
    });
  });

  it('never overwrites a field that is already there', () => {
    const doc = { ...WORKSHOP, status: 'approved', rating: 4.5 };
    assert.deepEqual(missingLockedFields(doc, 'pending'), { ratingCount: 0, jobsCompleted: 0 });
  });

  it('returns nothing when all 🔒 fields are present', () => {
    const doc = { ...WORKSHOP, status: 'pending', rating: 0, ratingCount: 0, jobsCompleted: 0 };
    assert.deepEqual(missingLockedFields(doc, 'pending'), {});
  });
});
