"""
GO ICELAND - OSM Data Fetcher
Fetches 2000-4500 POIs from OpenStreetMap for Iceland
"""
import requests
import json
from time import sleep

OUTPUT = "./data/iceland_raw.json"
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

QUERIES = [
    'node["natural"="waterfall"]',
    'node["natural"="geyser"]',
    'node["natural"="spring"]',
    'node["tourism"="viewpoint"]',
    'node["tourism"="attraction"]',
    'node["historic"]',
    'node["tourism"="museum"]',
    'node["amenity"="restaurant"]',
    'node["amenity"="cafe"]',
    'node["amenity"="fast_food"]',
    'node["amenity"="bar"]',
    'node["amenity"="pub"]',
    'node["route"="hiking"]',
    'node["natural"="peak"]',
    'node["natural"="volcano"]',
    'node["tourism"="hotel"]',
    'node["tourism"="guest_house"]',
    'node["tourism"="hostel"]',
    'node["tourism"="motel"]',
    'node["tourism"="camp_site"]',
    'node["amenity"="parking"]',
    'node["natural"="beach"]',
    'node["natural"="cave_entrance"]',
    'node["tourism"="information"]',
    'node["shop"="supermarket"]'
]

BBOX = "(63.0,-25.0,67.5,-12.0)"  # Iceland bounding box

def run_query(q, retry=3):
    """Execute Overpass API query with retry logic"""
    query = f"[out:json];{q}{BBOX};out center;"
    print(f"Running → {q}")
    
    for attempt in range(retry):
        try:
            resp = requests.post(OVERPASS_URL, data=query, timeout=90)
            resp.raise_for_status()
            sleep(10)  # Much slower rate limiting (10 seconds)
            return resp.json()
        except requests.exceptions.HTTPError as e:
            if "429" in str(e):
                wait_time = 30 * (attempt + 1)
                print(f"  Rate limited, waiting {wait_time}s...")
                sleep(wait_time)
            else:
                print(f"  HTTP Error (attempt {attempt+1}/{retry}): {e}")
                sleep(5)
        except requests.exceptions.Timeout:
            print(f"  Timeout (attempt {attempt+1}/{retry}), retrying...")
            sleep(5)
        except requests.exceptions.RequestException as e:
            print(f"  Error (attempt {attempt+1}/{retry}): {e}")
            sleep(5)
        except Exception as e:
            print(f"  Unexpected error: {e}")
            break
    
    print(f"  ❌ Failed after {retry} attempts, skipping...")
    return {"elements": []}

def main():
    all_pois = []

    for q in QUERIES:
        try:
            data = run_query(q)
            for el in data.get("elements", []):
                tags = el.get("tags", {})
                name = tags.get("name")
                
                if not name:
                    continue

                lat = el.get("lat") or el.get("center", {}).get("lat")
                lon = el.get("lon") or el.get("center", {}).get("lon")

                if not lat or not lon:
                    continue

                all_pois.append({
                    "name": name,
                    "lat": lat,
                    "lng": lon,
                    "category": q,
                    "rating": None,
                    "thumbnail": None,
                    "description": tags.get("description"),
                    "website": tags.get("website"),
                    "wikipedia": tags.get("wikipedia"),
                    "phone": tags.get("phone"),
                    "opening_hours": tags.get("opening_hours"),
                    "cuisine": tags.get("cuisine"),
                    "stars": tags.get("stars"),
                    "email": tags.get("email"),
                    "addr_street": tags.get("addr:street"),
                    "addr_city": tags.get("addr:city"),
                    "addr_postcode": tags.get("addr:postcode")
                })

        except Exception as e:
            print(f"Error processing query {q}: {e}")

    print(f"\nTotal POIs fetched: {len(all_pois)}")

    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(all_pois, f, indent=2, ensure_ascii=False)

    print(f"✅ Saved to: {OUTPUT}")

if __name__ == "__main__":
    main()
