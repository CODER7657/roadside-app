# Rendering ThreeUI backgrounds as still images

The apps never run WebGL. We render ThreeUI scenes to JPG/PNG and ship the images (PLAN.md §6.17).

1. Clone ThreeUI and install it:
   ```bash
   git clone --depth 1 https://github.com/MengTo/threeui.git
   ```
   Then run `npm install` inside the clone.
2. Copy `capture.html` into the clone's root and `capture.tsx` into its `src/`, then start Vite:
   ```bash
   npx vite --port 5199
   ```
3. Open (or screenshot with headless Chrome) `http://localhost:5199/capture.html?c=<Component>&p=<url-encoded JSON props>`. Examples we used:
   - Amber horizon (splash, onboarding, cover): `c=EmeraldHorizonBackground&p={"hue":-100}`
   - Signal-colour streams: `c=StreamConvergenceBackground&p={"hue":100}`
   - Amber warp: `c=WarpFieldBackground&p={"hue":-120,"saturation":1.6}`
   - Gold liquid: `c=LiquidFormBackground&p={"tintHue":40,"tintAmount":0.7}`
4. Headless capture (Windows paths shown):
   ```bash
   chrome --headless=new --enable-unsafe-swiftshader --use-angle=swiftshader --hide-scrollbars --window-size=1080,2400 --virtual-time-budget=9000 --screenshot=out.png "http://localhost:5199/capture.html?c=EmeraldHorizonBackground&p=%7B%22hue%22%3A-100%7D"
   ```
5. Save phone backgrounds at 1080×2400 and the Play feature graphic at 1024×500, compressed (JPG q≈85 or WebP), into `assets/threeui/backgrounds/`.
