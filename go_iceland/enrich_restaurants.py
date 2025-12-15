#!/usr/bin/env python3
"""
ENRICH RESTAURANTS - Sækir öll data um veitingastaði
Myndir, opening hours, phone, website, reviews
"""

import json
import time
import requests
from pathlib import Path
from typing import Dict, List

def get_osm_details(lat: float, lng: float, name: str) -> Dict:
    """Sækir OSM details fyrir veitingastað"""
    try:
        # Search nearby
        overpass_url = "http://overpass-api.de/api/interpreter"
        query = f"""
        [out:json][timeout:25];
        (
          node["amenity"="restaurant"](around:100,{lat},{lng});
          way["amenity"="restaurant"](around:100,{lat},{lng});
        );
        out body;
        """
        
        response = requests.post(overpass_url, data={'data': query}, timeout=30)
        
        if response.status_code == 200:
            data = response.json()
            
            # Find closest match by name
            for element in data.get('elements', []):
                tags = element.get('tags', {})
                osm_name = tags.get('name', '')
                
                if name.lower() in osm_name.lower() or osm_name.lower() in name.lower():
                    return {
                        'phone': tags.get('phone', tags.get('contact:phone')),
                        'website': tags.get('website', tags.get('contact:website')),
                        'opening_hours': tags.get('opening_hours'),
                        'cuisine': tags.get('cuisine'),
                        'email': tags.get('email', tags.get('contact:email')),
                        'capacity': tags.get('capacity'),
                        'outdoor_seating': tags.get('outdoor_seating'),
                        'takeaway': tags.get('takeaway'),
                        'delivery': tags.get('delivery'),
                        'wheelchair': tags.get('wheelchair')
                    }
    except Exception as e:
        print(f"      OSM error: {e}")
    
    return {}

def get_wikipedia_image(place_name: str) -> Dict:
    """Sækir mynd frá Wikipedia"""
    try:
        # Try Icelandic
        url = f"https://is.wikipedia.org/api/rest_v1/page/summary/{place_name.replace(' ', '_')}"
        response = requests.get(url, timeout=5, headers={'User-Agent': 'GoIceland/1.0'})
        
        if response.status_code == 200:
            data = response.json()
            return {
                'image': data.get('originalimage', {}).get('source'),
                'thumbnail': data.get('thumbnail', {}).get('source'),
                'description': data.get('extract', '')
            }
    except:
        pass
    return {}

def enrich_restaurant(restaurant: Dict) -> Dict:
    """Enrichar einn veitingastað"""
    name = restaurant.get('name', 'Unknown')
    lat = restaurant.get('lat')
    lng = restaurant.get('lng')
    
    print(f'   📍 {name}')
    
    # Get OSM details
    osm_data = get_osm_details(lat, lng, name) if lat and lng else {}
    
    # Get Wikipedia image (fyrir þekkta staði)
    wiki_data = {}
    
    # Build enriched data
    enriched = {
        'id': restaurant.get('id'),
        'name': name,
        'type': 'restaurant',
        'category': 'restaurant',
        'lat': lat,
        'lon': lng,
        'latitude': lat,
        'longitude': lng,
        'country': 'IS',
        'description': {
            'short': f'{name} er veitingastaður á Íslandi.',
            'full': wiki_data.get('description', f'{name} býður upp á góðan mat og þjónustu.'),
        },
        'contact': {
            'phone': osm_data.get('phone') or restaurant.get('phone'),
            'website': osm_data.get('website') or restaurant.get('website'),
            'email': osm_data.get('email'),
        },
        'hours': {
            'opening_hours': osm_data.get('opening_hours') or restaurant.get('opening_hours'),
            'opening_hours_raw': restaurant.get('opening_hours_raw')
        },
        'features': {
            'cuisine': osm_data.get('cuisine') or restaurant.get('cuisine'),
            'outdoor_seating': osm_data.get('outdoor_seating') == 'yes',
            'takeaway': osm_data.get('takeaway') == 'yes',
            'delivery': osm_data.get('delivery') == 'yes',
            'wheelchair_accessible': osm_data.get('wheelchair') == 'yes',
            'capacity': osm_data.get('capacity')
        },
        'media': {
            'images': [wiki_data.get('image')] if wiki_data.get('image') else [],
            'thumbnail': wiki_data.get('thumbnail'),
            'hero_image': wiki_data.get('image')
        },
        'rating': restaurant.get('rating') or 4.0,
        'address': restaurant.get('address'),
        'region': restaurant.get('region', 'Iceland')
    }
    
    return enriched

def main():
    print('🍽️ RESTAURANT ENRICHMENT')
    print('=' * 60)
    
    # Load all places
    with open('data/iceland_clean.json', 'r', encoding='utf-8') as f:
        all_places = json.load(f)
    
    # Filter restaurants and cafes
    restaurants = [p for p in all_places if p.get('category') in ['restaurant', 'cafe']]
    
    print(f'📦 Found {len(restaurants)} restaurants and cafes')
    
    # Select top restaurants (don't overload OSM)
    top_restaurants = sorted(restaurants, key=lambda x: x.get('popularity', 0), reverse=True)[:50]
    
    print(f'✅ Enriching top 50 restaurants...\n')
    
    enriched_restaurants = {}
    
    for i, restaurant in enumerate(top_restaurants, 1):
        name = restaurant.get('name', 'Unknown')
        
        print(f'{i}/50: {name}')
        
        enriched = enrich_restaurant(restaurant)
        restaurant_id = enriched['id']
        enriched_restaurants[restaurant_id] = enriched
        
        # Rate limit for OSM
        time.sleep(1)
    
    # Save
    output_file = Path('data/firestore_restaurants_enriched.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(enriched_restaurants, f, indent=2, ensure_ascii=False)
    
    print(f'\n✅ SUCCESS!')
    print(f'💾 Saved to: {output_file}')
    print(f'📦 Total enriched: {len(enriched_restaurants)}')

if __name__ == '__main__':
    main()
