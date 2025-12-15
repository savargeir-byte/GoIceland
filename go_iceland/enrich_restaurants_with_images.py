import json
import requests
import time
import os
from pathlib import Path

# Paths
DATA_DIR = Path(__file__).parent / 'data'
INPUT_FILE = DATA_DIR / 'iceland_clean.json'
OUTPUT_FILE = DATA_DIR / 'restaurants_enriched.json'
CHECKPOINT_FILE = DATA_DIR / 'restaurants_checkpoint.json'

# Wikipedia API
WIKI_API = 'https://is.wikipedia.org/w/api.php'
WIKI_API_EN = 'https://en.wikipedia.org/w/api.php'

# OSM Overpass API
OVERPASS_API = 'https://overpass-api.de/api/interpreter'


def get_wikipedia_info(name):
    """Fetch description and image from Wikipedia (Icelandic first, then English)"""
    for api_url, lang in [(WIKI_API, 'is'), (WIKI_API_EN, 'en')]:
        try:
            # Search for article
            search_params = {
                'action': 'query',
                'format': 'json',
                'list': 'search',
                'srsearch': name,
                'srlimit': 1
            }
            search_resp = requests.get(api_url, params=search_params, timeout=10)
            search_data = search_resp.json()
            
            if not search_data.get('query', {}).get('search'):
                continue
            
            page_title = search_data['query']['search'][0]['title']
            
            # Get page info
            page_params = {
                'action': 'query',
                'format': 'json',
                'prop': 'extracts|pageimages|info',
                'titles': page_title,
                'exintro': True,
                'explaintext': True,
                'piprop': 'original',
                'inprop': 'url'
            }
            page_resp = requests.get(api_url, params=page_params, timeout=10)
            page_data = page_resp.json()
            
            pages = page_data.get('query', {}).get('pages', {})
            if not pages:
                continue
            
            page = list(pages.values())[0]
            
            extract = page.get('extract', '').strip()
            image_url = page.get('original', {}).get('source')
            wiki_url = page.get('fullurl')
            
            if extract or image_url:
                return {
                    'description': extract if extract else None,
                    'image': image_url,
                    'wikipedia_url': wiki_url,
                    'language': lang
                }
        except Exception as e:
            print(f"      ⚠️ Wikipedia {lang} error: {e}")
            continue
    
    return None


def get_osm_details(lat, lon, name):
    """Fetch opening hours, phone, website, etc from OSM"""
    query = f"""
    [out:json][timeout:10];
    (
      node["amenity"="restaurant"](around:100,{lat},{lon});
      way["amenity"="restaurant"](around:100,{lat},{lon});
      node["amenity"="cafe"](around:100,{lat},{lon});
      way["amenity"="cafe"](around:100,{lat},{lon});
    );
    out body;
    """
    
    try:
        response = requests.post(OVERPASS_API, data={'data': query}, timeout=15)
        data = response.json()
        
        # Find best match
        for element in data.get('elements', []):
            tags = element.get('tags', {})
            osm_name = tags.get('name', '').lower()
            
            if name.lower() in osm_name or osm_name in name.lower():
                return {
                    'phone': tags.get('phone') or tags.get('contact:phone'),
                    'website': tags.get('website') or tags.get('contact:website'),
                    'opening_hours': tags.get('opening_hours'),
                    'cuisine': tags.get('cuisine'),
                    'email': tags.get('email') or tags.get('contact:email'),
                    'capacity': tags.get('capacity'),
                    'outdoor_seating': tags.get('outdoor_seating') == 'yes',
                    'takeaway': tags.get('takeaway') == 'yes',
                    'delivery': tags.get('delivery') == 'yes',
                    'wheelchair': tags.get('wheelchair') == 'yes'
                }
        
        return {}
    except Exception as e:
        print(f"      ⚠️ OSM error: {e}")
        return {}


def enrich_restaurant(restaurant):
    """Enrich a single restaurant with Wikipedia and OSM data"""
    name = restaurant['name']
    lat = restaurant['lat']
    lon = restaurant.get('lon') or restaurant.get('lng')
    
    print(f"\n   📍 {name}")
    
    enriched = {
        'id': restaurant.get('id', f"{lat}{lon}".replace('.', '').replace('-', '')),
        'name': name,
        'type': 'restaurant',
        'category': restaurant.get('category', 'restaurant'),
        'lat': lat,
        'lon': lon,
        'lng': lon,
        'latitude': lat,
        'longitude': lon,
        'country': 'IS'
    }
    
    # Get Wikipedia info
    wiki_info = get_wikipedia_info(name)
    if wiki_info:
        if wiki_info.get('description'):
            enriched['description'] = {
                'short': wiki_info['description'][:300] + '...' if len(wiki_info['description']) > 300 else wiki_info['description'],
                'history': wiki_info['description']
            }
            print(f"      ✓ Description from Wikipedia ({wiki_info.get('language', 'is')})")
        
        if wiki_info.get('image'):
            enriched['media'] = {
                'images': [wiki_info['image']],
                'hero_image': wiki_info['image'],
                'thumbnail': wiki_info['image']
            }
            enriched['images'] = [wiki_info['image']]
            enriched['image'] = wiki_info['image']
            print(f"      ✓ Image from Wikipedia")
        
        if wiki_info.get('wikipedia_url'):
            enriched['wikipedia_url'] = wiki_info['wikipedia_url']
    
    # Get OSM details
    time.sleep(1)  # Rate limit
    osm_info = get_osm_details(lat, lon, name)
    if osm_info:
        enriched['meta'] = osm_info
        if osm_info.get('opening_hours'):
            print(f"      ✓ Opening hours: {osm_info['opening_hours']}")
        if osm_info.get('phone'):
            print(f"      ✓ Phone: {osm_info['phone']}")
        if osm_info.get('website'):
            print(f"      ✓ Website: {osm_info['website']}")
    
    # Copy existing rating if available
    if restaurant.get('rating'):
        enriched['rating'] = restaurant['rating']
    
    return enriched


def main():
    print('🍽️ RESTAURANT ENRICHMENT WITH IMAGES\n')
    
    # Load data
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    # Filter restaurants
    restaurants = [p for p in places if p.get('category') == 'restaurant']
    print(f'📦 Found {len(restaurants)} restaurants\n')
    
    # Load checkpoint if exists
    processed_ids = set()
    enriched_restaurants = []
    
    if CHECKPOINT_FILE.exists():
        with open(CHECKPOINT_FILE, 'r', encoding='utf-8') as f:
            checkpoint_data = json.load(f)
            enriched_restaurants = checkpoint_data.get('restaurants', [])
            processed_ids = set(checkpoint_data.get('processed_ids', []))
        print(f'📌 Resuming from checkpoint: {len(enriched_restaurants)} already processed\n')
    
    # Process restaurants
    target_count = 100  # Process 100 restaurants
    for i, restaurant in enumerate(restaurants, 1):
        if len(enriched_restaurants) >= target_count:
            break
        
        # Get coordinates first
        lat = restaurant['lat']
        lon = restaurant.get('lon') or restaurant.get('lng')
        restaurant_id = restaurant.get('id', f"{lat}{lon}".replace('.', '').replace('-', ''))
        
        if restaurant_id in processed_ids:
            continue
        
        # Get coordinates
        lat = restaurant['lat']
        lon = restaurant.get('lon') or restaurant.get('lng')
        
        print(f'{i}/{len(restaurants)}: {restaurant["name"]}')
        
        try:
            enriched = enrich_restaurant(restaurant)
            enriched_restaurants.append(enriched)
            processed_ids.add(restaurant_id)
            
            # Save checkpoint every 10 restaurants
            if len(enriched_restaurants) % 10 == 0:
                checkpoint_data = {
                    'restaurants': enriched_restaurants,
                    'processed_ids': list(processed_ids)
                }
                with open(CHECKPOINT_FILE, 'w', encoding='utf-8') as f:
                    json.dump(checkpoint_data, f, ensure_ascii=False, indent=2)
                print(f'\n   💾 Checkpoint saved: {len(enriched_restaurants)} restaurants\n')
        
        except Exception as e:
            print(f'   ❌ Error: {e}')
            continue
    
    # Save final output
    print(f'\n💾 Saving {len(enriched_restaurants)} enriched restaurants...')
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(enriched_restaurants, f, ensure_ascii=False, indent=2)
    
    print(f'\n✅ SUCCESS!')
    print(f'📊 Enriched {len(enriched_restaurants)} restaurants')
    print(f'📄 Output: {OUTPUT_FILE}')
    
    # Clean up checkpoint
    if CHECKPOINT_FILE.exists():
        CHECKPOINT_FILE.unlink()


if __name__ == '__main__':
    main()
