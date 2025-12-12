"""
GO ICELAND - OpenStreetMap POI Fetcher
Fetches 2000+ Points of Interest from Iceland using Overpass API

This script queries OpenStreetMap for all tourist-relevant locations in Iceland:
- Natural features (waterfalls, geysers, hot springs, beaches, cliffs, caves, peaks, lakes, glaciers)
- Tourism sites (viewpoints, attractions, museums, information centers, picnic sites)
- Historic sites (churches, monuments, ruins, archaeological sites)
- Geological features (fumaroles, lava fields, volcanic features)
- Hiking routes and trails
- Villages, towns, and settlements

Expected output: 2000-4500 POIs saved to iceland_pois_raw.json
"""

import requests
import json
from time import sleep
from datetime import datetime

OUTPUT_FILE = "iceland_pois_raw.json"
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Iceland bounding box: South lat, West lng, North lat, East lng
ICELAND_BBOX = "(63.0,-25.0,67.5,-12.0)"

# Comprehensive query categories for Iceland tourism
QUERIES = [
    # Natural features
    ('node["natural"="waterfall"]', 'waterfall'),
    ('node["natural"="geyser"]', 'geyser'),
    ('node["natural"="hot_spring"]', 'hot_spring'),
    ('node["natural"="spring"]', 'spring'),
    ('node["natural"="beach"]', 'beach'),
    ('node["natural"="cliff"]', 'cliff'),
    ('node["natural"="cave_entrance"]', 'cave'),
    ('node["natural"="peak"]', 'peak'),
    ('node["natural"="lake"]', 'lake'),
    ('node["natural"="glacier"]', 'glacier'),
    ('node["natural"="rock"]', 'rock_formation'),
    ('node["natural"="bay"]', 'bay'),
    ('node["natural"="volcano"]', 'volcano'),
    ('node["natural"="sinkhole"]', 'sinkhole'),
    ('way["natural"="beach"]', 'beach'),
    ('way["natural"="cliff"]', 'cliff'),
    
    # Tourism
    ('node["tourism"="viewpoint"]', 'viewpoint'),
    ('node["tourism"="attraction"]', 'attraction'),
    ('node["tourism"="artwork"]', 'artwork'),
    ('node["tourism"="information"]', 'information'),
    ('node["tourism"="picnic_site"]', 'picnic_site'),
    ('node["tourism"="museum"]', 'museum'),
    ('node["tourism"="camp_site"]', 'campsite'),
    ('node["tourism"="caravan_site"]', 'caravan_site'),
    ('node["tourism"="theme_park"]', 'theme_park'),
    ('node["tourism"="zoo"]', 'zoo'),
    
    # Historic
    ('node["historic"="ruins"]', 'ruins'),
    ('node["historic"="church"]', 'church'),
    ('node["historic"="monument"]', 'monument'),
    ('node["historic"="castle"]', 'castle'),
    ('node["historic"="memorial"]', 'memorial'),
    ('node["historic"="archaeological_site"]', 'archaeological_site'),
    ('way["historic"="ruins"]', 'ruins'),
    
    # Geological
    ('node["geological"="fumarole"]', 'fumarole'),
    ('node["geological"="hot_spring"]', 'hot_spring'),
    ('node["geological"="volcanic_lava_field"]', 'lava_field'),
    ('node["geological"="volcanic_caldera_rim"]', 'caldera'),
    
    # Places (villages, towns, islands)
    ('node["place"="hamlet"]', 'hamlet'),
    ('node["place"="village"]', 'village'),
    ('node["place"="town"]', 'town'),
    ('node["place"="island"]', 'island'),
    ('node["place"="locality"]', 'locality'),
    
    # Amenities
    ('node["amenity"="place_of_worship"]', 'church'),
    ('node["amenity"="parking"]["tourism"="yes"]', 'parking'),
    ('node["amenity"="shelter"]', 'shelter'),
    
    # Leisure
    ('node["leisure"="swimming_pool"]', 'swimming_pool'),
    ('node["leisure"="nature_reserve"]', 'nature_reserve'),
    ('node["leisure"="park"]', 'park'),
    
    # Man-made structures
    ('node["man_made"="lighthouse"]', 'lighthouse'),
    ('node["man_made"="bridge"]["bridge"="yes"]', 'bridge'),
    
    # Hiking routes (as ways)
    ('way["route"="hiking"]', 'hiking_route'),
    ('way["route"="foot"]', 'hiking_route'),
]

def run_query(query_string, category):
    """Execute a single Overpass API query"""
    query = f"[out:json][timeout:120];{query_string}{ICELAND_BBOX};out center;"
    
    print(f"🔍 Fetching {category:20s} → {query_string[:40]}...")
    
    try:
        response = requests.post(OVERPASS_URL, data={"data": query}, timeout=180)
        response.raise_for_status()
        data = response.json()
        
        elements = data.get("elements", [])
        print(f"   ✓ Found {len(elements)} items")
        
        return elements, category
    except requests.exceptions.Timeout:
        print(f"   ⚠️  Timeout on {category}")
        return [], category
    except Exception as e:
        print(f"   ❌ Error on {category}: {e}")
        return [], category

def extract_poi_data(element, category):
    """Extract and normalize POI data from OSM element"""
    tags = element.get("tags", {})
    
    # Get name (skip unnamed features unless they're significant)
    name = tags.get("name") or tags.get("name:en") or tags.get("name:is")
    
    # Get coordinates
    lat = element.get("lat")
    lng = element.get("lon")
    
    # For ways, use center point
    if not lat and "center" in element:
        lat = element["center"].get("lat")
        lng = element["center"].get("lon")
    
    if not lat or not lng:
        return None
    
    # Determine primary type
    primary_type = (
        tags.get("natural") or 
        tags.get("tourism") or 
        tags.get("historic") or 
        tags.get("geological") or
        tags.get("place") or
        tags.get("leisure") or
        tags.get("man_made") or
        category
    )
    
    # Extract additional metadata
    description = (
        tags.get("description") or 
        tags.get("description:en") or 
        tags.get("note")
    )
    
    wikipedia = tags.get("wikipedia") or tags.get("wikidata")
    website = tags.get("website") or tags.get("url")
    
    return {
        "osm_id": element.get("id"),
        "name": name,
        "lat": lat,
        "lng": lng,
        "type": primary_type,
        "category": category,
        "subtype": tags.get("tourism") or tags.get("historic"),
        "description": description,
        "wikipedia": wikipedia,
        "website": website,
        "tags": tags,
        "fetched_at": datetime.now().isoformat()
    }

def main():
    """Main execution function"""
    print("=" * 60)
    print("GO ICELAND - OSM POI Fetcher")
    print("=" * 60)
    print(f"Target: {len(QUERIES)} query categories")
    print(f"Bounding box: {ICELAND_BBOX}")
    print(f"Output: {OUTPUT_FILE}")
    print("=" * 60)
    print()
    
    all_pois = []
    category_counts = {}
    
    for query_string, category in QUERIES:
        elements, cat = run_query(query_string, category)
        
        count = 0
        for element in elements:
            poi_data = extract_poi_data(element, cat)
            if poi_data:
                all_pois.append(poi_data)
                count += 1
        
        category_counts[cat] = category_counts.get(cat, 0) + count
        
        # Rate limiting - be nice to Overpass API
        sleep(2)
    
    print()
    print("=" * 60)
    print("✅ FETCH COMPLETE")
    print("=" * 60)
    print(f"Total POIs collected: {len(all_pois)}")
    print()
    print("Category breakdown:")
    for cat, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
        print(f"  {cat:25s}: {count:4d}")
    print()
    
    # Save raw data
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(all_pois, f, indent=2, ensure_ascii=False)
    
    print(f"💾 Saved to {OUTPUT_FILE}")
    print()
    print("Next step: Run transform_pois_for_firestore.py")
    print("=" * 60)

if __name__ == "__main__":
    main()
