// Shared test data. Not a test file, so importing it doesn't re-run any suite.

import { GeoPoint } from 'firebase-admin/firestore';

const common = {
  name: 'Ramesh',
  profilePhotoUrl: 'https://example.test/p.jpg',
  cityId: 'bharuch',
  vehicleTypes: ['car', 'bike'],
  services: ['flat_tyre', 'battery'],
};

export const WORKSHOP = {
  ...common,
  mechanicType: 'workshop',
  shopName: 'Shree Auto',
  shopAddress: 'Station Road, Bharuch',
  shopPhotoUrl: 'https://example.test/shop.jpg',
};

export const INDEPENDENT = {
  ...common,
  mechanicType: 'independent',
  baseArea: { locality: 'GIDC Ankleshwar', geopoint: new GeoPoint(21.62, 73.01) },
  experienceYears: 8,
  toolkitPhotoUrls: ['https://example.test/t1.jpg', 'https://example.test/t2.jpg'],
  travelVehicle: { type: 'bike', regNo: 'GJ16AB1234' },
};
