"""Render real-map backdrops for wireframes/mockups from OpenStreetMap tiles (© OpenStreetMap contributors, ODbL).
One-off, low-volume use per the OSM tile policy. Route geometry from the public OSRM demo server.
Output: assets/maps/*.png (day = muted, night = dark), with the real driving route drawn in."""
import io, math, json, os, tempfile, urllib.request
from PIL import Image, ImageDraw, ImageEnhance, ImageOps, ImageFilter

UA = {"User-Agent": "RoadsideWireframes/1.0 (one-off design mockup render)"}
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "maps")
Z = 16
MECH = (72.5190, 23.0385)    # mechanic start (Bodakdev side)
PICK = (72.5117, 23.0495)    # customer pickup (Thaltej, near SG Highway)

def get(url):
    with urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=30) as r:
        return r.read()

def px(lon, lat, z=None):
    z = Z if z is None else z
    n = 2 ** z * 256
    x = (lon + 180) / 360 * n
    y = (1 - math.log(math.tan(math.radians(lat)) + 1 / math.cos(math.radians(lat))) / math.pi) / 2 * n
    return x, y

route = json.loads(get(f"https://router.project-osrm.org/route/v1/driving/{MECH[0]},{MECH[1]};{PICK[0]},{PICK[1]}?overview=full&geometries=geojson"))
coords = route["routes"][0]["geometry"]["coordinates"]
print("route km", route["routes"][0]["distance"] / 1000)

tile_cache = {}
CACHE = os.environ.get("TILE_CACHE", os.path.join(tempfile.gettempdir(), "osm-tiles")); os.makedirs(CACHE, exist_ok=True)
def canvas(cx, cy, w, h):
    """Stitch tiles so that global pixel (cx,cy) is centred in a w x h image."""
    x0, y0 = int(cx - w / 2), int(cy - h / 2)
    img = Image.new("RGB", (w, h))
    for tx in range(x0 // 256, (x0 + w) // 256 + 1):
        for ty in range(y0 // 256, (y0 + h) // 256 + 1):
            k = (tx, ty)
            if k not in tile_cache:
                f = os.path.join(CACHE, f"{Z}_{tx}_{ty}.png")
                if not os.path.exists(f):
                    open(f, "wb").write(get(f"https://tile.openstreetmap.org/{Z}/{tx}/{ty}.png"))
                tile_cache[k] = Image.open(f).convert("RGB")
            img.paste(tile_cache[k], (tx * 256 - x0, ty * 256 - y0))
    return img, x0, y0

def day(img):   # muted "Lane" day style: low saturation, warm paper
    g = ImageEnhance.Color(img).enhance(0.28)
    g = ImageEnhance.Contrast(g).enhance(0.92)
    tint = Image.new("RGB", img.size, (244, 243, 238))
    return Image.blend(g, tint, 0.18)

def night(img): # dark "Asphalt" style: invert, cool it down, lower contrast
    g = ImageOps.invert(ImageEnhance.Color(img).enhance(0.0))
    g = ImageEnhance.Brightness(g).enhance(0.9)
    g = ImageEnhance.Contrast(g).enhance(1.25)
    tint = Image.new("RGB", img.size, (18, 22, 30))
    return Image.blend(g, tint, 0.28)

def draw_route(img, x0, y0, color, width):
    big = img.resize((img.width * 2, img.height * 2), Image.LANCZOS)
    d = ImageDraw.Draw(big)
    pts = [((px(lo, la)[0] - x0) * 2, (px(lo, la)[1] - y0) * 2) for lo, la in coords]
    d.line(pts, fill=(255, 255, 255), width=width * 2 + 8, joint="curve")
    d.line(pts, fill=color, width=width * 2, joint="curve")
    return big.resize(img.size, Image.LANCZOS), pts

def save(img, name):
    p = os.path.join(OUT, name); img.save(p, optimize=True); print(name, img.size)

W, H = 640, 1400  # phone screen aspect, 2x density
pcx, pcy = px(*PICK)
mcx, mcy = px(*MECH)
# 1 · pickup-centred (Home, Confirm location)
img, x0, y0 = canvas(pcx, pcy + 260, W, H)  # pickup sits at ~31% height (the dock covers the bottom)
save(day(img), "map-day-pickup.png"); save(night(img), "map-night-pickup.png")
# 2 · route views (Tracking, Navigate): zoom out one level so the whole route sits above the dock
Z = 15; tile_cache.clear()
pcx, pcy = px(*PICK); mcx, mcy = px(*MECH)
rcx, rcy = (pcx + mcx) / 2, (pcy + mcy) / 2 + 260
img, x0, y0 = canvas(rcx, rcy, W, H)
r, pts = draw_route(night(img), x0, y0, (126, 162, 255), 7); save(r, "map-night-route.png")
r, _ = draw_route(day(img), x0, y0, (30, 91, 255), 7); save(r, "map-day-route.png")
meta = {"pickup_home_px": [pcx - (pcx - W/2), H/2 - 260], "pickup_px": [pcx - x0, pcy - y0], "mech_px": [mcx - x0, mcy - y0], "size": [W, H], "route_km": round(route["routes"][0]["distance"] / 1000, 2)}
# 3 · admin wide dark map
img, ax0, ay0 = canvas(rcx, rcy - 260, 1600, 900)
save(night(img), "map-night-wide.png")
json.dump(meta, open(os.path.join(OUT, "map-meta.json"), "w"), indent=1)
print(meta, "tiles fetched:", len(tile_cache))
open(os.path.join(OUT, "ATTRIBUTION.txt"), "w").write("Map data and tiles © OpenStreetMap contributors (https://www.openstreetmap.org/copyright), ODbL. Styled (desaturated / inverted) for design mockups only. Route geometry: OSRM demo server. In the real apps, maps come from Ola Maps (see PLAN.md).\n")
