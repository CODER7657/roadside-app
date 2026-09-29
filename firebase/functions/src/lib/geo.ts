// Small geo helpers: distance and geohash (PLAN §8, §11). Written here instead of
// pulling in geofire-common, which hasn't been updated since 2022 (PLAN §3 package rule).

const EARTH_RADIUS_KM = 6371.0088;
const BASE32 = '0123456789bcdefghjkmnpqrstuvwxyz';

export interface LatLng {
  lat: number;
  lng: number;
}

const rad = (deg: number): number => (deg * Math.PI) / 180;

/** Great-circle distance in km (haversine). */
export function distanceKm(a: LatLng, b: LatLng): number {
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 + Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * EARTH_RADIUS_KM * Math.asin(Math.min(1, Math.sqrt(h)));
}

/** Size of one geohash cell in km at `precision`, measured at latitude `lat`. */
function cellSizeKm(precision: number, lat: number): { heightKm: number; widthKm: number } {
  const bits = precision * 5;
  const lngBits = Math.ceil(bits / 2);
  const latBits = Math.floor(bits / 2);
  const kmPerDeg = (Math.PI * EARTH_RADIUS_KM) / 180;
  return {
    heightKm: (180 / 2 ** latBits) * kmPerDeg,
    widthKm: (360 / 2 ** lngBits) * kmPerDeg * Math.cos(rad(lat)),
  };
}

/**
 * Geohash ranges that together cover every point within `radiusKm` of `center`:
 * the cell containing the centre plus its 8 neighbours, at the finest precision whose
 * cells are still at least `radiusKm` across. Query `>= start` and `<= end` for each,
 * then filter by real distance (the cells over-cover).
 */
export function geohashQueryBounds(center: LatLng, radiusKm: number): Array<[string, string]> {
  let precision = 1;
  for (let p = 9; p >= 1; p--) {
    const { heightKm, widthKm } = cellSizeKm(p, center.lat);
    if (heightKm >= radiusKm && widthKm >= radiusKm) {
      precision = p;
      break;
    }
  }
  const { heightKm, widthKm } = cellSizeKm(precision, center.lat);
  const kmPerDeg = (Math.PI * EARTH_RADIUS_KM) / 180;
  const dLat = heightKm / kmPerDeg;
  const dLng = widthKm / (kmPerDeg * Math.cos(rad(center.lat)));

  const hashes = new Set<string>();
  for (const i of [-1, 0, 1]) {
    for (const j of [-1, 0, 1]) {
      const lat = Math.max(-90, Math.min(90, center.lat + i * dLat));
      const lng = ((center.lng + j * dLng + 540) % 360) - 180;
      hashes.add(geohash({ lat, lng }, precision));
    }
  }
  return [...hashes].sort().map((h) => [h, `${h}~`]);
}

/** Standard base-32 geohash. Precision 10 ≈ 1.2 m × 0.6 m cells. */
export function geohash({ lat, lng }: LatLng, precision = 10): string {
  let latMin = -90;
  let latMax = 90;
  let lngMin = -180;
  let lngMax = 180;
  let hash = '';
  let bits = 0;
  let bitCount = 0;
  let evenBit = true; // even bits encode longitude

  while (hash.length < precision) {
    if (evenBit) {
      const mid = (lngMin + lngMax) / 2;
      if (lng >= mid) {
        bits = (bits << 1) | 1;
        lngMin = mid;
      } else {
        bits <<= 1;
        lngMax = mid;
      }
    } else {
      const mid = (latMin + latMax) / 2;
      if (lat >= mid) {
        bits = (bits << 1) | 1;
        latMin = mid;
      } else {
        bits <<= 1;
        latMax = mid;
      }
    }
    evenBit = !evenBit;
    if (++bitCount === 5) {
      hash += BASE32[bits];
      bits = 0;
      bitCount = 0;
    }
  }
  return hash;
}
