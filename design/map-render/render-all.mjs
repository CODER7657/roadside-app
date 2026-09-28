// Renders every mockup map into ../../assets/maps/. Needs a local Chrome (set CHROME_PATH if not the Windows default).
import { execFileSync } from 'node:child_process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import path from 'node:path';
const here = path.dirname(fileURLToPath(import.meta.url));
const out = path.resolve(here, '../../assets/maps');
const page = pathToFileURL(path.join(here, 'render.html')).href;
const jobs = [
  ['map-day-pickup.png', 'pickup', 'day', 360, 790, 2],
  ['map-night-pickup.png', 'pickup', 'night', 360, 790, 2],
  ['map-day-route.png', 'route', 'day', 360, 790, 2],
  ['map-night-route.png', 'route', 'night', 360, 790, 2],
  ['map-night-wide.png', 'wide', 'night', 1600, 900, 1],
  ['map-day-wide.png', 'wide', 'day', 1600, 900, 1],
];
for (const [file, view, theme, w, h, dsf] of jobs) {
  execFileSync('node', [path.join(here, 'shoot.mjs'), `${page}?view=${view}&theme=${theme}`, path.join(out, file), String(w), String(h), String(dsf)], { stdio: 'inherit' });
}
