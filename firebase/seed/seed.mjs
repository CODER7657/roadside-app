#!/usr/bin/env node
// Seeds serviceAreas/{ahmedabad|ankleshwar|bharuch}, appConfig/public and prices/* (PLAN.md §8).
//
//   # emulator (default project demo-roadside)
//   firebase emulators:exec --project demo-roadside --only firestore "npm --prefix seed run seed"
//
//   # a real project (Application Default Credentials: `gcloud auth application-default login`)
//   npm --prefix seed run seed -- --project roadside-33282 --support-phone +91XXXXXXXXXX
//
// Existing documents are left alone, so admin changes (a city switched off, a new price) survive a
// re-run. Pass --overwrite to replace them. roadside-prod also needs --allow-prod.

import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';
import { initializeApp } from 'firebase-admin/app';
import { FieldValue, GeoPoint, getFirestore } from 'firebase-admin/firestore';

const { values: args } = parseArgs({
  options: {
    project: { type: 'string' },
    'support-phone': { type: 'string' },
    overwrite: { type: 'boolean', default: false },
    'allow-prod': { type: 'boolean', default: false },
  },
});

const emulator = process.env.FIRESTORE_EMULATOR_HOST;
const projectId = args.project ?? process.env.GCLOUD_PROJECT ?? (emulator ? 'demo-roadside' : undefined);
if (!projectId) fail('No project. Run inside `firebase emulators:exec` or pass --project roadside-33282.');
if (!emulator && projectId.includes('prod') && !args['allow-prod']) {
  fail(`Refusing to seed ${projectId} without --allow-prod.`);
}

const E164 = /^\+[1-9][0-9]{7,14}$/;
const supportPhone = args['support-phone'] ?? (emulator ? '+919800000000' : undefined);
if (!supportPhone || !E164.test(supportPhone)) {
  fail('Pass --support-phone in E.164 (e.g. +919876543210): it is shown to customers.');
}

const here = dirname(fileURLToPath(import.meta.url));
const load = (name) => JSON.parse(readFileSync(join(here, 'data', name), 'utf8'));

const db = getFirestore(initializeApp({ projectId }));
const now = FieldValue.serverTimestamp();
const base = { createdAt: now, updatedAt: now, schemaVersion: 1 };

const docs = [];
for (const [cityId, a] of Object.entries(load('serviceAreas.json'))) {
  docs.push([
    `serviceAreas/${cityId}`,
    {
      name: a.name,
      center: new GeoPoint(a.center[0], a.center[1]),
      radiusKm: a.radiusKm,
      active: a.active,
      supportPhone,
      launchedAt: null,
      ...base,
    },
  ]);
}
docs.push(['appConfig/public', { ...load('appConfig.json'), supportPhone }]);
for (const [id, p] of Object.entries(load('prices.json'))) {
  if (id !== `${p.vehicleType}_${p.problemType}` || !(p.min < p.max)) fail(`Bad price ${id}`);
  docs.push([`prices/${id}`, { ...p, ...base }]);
}

let written = 0;
let skipped = 0;
for (const [path, data] of docs) {
  const ref = db.doc(path);
  if (!args.overwrite && (await ref.get()).exists) {
    skipped++;
    continue;
  }
  await ref.set(data);
  written++;
}
console.log(`Seeded ${projectId}${emulator ? ' (emulator)' : ''}: ${written} written, ${skipped} already there.`);

function fail(message) {
  console.error(message);
  process.exit(1);
}
