#!/usr/bin/env python3
"""
COMPLETE ENRICHMENT - Öll gögn með lýsingum
Enrichar alla staði með Wikipedia descriptions, images og history
"""

import json
import time
import requests
from pathlib import Path
from typing import Dict, Optional, List

def get_wikipedia_info(place_name: str, category: str = None) -> Dict:
    """Sækir Wikipedia upplýsingar"""
    try:
        # Clean name for Wikipedia
        wiki_name = place_name.replace(' ', '_')
        
        # Try Icelandic first
        url = f"https://is.wikipedia.org/api/rest_v1/page/summary/{wiki_name}"
        response = requests.get(url, timeout=5, headers={'User-Agent': 'GoIceland/1.0'})
        
        if response.status_code == 200:
            data = response.json()
            return {
                'description': data.get('extract', ''),
                'thumbnail': data.get('thumbnail', {}).get('source'),
                'image': data.get('originalimage', {}).get('source'),
                'wikipedia_url': data.get('content_urls', {}).get('desktop', {}).get('page')
            }
        elif response.status_code == 404:
            # Try English
            url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{wiki_name}"
            response = requests.get(url, timeout=5, headers={'User-Agent': 'GoIceland/1.0'})
            if response.status_code == 200:
                data = response.json()
                return {
                    'description': data.get('extract', ''),
                    'thumbnail': data.get('thumbnail', {}).get('source'),
                    'image': data.get('originalimage', {}).get('source'),
                    'wikipedia_url': data.get('content_urls', {}).get('desktop', {}).get('page')
                }
    except Exception as e:
        pass
    
    return {}

def get_default_description(category: str, name: str) -> str:
    """Generate default descriptions based on category"""
    descriptions = {
        'restaurant': f'{name} er veitingastaður á Íslandi sem býður upp á hefðbundinn mat og góða þjónustu.',
        'cafe': f'{name} er kaffihús á Íslandi með góðan kaffibolla og notalegt andrúmsloft.',
        'hotel': f'{name} er hótel á Íslandi með þægilegum herbergjum og góðri þjónustu.',
        'hostel': f'{name} er farfuglaheimili á Íslandi með góðu aðstöðu fyrir ferðamenn.',
        'viewpoint': f'{name} er útsýnisstaður með glæsilegu útsýni yfir íslenska náttúru.',
        'museum': f'{name} er safn á Íslandi með áhugaverðar sýningar um sögu og menningu.',
        'landmark': f'{name} er kennileiti á Íslandi og vinsæll ferðamannastaður.',
        'volcano': f'{name} er eldfjall á Íslandi, hluti af eldvirkum landslaginu.',
        'peak': f'{name} er fjallstindur á Íslandi, vinsæll áfangastaður hjá göngugarfólki.',
        'hot_spring': f'{name} er heitur uppspretta á Íslandi, hluti af jarðhitasvæði landsins.',
        'cave': f'{name} er hellir á Íslandi með einstaka jarðmyndanir.',
        'beach': f'{name} er strönd á Íslandi með fallegum útsýni.',
        'camping': f'{name} er tjaldstæði á Íslandi með góðri aðstöðu fyrir ferðamenn.',
    }
    return descriptions.get(category, f'{name} er áhugaverður staður á Íslandi.')

def enrich_place(place: Dict) -> Dict:
    """Enrichar einn stað"""
    name = place.get('name', 'Unknown')
    category = place.get('category', 'other')
    
    # Get Wikipedia info (with rate limiting)
    wiki_info = {}
    if category in ['viewpoint', 'landmark', 'volcano', 'peak', 'hot_spring', 'museum']:
        wiki_info = get_wikipedia_info(name, category)
        time.sleep(0.3)  # Be nice to Wikipedia
    
    # Build enriched data
    description = wiki_info.get('description', '') or get_default_description(category, name)
    
    enriched = {
        'id': place.get('id'),
        'name': name,
        'type': category,
        'category': category,
        'lat': place.get('lat'),
        'lon': place.get('lng'),
        'latitude': place.get('lat'),
        'longitude': place.get('lng'),
        'country': 'IS',
        'description': {
            'short': description[:200] if description else '',
            'history': description,
            'geology': '',
            'culture': ''
        },
        'media': {
            'images': [wiki_info.get('image')] if wiki_info.get('image') else [],
            'thumbnail': wiki_info.get('thumbnail'),
            'hero_image': wiki_info.get('image')
        },
        'rating': place.get('rating') or 4.0,
        'wikipedia_url': wiki_info.get('wikipedia_url'),
        'website': place.get('website'),
        'phone': place.get('phone'),
        'opening_hours': place.get('opening_hours'),
        'address': place.get('address'),
        'image': wiki_info.get('image'),
        'images': [wiki_info.get('image')] if wiki_info.get('image') else []
    }
    
    return enriched

def select_best_places(places: List[Dict]) -> List[Dict]:
    """Velur bestu staðina úr hverri category"""
    
    # Priority categories with target counts
    priorities = {
        'viewpoint': 50,
        'waterfall': 20,
        'restaurant': 30,
        'cafe': 20,
        'hotel': 25,
        'hostel': 15,
        'museum': 20,
        'landmark': 30,
        'volcano': 15,
        'peak': 25,
        'hot_spring': 20,
        'cave': 10,
        'beach': 5,
        'camping': 15,
        'info_center': 10,
    }
    
    selected = []
    
    for category, target_count in priorities.items():
        # Get places in this category
        category_places = [p for p in places if p.get('category') == category]
        
        # Sort by popularity and rating
        sorted_places = sorted(
            category_places,
            key=lambda x: (x.get('popularity', 0), x.get('rating') or 0),
            reverse=True
        )
        
        # Take top N
        selected.extend(sorted_places[:target_count])
    
    return selected

def main():
    print('🌟 COMPLETE ENRICHMENT PIPELINE')
    print('=' * 60)
    
    # Load all places
    with open('data/iceland_clean.json', 'r', encoding='utf-8') as f:
        all_places = json.load(f)
    
    print(f'📦 Loaded {len(all_places)} places from database')
    
    # Select best places
    print(f'\n🎯 Selecting best places from each category...')
    selected_places = select_best_places(all_places)
    
    print(f'✅ Selected {len(selected_places)} places to enrich')
    
    # Show category breakdown
    from collections import Counter
    category_counts = Counter(p.get('category') for p in selected_places)
    print(f'\n📊 Category breakdown:')
    for cat, count in sorted(category_counts.items(), key=lambda x: x[1], reverse=True):
        print(f'   {cat:20} {count:3}')
    
    # Enrich all selected places
    print(f'\n🚀 Enriching places...')
    enriched_places = {}
    
    for i, place in enumerate(selected_places, 1):
        name = place.get('name', 'Unknown')
        category = place.get('category', 'other')
        
        if i % 10 == 0:
            print(f'   {i}/{len(selected_places)} - {name} ({category})')
        
        enriched = enrich_place(place)
        place_id = enriched['id']
        enriched_places[place_id] = enriched
    
    # Save enriched data
    output_file = Path('data/firestore_complete_enriched.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(enriched_places, f, indent=2, ensure_ascii=False)
    
    print(f'\n✅ SUCCESS!')
    print(f'💾 Saved to: {output_file}')
    print(f'📦 Total enriched places: {len(enriched_places)}')
    print(f'\n🔥 Ready to upload to Firebase!')

if __name__ == '__main__':
    main()
