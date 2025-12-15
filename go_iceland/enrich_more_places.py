import json
import requests
import time
from pathlib import Path

# Paths
DATA_DIR = Path(__file__).parent / 'data'
INPUT_FILE = DATA_DIR / 'iceland_clean.json'
ENRICHED_PLACES_FILE = DATA_DIR / 'firestore_top_places.json'
OUTPUT_FILE = DATA_DIR / 'all_enriched_places.json'

# Wikipedia API
WIKI_API = 'https://is.wikipedia.org/w/api.php'
WIKI_API_EN = 'https://en.wikipedia.org/w/api.php'


def get_wikipedia_info(name):
    """Fetch description and image from Wikipedia"""
    for api_url, lang in [(WIKI_API, 'is'), (WIKI_API_EN, 'en')]:
        try:
            # Search
            search_resp = requests.get(api_url, params={
                'action': 'query',
                'format': 'json',
                'list': 'search',
                'srsearch': name,
                'srlimit': 1
            }, timeout=10)
            search_data = search_resp.json()
            
            if not search_data.get('query', {}).get('search'):
                continue
            
            page_title = search_data['query']['search'][0]['title']
            
            # Get page info
            page_resp = requests.get(api_url, params={
                'action': 'query',
                'format': 'json',
                'prop': 'extracts|pageimages|info',
                'titles': page_title,
                'exintro': True,
                'explaintext': True,
                'piprop': 'original',
                'inprop': 'url'
            }, timeout=10)
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
                    'wikipedia_url': wiki_url
                }
        except:
            continue
    
    return None


def enrich_place(place):
    """Enrich a place with Wikipedia data"""
    name = place['name']
    lat = place['lat']
    lon = place.get('lon') or place.get('lng')
    
    enriched = {
        'id': place.get('id', f"{lat}{lon}".replace('.', '').replace('-', '')),
        'name': name,
        'type': place.get('category', 'unknown'),
        'category': place.get('category', 'unknown'),
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
        
        if wiki_info.get('image'):
            enriched['media'] = {
                'images': [wiki_info['image']],
                'hero_image': wiki_info['image'],
                'thumbnail': wiki_info['image']
            }
            enriched['images'] = [wiki_info['image']]
            enriched['image'] = wiki_info['image']
            return enriched, True  # Has image
        
        if wiki_info.get('wikipedia_url'):
            enriched['wikipedia_url'] = wiki_info['wikipedia_url']
    
    return enriched, False  # No image


def main():
    print('🌍 ENRICHING ALL MAJOR PLACES WITH WIKIPEDIA\n')
    
    # Load existing enriched places
    with open(ENRICHED_PLACES_FILE, 'r', encoding='utf-8') as f:
        existing_data = json.load(f)
    
    existing_places = list(existing_data.values())
    existing_ids = set(p['id'] for p in existing_places)
    print(f'📦 Already have {len(existing_places)} enriched places\n')
    
    # Load all places
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        all_places = json.load(f)
    
    # Target categories and counts
    targets = {
        'viewpoint': 30,
        'landmark': 30,
        'restaurant': 30,
        'cafe': 20,
        'hotel': 20,
        'museum': 20,
        'hot_spring': 15,
        'volcano': 10,
        'peak': 15,
        'cave': 10
    }
    
    # Group by category
    by_category = {}
    for place in all_places:
        cat = place.get('category', 'unknown')
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(place)
    
    # Enrich each category
    all_enriched = existing_places.copy()
    with_images_count = len([p for p in existing_places if p.get('images')])
    
    for category, target_count in targets.items():
        if category not in by_category:
            continue
        
        print(f'\n📂 {category.upper()} (target: {target_count})')
        places_in_cat = by_category[category]
        enriched_count = 0
        
        for place in places_in_cat:
            if enriched_count >= target_count:
                break
            
            place_id = place.get('id', f"{place['lat']}{place.get('lon') or place.get('lng')}".replace('.', '').replace('-', ''))
            if place_id in existing_ids:
                continue
            
            print(f'  {enriched_count+1}/{target_count}: {place["name"]}', end=' ')
            
            try:
                enriched, has_image = enrich_place(place)
                
                if has_image:
                    all_enriched.append(enriched)
                    existing_ids.add(place_id)
                    enriched_count += 1
                    with_images_count += 1
                    print('✓ (image)')
                else:
                    print('- (no image)')
                
                time.sleep(0.5)  # Rate limit
            except Exception as e:
                print(f'✗ ({e})')
                continue
    
    print(f'\n\n💾 Saving {len(all_enriched)} places...')
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(all_enriched, f, ensure_ascii=False, indent=2)
    
    print(f'\n✅ SUCCESS!')
    print(f'📊 Total places: {len(all_enriched)}')
    print(f'📸 With images: {with_images_count}')
    print(f'📄 Output: {OUTPUT_FILE}')


if __name__ == '__main__':
    main()
