"""
GO ICELAND - Map Preview Downloader
Downloads Mapbox static map previews for each POI
"""
import requests
import json
import os
from time import sleep

MAPBOX_TOKEN = os.getenv("MAPBOX_TOKEN")
INPUT = "./data/iceland_clean.json"
OUTPUT_DIR = "./previews"

MAPBOX_STYLE = "mapbox/outdoors-v12"
WIDTH = 500
HEIGHT = 500
ZOOM = 14

def download_preview(poi):
    """Download Mapbox static image for POI"""
    lat = poi["lat"]
    lng = poi["lng"]
    
    # Mapbox Static Images API
    url = (
        f"https://api.mapbox.com/styles/v1/{MAPBOX_STYLE}/static/"
        f"pin-s+ff0000({lng},{lat})/"
        f"{lng},{lat},{ZOOM},0/{WIDTH}x{HEIGHT}@2x"
        f"?access_token={MAPBOX_TOKEN}"
    )
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        return response.content
    except Exception as e:
        print(f"Error downloading preview for {poi['name']}: {e}")
        return None

def main():
    if not MAPBOX_TOKEN:
        print("❌ MAPBOX_TOKEN not found in environment")
        print("Set it with: $env:MAPBOX_TOKEN='your_token'")
        return

    with open(INPUT, encoding="utf-8") as f:
        places = json.load(f)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Downloading {len(places)} previews...")

    for i, p in enumerate(places, 1):
        poi_id = p.get("id", p["name"].replace(" ", "_"))
        fname = os.path.join(OUTPUT_DIR, f"{poi_id}.jpg")
        
        if os.path.exists(fname):
            print(f"[{i}/{len(places)}] Skipping {p['name']} (exists)")
            continue
        
        image = download_preview(p)
        
        if image:
            with open(fname, "wb") as f:
                f.write(image)
            print(f"[{i}/{len(places)}] ✅ {p['name']}")
            sleep(0.3)  # Rate limiting
        else:
            print(f"[{i}/{len(places)}] ❌ Failed: {p['name']}")

    print(f"\n✅ Previews saved to: {OUTPUT_DIR}")

if __name__ == "__main__":
    main()
