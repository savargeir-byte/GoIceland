"""
🇮🇸 FETCH ALL PLACES IN ICELAND FROM OPENSTREETMAP
Production-ready script to fetch 2000-4000+ POIs

Categories:
- Waterfalls, glaciers, geysers, hot springs
- Beaches, cliffs, caves, viewpoints
- Hotels, restaurants, museums, attractions
- Churches, ruins, monuments
- Parking, toilets, campgrounds
"""

import requests
import json
import time
from datetime import datetime


OVERPASS_API = "https://overpass-api.de/api/interpreter"
ICELAND_BBOX = "(63.0,-25.0,67.6,-12.0)"  # South, West, North, East

# Comprehensive query for ALL relevant POIs in Iceland
QUERIES = [
    # NATURE
    'node["natural"="waterfall"]',
    'node["natural"="glacier"]',
    'node["natural"="hot_spring"]',
    'node["natural"="geyser"]',
    'node["natural"="beach"]',
    'node["natural"="cliff"]',
    'node["natural"="cave_entrance"]',
    'node["natural"="peak"]',
    'node["natural"="viewpoint"]',
    'node["natural"="rock"]',
    'node["natural"="spring"]',
    'node["natural"="volcano"]',
    
    # TOURISM
    'node["tourism"="attraction"]',
    'node["tourism"="viewpoint"]',
    'node["tourism"="hotel"]',
    'node["tourism"="hostel"]',
    'node["tourism"="guest_house"]',
    'node["tourism"="museum"]',
    'node["tourism"="information"]',
    'node["tourism"="camp_site"]',
    'node["tourism"="picnic_site"]',
    
    # HISTORIC
    'node["historic"="castle"]',
    'node["historic"="ruins"]',
    'node["historic"="church"]',
    'node["historic"="monument"]',
    'node["historic"="memorial"]',
    'node["historic"="archaeological_site"]',
    
    # AMENITIES
    'node["amenity"="restaurant"]',
    'node["amenity"="cafe"]',
    'node["amenity"="fast_food"]',
    'node["amenity"="bar"]',
    'node["amenity"="pub"]',
    'node["amenity"="parking"]',
    'node["amenity"="toilets"]',
    'node["amenity"="fuel"]',
    
    # LEISURE
    'node["leisure"="park"]',
    'node["leisure"="nature_reserve"]',
    'node["leisure"="swimming_pool"]',
]


def fetch_places_by_query(query_type):
    """Fetch places from OSM for specific query."""
    query = f"[out:json][timeout:180];{query_type}{ICELAND_BBOX};out body;"
    
    try:
        print(f"🔍 Fetching: {query_type}")
        response = requests.post(OVERPASS_API, data=query, timeout=180)
        response.raise_for_status()
        data = response.json()
        
        elements = data.get("elements", [])
        print(f"   ✅ Found {len(elements)} places")
        return elements
        
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return []


def process_element(element):
    """Convert OSM element to our POI format."""
    tags = element.get("tags", {})
    
    # Skip if no name
    if "name" not in tags:
        return None
    
    # Determine category
    category = "unknown"
    if "natural" in tags:
        category = tags["natural"]
    elif "tourism" in tags:
        category = tags["tourism"]
    elif "historic" in tags:
        category = tags["historic"]
    elif "amenity" in tags:
        category = tags["amenity"]
    elif "leisure" in tags:
        category = tags["leisure"]
    
    return {
        "id": f"osm_{element.get('id')}",
        "name": tags.get("name"),
        "name_en": tags.get("name:en"),
        "category": category,
        "lat": element.get("lat"),
        "lng": element.get("lon"),
        "latitude": element.get("lat"),
        "longitude": element.get("lon"),
        "country": "IS",
        "tags": tags,
        "osm_id": element.get("id"),
        "osm_type": element.get("type"),
        "fetched_at": datetime.now().isoformat(),
    }


def fetch_all_places():
    """Main function to fetch all places."""
    print("🇮🇸 FETCHING ALL PLACES IN ICELAND")
    print("=" * 60)
    print(f"Bounding box: {ICELAND_BBOX}")
    print(f"Queries: {len(QUERIES)}")
    print("=" * 60)
    print()
    
    all_places = []
    seen_ids = set()
    
    for i, query_type in enumerate(QUERIES, 1):
        print(f"[{i}/{len(QUERIES)}] {query_type}")
        
        elements = fetch_places_by_query(query_type)
        
        for element in elements:
            poi = process_element(element)
            
            if poi and poi["id"] not in seen_ids:
                all_places.append(poi)
                seen_ids.add(poi["id"])
        
        # Rate limiting - be nice to OSM servers
        time.sleep(2)
        print()
    
    # Save to file
    output_file = "data/iceland_places_raw.json"
    print(f"💾 Saving to {output_file}")
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(all_places, f, indent=2, ensure_ascii=False)
    
    # Statistics
    print()
    print("=" * 60)
    print("📊 STATISTICS")
    print("=" * 60)
    print(f"Total places: {len(all_places)}")
    
    # Count by category
    categories = {}
    for place in all_places:
        cat = place["category"]
        categories[cat] = categories.get(cat, 0) + 1
    
    print("\nBy category:")
    for cat, count in sorted(categories.items(), key=lambda x: -x[1])[:20]:
        print(f"  {cat}: {count}")
    
    print("=" * 60)
    print("✅ ALL PLACES FETCHED!")
    print(f"📂 Saved to: {output_file}")
    print()
    
    return all_places


if __name__ == "__main__":
    fetch_all_places()
