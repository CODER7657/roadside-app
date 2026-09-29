// The public live-trip page at /t/{token} (issue #37).
//
// Rendered on the server so the person opening the link needs no login, App Check or
// JavaScript: Firebase Hosting rewrites /t/** to this function. The page shows only what
// getSharedTrip returns, refreshes itself every 30 s, and is kept out of caches, search engines
// and referrers. Unknown and expired links get the same answer, so a link can't be probed.

import { createHash } from 'node:crypto';
import * as logger from 'firebase-functions/logger';
import { onRequest } from 'firebase-functions/v2/https';
import { HttpsError } from 'firebase-functions/v2/https';
import { REGION } from '../lib/admin.js';
import { enforceRateLimit, type RateLimit } from '../lib/rateLimit.js';
import { getSharedTrip, TOKEN_PATTERN, type SharedTrip } from './shareLinks.js';

/** Per client IP. An open tab refreshes 20 times in 10 minutes, so this allows ~6 tabs. */
export const PAGE_RATE_LIMIT: RateLimit = { max: 120, windowSeconds: 600 };
const REFRESH_SECONDS = 30;

type Lang = 'en' | 'hi' | 'gu';

// hi/gu to be checked in the glossary review (#55).
const STRINGS: Record<Lang, Record<string, string>> = {
  en: {
    title: 'Live trip',
    requested: 'Looking for a mechanic nearby',
    accepted: '{name} has accepted and is getting ready',
    arriving: '{name} is on the way',
    arrived: '{name} has arrived',
    in_progress: '{name} is working on the vehicle',
    eta: 'About {eta} min away',
    map: 'See roughly where they are',
    refresh: 'This page updates every 30 seconds.',
    gone_title: 'This link is no longer active',
    gone_body: 'Trip links stop working when the job ends, or after 3 hours.',
    busy: 'Too many requests. Please try again in a few minutes.',
  },
  hi: {
    title: 'लाइव यात्रा',
    requested: 'पास में मैकेनिक ढूँढ रहे हैं',
    accepted: '{name} ने काम स्वीकार कर लिया है और तैयार हो रहे हैं',
    arriving: '{name} रास्ते में हैं',
    arrived: '{name} पहुँच गए हैं',
    in_progress: '{name} गाड़ी पर काम कर रहे हैं',
    eta: 'लगभग {eta} मिनट दूर',
    map: 'देखें वे लगभग कहाँ हैं',
    refresh: 'यह पेज हर 30 सेकंड में अपडेट होता है।',
    gone_title: 'यह लिंक अब सक्रिय नहीं है',
    gone_body: 'काम पूरा होने पर या 3 घंटे बाद यात्रा लिंक काम करना बंद कर देते हैं।',
    busy: 'बहुत सारे अनुरोध। कृपया कुछ मिनट बाद फिर कोशिश करें।',
  },
  gu: {
    title: 'લાઇવ મુસાફરી',
    requested: 'નજીકમાં મિકેનિક શોધી રહ્યા છીએ',
    accepted: '{name}એ કામ સ્વીકાર્યું છે અને તૈયાર થઈ રહ્યા છે',
    arriving: '{name} રસ્તામાં છે',
    arrived: '{name} પહોંચી ગયા છે',
    in_progress: '{name} વાહન પર કામ કરી રહ્યા છે',
    eta: 'આશરે {eta} મિનિટ દૂર',
    map: 'તેઓ આશરે ક્યાં છે તે જુઓ',
    refresh: 'આ પેજ દર 30 સેકન્ડે અપડેટ થાય છે.',
    gone_title: 'આ લિંક હવે સક્રિય નથી',
    gone_body: 'કામ પૂરું થાય ત્યારે અથવા 3 કલાક પછી મુસાફરી લિંક બંધ થઈ જાય છે.',
    busy: 'ઘણી બધી વિનંતીઓ. કૃપા કરીને થોડી મિનિટો પછી ફરી પ્રયાસ કરો.',
  },
};

const HEADERS: Record<string, string> = {
  'Content-Type': 'text/html; charset=utf-8',
  'Cache-Control': 'no-store, private',
  'X-Robots-Tag': 'noindex, nofollow',
  'Referrer-Policy': 'no-referrer',
  'X-Content-Type-Options': 'nosniff',
  'Content-Security-Policy': "default-src 'none'; style-src 'unsafe-inline'; base-uri 'none'; form-action 'none'; frame-ancestors 'none'",
};

export function escapeHtml(s: string): string {
  return s.replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[c]!);
}

function fill(template: string, values: Record<string, string>): string {
  return template.replace(/\{(\w+)\}/g, (_, k: string) => escapeHtml(values[k] ?? ''));
}

export function pickLang(queryLang: unknown, acceptLanguage: string | undefined): Lang {
  if (queryLang === 'hi' || queryLang === 'gu' || queryLang === 'en') return queryLang;
  for (const part of (acceptLanguage ?? '').toLowerCase().split(',')) {
    const code = part.trim().slice(0, 2);
    if (code === 'hi' || code === 'gu' || code === 'en') return code;
  }
  return 'en';
}

function page(lang: Lang, title: string, body: string, refresh: boolean): string {
  return `<!doctype html>
<html lang="${lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="robots" content="noindex, nofollow">
${refresh ? `<meta http-equiv="refresh" content="${REFRESH_SECONDS}">` : ''}
<title>${escapeHtml(title)}</title>
<style>
  body { margin: 0; font: 18px/1.5 system-ui, sans-serif; background: #fafaf9; color: #1c1917; }
  main { max-width: 28rem; margin: 0 auto; padding: 2rem 1.25rem; }
  h1 { font-size: 1.5rem; margin: 0 0 1rem; }
  .status { font-size: 1.25rem; font-weight: 600; }
  .eta { color: #b45309; font-weight: 600; }
  a { color: #1d4ed8; }
  .small { color: #57534e; font-size: 0.9rem; margin-top: 2rem; }
  @media (prefers-color-scheme: dark) {
    body { background: #1c1917; color: #fafaf9; } .small { color: #a8a29e; } a { color: #93c5fd; } .eta { color: #fbbf24; }
  }
</style>
</head>
<body><main>${body}</main></body>
</html>`;
}

export function renderTrip(trip: SharedTrip, lang: Lang): string {
  const t = STRINGS[lang];
  const name = trip.mechanicFirstName ?? '';
  const status = trip.status === 'requested' || !name ? t.requested! : fill(t[trip.status] ?? t.requested!, { name });
  const eta = trip.etaMinutes != null ? `<p class="eta">${fill(t.eta!, { eta: String(trip.etaMinutes) })}</p>` : '';
  const map = trip.position
    ? `<p><a href="https://www.google.com/maps/search/?api=1&amp;query=${trip.position.lat},${trip.position.lng}" rel="noopener noreferrer">${escapeHtml(t.map!)}</a></p>`
    : '';
  const body = `<h1>${escapeHtml(t.title!)}</h1><p class="status">${status}</p>${eta}${map}<p class="small">${escapeHtml(t.refresh!)}</p>`;
  return page(lang, t.title!, body, true);
}

export function renderGone(lang: Lang): string {
  const t = STRINGS[lang];
  return page(lang, t.gone_title!, `<h1>${escapeHtml(t.gone_title!)}</h1><p>${escapeHtml(t.gone_body!)}</p>`, false);
}

/**
 * Rate-limit key for a client: a hash, so raw IP addresses are never stored.
 * The first X-Forwarded-For entry can be spoofed, so this only caps cost; links are protected
 * by their 128-bit token, and maxInstances bounds spend.
 */
export function clientKey(forwardedFor: string | string[] | undefined, ip: string | undefined): string {
  const first = (Array.isArray(forwardedFor) ? forwardedFor[0] : forwardedFor)?.split(',')[0]?.trim();
  const addr = first || ip || 'unknown';
  return `share_ip_${createHash('sha256').update(addr).digest('hex').slice(0, 32)}`;
}

/** The parts of Express's req/res the page uses, so tests can pass plain objects. */
export interface PageRequest {
  method: string;
  path: string;
  query: Record<string, unknown>;
  headers: Record<string, string | string[] | undefined>;
  ip?: string;
}
export interface PageResponse {
  status(code: number): PageResponse;
  set(field: string, value: string): PageResponse;
  send(body: string): unknown;
}

export async function handleSharePage(req: PageRequest, res: PageResponse): Promise<void> {
  const lang = pickLang(req.query.lang, req.headers['accept-language'] as string | undefined);
  for (const [k, v] of Object.entries(HEADERS)) res.set(k, v);

  if (req.method !== 'GET' && req.method !== 'HEAD') {
    res.set('Allow', 'GET, HEAD');
    res.status(405).send('');
    return;
  }

  try {
    await enforceRateLimit(clientKey(req.headers['x-forwarded-for'], req.ip), 'sharePage', PAGE_RATE_LIMIT);
  } catch (err) {
    if (err instanceof HttpsError && err.code === 'resource-exhausted') {
      res.set('Retry-After', String(PAGE_RATE_LIMIT.windowSeconds));
      res.status(429).send(page(lang, STRINGS[lang].title!, `<p>${escapeHtml(STRINGS[lang].busy!)}</p>`, false));
      return;
    }
    throw err;
  }

  // /t/{token}; anything else is treated like an unknown link.
  const token = req.path.match(/^\/t\/([^/]+)\/?$/)?.[1] ?? '';
  const trip = TOKEN_PATTERN.test(token) ? await getSharedTrip(token) : null;
  if (!trip) {
    res.status(410).send(renderGone(lang));
    return;
  }
  res.status(200).send(renderTrip(trip, lang));
}

export const sharePage = onRequest({ region: REGION, invoker: 'public', maxInstances: 5 }, async (req, res) => {
  try {
    await handleSharePage(req as unknown as PageRequest, res as unknown as PageResponse);
  } catch (err) {
    // No token, IP or trip data in logs.
    logger.error('sharePage failed', { errorName: err instanceof Error ? err.name : typeof err });
    res.status(500).set('Cache-Control', 'no-store').send('');
  }
});
