"""
AUTOMATED BULK ENRICHMENT
Fetches images and generates descriptions for all 4,972 places automatically
"""
import json
import requests
from time import sleep
import os

# Pexels API (Free tier: 200 requests/hour)
PEXELS_API_KEY = "OZXF47aw2TXE6LjnSyBP5ALXhcDghSv1uQInbxCd6AOqlruSmhSfgJzX"

def get_pexels_image(query):
    """Get image from Pexels"""
    try:
        url = "https://api.pexels.com/v1/search"
        params = {
            "query": f"iceland {query}",
            "per_page": 3
        }
        headers = {"Authorization": PEXELS_API_KEY}
        
        response = requests.get(url, params=params, headers=headers, timeout=10)
        if response.status_code == 200:
            data = response.json()
            photos = data.get("photos", [])
            if photos:
                return [p["src"]["large"] for p in photos[:3]]
        return []
    except Exception as e:
        print(f"    ⚠️  Pexels error: {e}")
        return []

def get_wikipedia_description(place_name, lat, lon):
    """Get description from Wikipedia"""
    try:
        # Search for Wikipedia article near coordinates
        url = "https://en.wikipedia.org/w/api.php"
        params = {
            "action": "query",
            "list": "geosearch",
            "gscoord": f"{lat}|{lon}",
            "gsradius": 5000,
            "gslimit": 1,
            "format": "json"
        }
        
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        pages = data.get("query", {}).get("geosearch", [])
        if not pages:
            return None
        
        page_id = pages[0]["pageid"]
        
        # Get extract
        params = {
            "action": "query",
            "pageids": page_id,
            "prop": "extracts",
            "exintro": True,
            "explaintext": True,
            "format": "json"
        }
        
        response = requests.get(url, params=params, timeout=10)
        data = response.json()
        
        page = data.get("query", {}).get("pages", {}).get(str(page_id), {})
        extract = page.get("extract", "")
        
        if extract and len(extract) > 100:
            return extract
        return None
        
    except Exception as e:
        print(f"    ⚠️  Wikipedia error: {e}")
        return None

def generate_simple_description(name, category):
    """Generate a simple description when Wikipedia fails"""
    category_templates = {
        'waterfall': f"{name} is a stunning waterfall in Iceland, known for its powerful cascades and dramatic scenery. A must-visit destination for nature lovers.",
        'hot_spring': f"{name} is a natural hot spring in Iceland, offering warm geothermal waters surrounded by beautiful Icelandic landscapes.",
        'glacier': f"{name} is a magnificent glacier in Iceland, showcasing the raw power of nature with its massive ice formations.",
        'restaurant': f"{name} is a restaurant in Iceland, serving delicious local cuisine in a welcoming atmosphere.",
        'hotel': f"{name} is a hotel in Iceland, providing comfortable accommodations for travelers exploring the region.",
        'museum': f"{name} is a museum in Iceland, offering insights into the country's rich history and culture.",
        'hiking': f"{name} is a hiking trail in Iceland, offering spectacular views and an unforgettable outdoor experience.",
        'beach': f"{name} is a beach in Iceland, known for its unique coastal landscapes and natural beauty.",
        'cave': f"{name} is a cave in Iceland, featuring impressive geological formations and underground wonders.",
        'viewpoint': f"{name} is a viewpoint in Iceland, offering breathtaking panoramic views of the surrounding landscapes.",
    }
    
    template = category_templates.get(category, f"{name} is a notable location in Iceland worth visiting.")
    return template

def enrich_place(place, index, total):
    """Enrich a single place with images and description"""
    name = place.get('name', 'Unknown')
    category = place.get('category', 'other')
    lat = place.get('latitude')
    lon = place.get('longitude')
    
    print(f"\n[{index}/{total}] {name} ({category})")
    
    # Skip if already has content
    if place.get('images') and len(place.get('images', [])) >= 3 and place.get('content'):
        print("  ✅ Already enriched, skipping")
        return False
    
    enriched = False
    
    # Get images if missing
    if not place.get('images') or len(place.get('images', [])) < 3:
        print("  🖼️  Fetching images...")
        images = []
        
        # Use Pexels
        pexels_images = get_pexels_image(name)
        images.extend(pexels_images)
        sleep(2)  # Rate limit for Pexels: 200/hour = ~18 seconds between calls
        
        if images:
            place['images'] = images[:5]  # Take top 5
            print(f"  ✅ Added {len(place['images'])} images")
            enriched = True
        else:
            print("  ⚠️  No images found")
    
    # Get description if missing
    if not place.get('content'):
        print("  📝 Fetching description...")
        
        description = None
        if lat and lon:
            description = get_wikipedia_description(name, lat, lon)
            sleep(1)  # Rate limit
        
        if not description:
            description = generate_simple_description(name, category)
        
        place['content'] = {
            'en': {
                'description': description,
                'history': '',
                'tips': 'Visit during daylight hours for the best experience.'
            },
            'is': {
                'description': '',
                'history': '',
                'tips': ''
            },
            'zh': {
                'description': '',
                'history': '',
                'tips': ''
            }
        }
        print(f"  ✅ Added description ({len(description)} chars)")
        enriched = True
    
    return enriched

def main():
    print("="*80)
    print("🤖 AUTOMATED BULK ENRICHMENT")
    print("="*80)
    print()
    
    # Check API key
    if "YOUR_KEY" in PEXELS_API_KEY:
        print("⚠️  WARNING: Pexels API key not set!")
        print("   Get free key at: https://www.pexels.com/api/")
        print()
    else:
        print("✅ Pexels API key configured")
        print()
    
    # Load places
    input_file = 'go_iceland/data/iceland_places_master.json'
    
    if not os.path.exists(input_file):
        print(f"❌ File not found: {input_file}")
        return
    
    with open(input_file, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📊 Loaded {len(places)} places")
    print()
    print("Starting enrichment...")
    print("This will take ~2-3 hours for all places")
    print()
    
    enriched_count = 0
    
    for i, place in enumerate(places, 1):
        try:
            if enrich_place(place, i, len(places)):
                enriched_count += 1
            
            # Save progress every 50 places
            if i % 50 == 0:
                output_file = 'go_iceland/data/iceland_places_enriched.json'
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(places, f, indent=2, ensure_ascii=False)
                print(f"\n💾 Progress saved ({enriched_count} enriched so far)\n")
        
        except KeyboardInterrupt:
            print("\n\n⚠️  Interrupted by user")
            break
        except Exception as e:
            print(f"  ❌ Error: {e}")
            continue
    
    # Final save
    output_file = 'go_iceland/data/iceland_places_enriched.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(places, f, indent=2, ensure_ascii=False)
    
    print()
    print("="*80)
    print("✅ ENRICHMENT COMPLETE!")
    print("="*80)
    print()
    print(f"📊 SUMMARY:")
    print(f"   Total places: {len(places)}")
    print(f"   Enriched: {enriched_count}")
    print(f"   Output: {output_file}")
    print()
    print("Next step: Upload to Firestore")
    print("   cd go_iceland/firebase")
    print("   python upload_to_firestore.py")

if __name__ == "__main__":
    main()
