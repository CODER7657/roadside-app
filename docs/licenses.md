# Third-party licenses and attributions

Keep this file up to date. The apps' "Open-source licenses" screen (Flutter `showLicensePage`) must also list ThreeUI and Phosphor, since they aren't pub packages we depend on directly.

| What | Where we use it | License | Obligation |
|---|---|---|---|
| **ThreeUI Community** by Meng To (https://github.com/MengTo/threeui) | Button styles (Launch, Spinning Border, Gradient CTA, Gradient Beam) re-implemented in `lane_ui`; pre-rendered backgrounds in `assets/threeui/backgrounds/`; type pairing | MIT, `assets/threeui/LICENSE-threeui-MIT.txt` | Keep the copyright + license notice with copies; credit in the app's licenses screen |
| **Phosphor Icons** (https://github.com/phosphor-icons/core, `phosphor_flutter`) | All icons and pictograms | MIT, `assets/pictograms/LICENSE-phosphor-MIT.txt` | Keep the notice |
| **Onest**, **Instrument Serif**, **JetBrains Mono**, **Anek Devanagari**, **Anek Gujarati** | App and document typography | SIL Open Font License 1.1, `assets/fonts/licenses/` | Bundle the OFL text with the fonts; don't sell the fonts on their own |
| **OpenStreetMap** data via **OpenFreeMap** vector tiles (**OpenMapTiles** schema), rendered with **MapLibre GL** (BSD-3) | Mockup maps in `assets/maps/` (design docs only, not the app) | Data ODbL; tiles © OpenMapTiles; OpenFreeMap free to use | Keep "© OpenStreetMap contributors · OpenMapTiles · OpenFreeMap" on the images (already baked in) |
| **OSRM** demo server | Route geometry for the mockup maps | OSRM (BSD-2); data ODbL | Demo server for one-off use only |
| **Ola Maps** (app runtime) | Maps, directions, geocoding in the apps | Ola Maps terms | Follow their attribution rules in the map UI |
| **Lottie files** (4, to be chosen) | Onboarding / empty / searching / done | Check each file's license before adding | Record each one here |
