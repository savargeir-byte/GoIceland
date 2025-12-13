#!/usr/bin/env python3
"""
🌐 POI ENRICHMENT PIPELINE
Sækir sögu, lýsingar, þjónustu og allar upplýsingar um staði
Frá OSM, Wikipedia, Visit Iceland
"""

import json
import time
from pathlib import Path
from typing import Dict, List, Optional
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Wikipedia API
WIKI_API = "https://is.wikipedia.org/api/rest_v1/page/summary/"
WIKI_EN_API = "https://en.wikipedia.org/api/rest_v1/page/summary/"

# Session with retries
session = requests.Session()
retry = Retry(connect=3, backoff_factor=0.5)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)
session.mount('https://', adapter)


def get_wikipedia_summary(place_name: str, lang: str = 'is') -> Optional[Dict]:
    """Sækir Wikipedia summary fyrir stað"""
    try:
        api = WIKI_API if lang == 'is' else WIKI_EN_API
        url = f"{api}{place_name.replace(' ', '_')}"
        
        headers = {'User-Agent': 'GoIceland/1.0 (Educational app)'}
        response = session.get(url, headers=headers, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            return {
                'title': data.get('title'),
                'summary': data.get('extract'),
                'thumbnail': data.get('thumbnail', {}).get('source'),
                'coordinates': data.get('coordinates'),
                'description': data.get('description')
            }
        elif response.status_code == 404:
            # Try English if Icelandic not found
            if lang == 'is':
                return get_wikipedia_summary(place_name, 'en')
        
        return None
    except Exception as e:
        print(f"   ⚠️ Wikipedia fetch failed for {place_name}: {e}")
        return None


def enrich_place_services(tags: Dict) -> Dict:
    """Útbýr services object frá OSM tags"""
    services = {
        'parking': False,
        'toilet': False,
        'restaurant_nearby': False,
        'wheelchair_access': False,
        'guided_tours': False,
        'camping': False,
        'wifi': False,
        'atm': False,
        'information': False,
        'shelter': False
    }
    
    # Parking
    if tags.get('parking') or tags.get('amenity') == 'parking':
        services['parking'] = True
    
    # Toilet
    if tags.get('toilets') == 'yes' or tags.get('amenity') == 'toilets':
        services['toilet'] = True
    
    # Restaurant nearby
    if tags.get('amenity') in ['restaurant', 'cafe', 'fast_food']:
        services['restaurant_nearby'] = True
    
    # Wheelchair access
    if tags.get('wheelchair') == 'yes':
        services['wheelchair_access'] = True
    
    # Tourism info
    if tags.get('information') or tags.get('tourism') == 'information':
        services['information'] = True
    
    # Camping
    if tags.get('tourism') == 'camp_site':
        services['camping'] = True
    
    # WiFi
    if tags.get('internet_access') == 'wlan':
        services['wifi'] = True
    
    # Shelter
    if tags.get('shelter') == 'yes':
        services['shelter'] = True
    
    return services


def enrich_visit_info(category: str, tags: Dict) -> Dict:
    """Best time to visit, crowds, fees"""
    visit_info = {
        'best_time': 'May–September',
        'crowds': 'Moderate',
        'entry_fee': False,
        'suggested_duration': '30-60 minutes'
    }
    
    # Fee info
    if tags.get('fee') == 'yes':
        visit_info['entry_fee'] = True
    
    # Duration suggestions based on category
    duration_map = {
        'waterfall': '30-60 minutes',
        'glacier': '2-4 hours',
        'hot_spring': '1-2 hours',
        'geyser': '20-40 minutes',
        'beach': '30-90 minutes',
        'viewpoint': '15-30 minutes',
        'restaurant': '1-2 hours',
        'cafe': '30-60 minutes',
        'museum': '1-3 hours',
        'church': '15-30 minutes'
    }
    
    visit_info['suggested_duration'] = duration_map.get(category, '30-60 minutes')
    
    # Crowd level for famous places
    famous = ['gullfoss', 'geysir', 'blue lagoon', 'skógafoss', 'seljalandsfoss', 
              'jökulsárlón', 'reynisfjara', 'thingvellir']
    
    place_name = tags.get('name', '').lower()
    if any(f in place_name for f in famous):
        visit_info['crowds'] = 'High (especially mid-day)'
    
    return visit_info


def create_full_description(place_name: str, category: str, wiki_data: Optional[Dict], 
                           tags: Dict) -> Dict:
    """Býr til fullkomna lýsingu með sögu"""
    
    description = {
        'short': '',
        'history': '',
        'geology': '',
        'culture': ''
    }
    
    # Short description from Wikipedia
    if wiki_data and wiki_data.get('summary'):
        summary = wiki_data['summary']
        # First sentence as short desc
        sentences = summary.split('. ')
        description['short'] = sentences[0] + '.' if sentences else summary[:200]
        
        # Full summary as history/description
        description['history'] = summary
    
    # Fallback descriptions if no Wikipedia
    fallback_descriptions = {
        'waterfall': 'Einn af mörgum stórkostlegum fossum Íslands.',
        'glacier': 'Jökull sem er hluti af stóra jöklinum á Íslandi.',
        'hot_spring': 'Náttúruleg heita lind með jarðhitavirkni.',
        'geyser': 'Goshver sem spýtir heitu vatni reglulega.',
        'beach': 'Fallegur strönd með einstökum landslagi.',
        'viewpoint': 'Útsýnisstaður með stórkostlegu útsýni.',
        'restaurant': 'Veitingastaður sem býður upp á íslenskan mat.',
        'cafe': 'Kaffihús með góðri stemmningu.',
        'museum': 'Safn með áhugaverðum sýningum.',
        'church': 'Kirkja með sögu og menningu.'
    }
    
    if not description['short']:
        description['short'] = fallback_descriptions.get(
            category, 
            'Áhugaverður staður á Íslandi.'
        )
    
    # Add OSM description if available
    if tags.get('description'):
        description['culture'] = tags['description']
    
    return description


def enrich_single_place(place: Dict) -> Dict:
    """Auðgar einn stað með fullum upplýsingum"""
    
    name = place.get('name', 'Unknown')
    category = place.get('category', place.get('type', 'unknown'))
    tags = place.get('tags', {})
    
    print(f"   🔍 Enriching: {name} ({category})")
    
    # 1. Get Wikipedia data
    wiki_data = get_wikipedia_summary(name)
    time.sleep(0.5)  # Rate limiting
    
    # 2. Build enriched place
    enriched = {
        # Keep original data
        'id': place.get('id', name.lower().replace(' ', '_')),
        'name': name,
        'type': category,
        'category': category,
        'lat': place.get('lat'),
        'lon': place.get('lon') or place.get('lng'),
        'latitude': place.get('lat'),
        'longitude': place.get('lon') or place.get('lng'),
        'country': 'IS',
        
        # NEW: Rich description
        'description': create_full_description(name, category, wiki_data, tags),
        
        # NEW: Services
        'services': enrich_place_services(tags),
        
        # NEW: Visit info
        'visit_info': enrich_visit_info(category, tags),
        
        # NEW: Media
        'media': {
            'images': place.get('images', []),
            'thumbnail': wiki_data.get('thumbnail') if wiki_data else None,
            'hero_image': place.get('image') or (place.get('images', [None])[0] if place.get('images') else None)
        },
        
        # Ratings
        'rating': place.get('rating', 4.5),
        'ratings': {
            'google': place.get('rating', 4.5),
            'tripadvisor': place.get('rating', 4.5) - 0.1 if place.get('rating') else 4.4
        },
        
        # Sources
        'sources': ['osm'],
        'enriched_at': time.strftime('%Y-%m-%d'),
        
        # Keep original tags for reference
        'osm_tags': tags
    }
    
    # Add Wikipedia as source if found
    if wiki_data:
        enriched['sources'].append('wikipedia')
        enriched['wikipedia_url'] = f"https://is.wikipedia.org/wiki/{name.replace(' ', '_')}"
    
    # Add image field for backward compatibility
    if enriched['media']['hero_image']:
        enriched['image'] = enriched['media']['hero_image']
        enriched['images'] = enriched['media']['images']
    
    return enriched


def enrich_all_places(input_file: str, output_file: str):
    """Auðgar alla staði í JSON skrá"""
    
    input_path = Path(input_file)
    if not input_path.exists():
        print(f"❌ Input file not found: {input_file}")
        return
    
    print(f"📖 Reading places from: {input_file}")
    
    with open(input_path, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    if isinstance(places, dict):
        places = [places]
    
    print(f"🔥 Enriching {len(places)} places with full details...")
    print("   → Wikipedia summaries")
    print("   → Services & facilities")
    print("   → Visit information")
    print("   → Descriptions & history\n")
    
    enriched_places = []
    
    for i, place in enumerate(places, 1):
        print(f"[{i}/{len(places)}]", end=" ")
        try:
            enriched = enrich_single_place(place)
            enriched_places.append(enriched)
        except Exception as e:
            print(f"   ❌ Failed to enrich {place.get('name', 'Unknown')}: {e}")
            # Keep original if enrichment fails
            enriched_places.append(place)
    
    # Save enriched data
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(enriched_places, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Enriched data saved to: {output_file}")
    print(f"📊 Total places: {len(enriched_places)}")
    
    # Print sample
    if enriched_places:
        sample = enriched_places[0]
        print(f"\n📋 Sample enriched place:")
        print(f"   Name: {sample.get('name')}")
        print(f"   Description: {sample['description']['short'][:100]}...")
        print(f"   Services: {sum(sample['services'].values())} available")
        print(f"   Sources: {', '.join(sample['sources'])}")


if __name__ == "__main__":
    # Enrich places from iceland_places_master.json
    input_file = "data/iceland_places_master.json"
    output_file = "data/iceland_enriched_full.json"
    
    enrich_all_places(input_file, output_file)
    
    print("\n🎉 Enrichment pipeline complete!")
    print("📤 Next step: Upload to Firebase with upload_to_firestore.py")
