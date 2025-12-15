#!/usr/bin/env python3
"""
Enrichar og uploadar bestu staðina á Íslandi í Firebase
Handpicked listi af helstu ferðamannastöðum
"""

import json
import time
import requests
from pathlib import Path
from typing import Dict, Optional

# Bestu staðirnir á Íslandi (handpicked)
TOP_PLACES = [
    "Gullfoss", "Geysir", "Þingvellir", "Skógafoss", "Seljalandsfoss",
    "Jökulsárlón", "Reynisfjara", "Dettifoss", "Goðafoss", "Hallgrímskirkja",
    "Perlan", "Harpa", "Blue Lagoon", "Landmannalaugar", "Þórsmörk",
    "Mývatn", "Ásbyrgi", "Snæfellsjökull", "Dynjandi", "Kirkjufell",
    "Víti", "Askja", "Hverir", "Svartifoss", "Aldeyjarfoss",
    "Hjálparfoss", "Gljúfrabúi", "Fagradalsfjall", "Kerið", "Strokkur",
    "Þingvallavatn", "Eyjafjallajökull", "Vatnajökull", "Langjökull",
    "Hofsjökull", "Hekla", "Katla", "Askja", "Herðubreið",
    "Hvannadalshnjúkur", "Esjan", "Krafla", "Námafjall", "Hverfjall",
    "Grjótagjá", "Stóragjá", "Dimmuborgir", "Hljóðaklettar", "Hengifoss",
    "Litlanesfoss", "Fjaðrárgljúfur", "Látrabjarg", "Dyrhólaey",
    "Vík í Mýrdal", "Höfn", "Akureyri", "Ísafjörður", "Egilsstaðir",
    "Húsavík", "Seyðisfjörður", "Vestmannaeyjar", "Grindavík", "Borgarnes"
]

def load_places():
    """Hleður öllum stöðum"""
    with open('data/iceland_clean.json', 'r', encoding='utf-8') as f:
        return json.load(f)

def find_place(places, search_name):
    """Finnur stað eftir nafni"""
    search_lower = search_name.lower()
    
    # Exact match first
    for p in places:
        if p.get('name', '').lower() == search_lower:
            return p
    
    # Partial match
    for p in places:
        name = p.get('name', '').lower()
        if search_lower in name or name in search_lower:
            return p
    
    return None

def get_wikipedia_info(place_name):
    """Sækir Wikipedia upplýsingar"""
    try:
        url = f"https://is.wikipedia.org/api/rest_v1/page/summary/{place_name.replace(' ', '_')}"
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
            url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{place_name.replace(' ', '_')}"
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
        print(f"   ⚠️  Wikipedia error: {e}")
    
    return {}

def enrich_place(place, place_name):
    """Enrichar stað með Wikipedia gögnum"""
    wiki_info = get_wikipedia_info(place_name)
    
    enriched = {
        'id': place.get('id'),
        'name': place.get('name'),
        'type': place.get('category', 'attraction'),
        'category': place.get('category', 'attraction'),
        'lat': place.get('lat'),
        'lon': place.get('lng'),
        'latitude': place.get('lat'),
        'longitude': place.get('lng'),
        'country': 'IS',
        'description': {
            'short': wiki_info.get('description', '')[:200],
            'history': wiki_info.get('description', ''),
            'geology': '',
            'culture': ''
        },
        'media': {
            'images': [wiki_info.get('image')] if wiki_info.get('image') else [],
            'thumbnail': wiki_info.get('thumbnail'),
            'hero_image': wiki_info.get('image')
        },
        'rating': place.get('rating') or 4.5,
        'wikipedia_url': wiki_info.get('wikipedia_url'),
        'image': wiki_info.get('image'),
        'images': [wiki_info.get('image')] if wiki_info.get('image') else []
    }
    
    return enriched

def main():
    print('🌟 ENRICHING TOP ICELAND PLACES')
    print('=' * 60)
    
    places = load_places()
    enriched_places = {}
    
    found = 0
    not_found = []
    
    for place_name in TOP_PLACES:
        print(f'\n🔍 Searching: {place_name}')
        
        place = find_place(places, place_name)
        
        if place:
            found += 1
            print(f'   ✅ Found: {place.get("name")} ({place.get("category")})')
            print(f'   📡 Getting Wikipedia data...')
            
            enriched = enrich_place(place, place_name)
            place_id = enriched['id']
            enriched_places[place_id] = enriched
            
            if enriched.get('image'):
                print(f'   🖼️  Image found')
            
            time.sleep(0.5)  # Be nice to Wikipedia
        else:
            not_found.append(place_name)
            print(f'   ❌ Not found in database')
    
    print(f'\n\n📊 SUMMARY')
    print('=' * 60)
    print(f'✅ Found and enriched: {found}')
    print(f'❌ Not found: {len(not_found)}')
    
    if not_found:
        print(f'\nMissing places:')
        for p in not_found[:10]:
            print(f'  - {p}')
    
    # Save enriched places
    output_file = Path('data/firestore_top_places.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(enriched_places, f, indent=2, ensure_ascii=False)
    
    print(f'\n💾 Saved to: {output_file}')
    print(f'📦 Total places ready for Firebase: {len(enriched_places)}')

if __name__ == '__main__':
    main()
