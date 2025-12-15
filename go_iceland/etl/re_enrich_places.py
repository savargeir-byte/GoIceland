"""
Re-enrich all places with images and descriptions from Wikipedia/OSM
"""
import json
import requests
from time import sleep
import os

def get_wikipedia_data(place_name, lat, lon):
    """Get Wikipedia article and images for a place"""
    try:
        # Search for Wikipedia article near coordinates
        url = "https://en.wikipedia.org/w/api.php"
        params = {
            "action": "query",
            "list": "geosearch",
            "gscoord": f"{lat}|{lon}",
            "gsradius": 10000,  # 10km radius
            "gslimit": 5,
            "format": "json"
        }
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        pages = data.get("query", {}).get("geosearch", [])
        if not pages:
            return None, []
        
        # Get the first matching page
        page_id = pages[0]["pageid"]
        
        # Get page content and images
        params = {
            "action": "query",
            "pageids": page_id,
            "prop": "extracts|pageimages|images",
            "exintro": True,
            "explaintext": True,
            "pithumbsize": 800,
            "imlimit": 10,
            "format": "json"
        }
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        page_data = data.get("query", {}).get("pages", {}).get(str(page_id), {})
        
        description = page_data.get("extract", "")
        thumbnail = page_data.get("thumbnail", {}).get("source", "")
        
        # Get additional images
        images = []
        if thumbnail:
            images.append(thumbnail)
        
        return description, images
        
    except Exception as e:
        print(f"  ⚠️  Error getting Wikipedia data: {e}")
        return None, []

def get_osm_images(osm_id):
    """Get images from OpenStreetMap Wik idata"""
    try:
        # This would need proper OSM API integration
        # For now, return empty
        return []
    except:
        return []

def enrich_places():
    """Enrich all places with images and descriptions"""
    
    # Load places from Firestore download
    with open('data/iceland_places_master.json', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📊 Total places to enrich: {len(places)}")
    print(f"Starting enrichment...\n")
    
    enriched_count = 0
    
    for i, place in enumerate(places[:100]):  # Start with first 100
        name = place.get('name', 'Unknown')
        lat = place.get('latitude')
        lon = place.get('longitude')
        
        if not lat or not lon:
            continue
        
        print(f"{i+1}/{len(places)}: {name}")
        
        # Get Wikipedia data
        description, images = get_wikipedia_data(name, lat, lon)
        
        if description:
            place['content'] = {
                'en': {
                    'description': description,
                    'history': '',
                    'tips': ''
                }
            }
            print(f"  ✅ Added description ({len(description)} chars)")
        
        if images:
            place['images'] = images
            print(f"  ✅ Added {len(images)} images")
            enriched_count += 1
        
        # Rate limit
        sleep(0.5)
        
        if (i + 1) % 10 == 0:
            print(f"\n📈 Progress: {i+1}/{len(places)} ({enriched_count} enriched)\n")
    
    # Save enriched data
    output_file = 'data/iceland_places_enriched.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(places, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Enriched {enriched_count} places")
    print(f"💾 Saved to: {output_file}")

if __name__ == "__main__":
    enrich_places()
