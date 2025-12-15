#!/usr/bin/env python3
"""
ENRICH HIKING TRAILS
Bætir við lýsingum, myndum og öllum upplýsingum um hiking trails
"""

import json
import time
import requests
from pathlib import Path
from typing import Dict, List

# Famous Icelandic hiking trails
FAMOUS_TRAILS = {
    'Laugavegur': 'Laugavegur er eitt vinsælasta gönguleiðin á Íslandi, 55 km leið frá Landmannalaugum til Þórsmerkur í gegnum náttúrulega og fjölbreytta náttúru með litríkum fjöllum, laugum og jöklum.',
    'Fimmvörðuháls': 'Fimmvörðuháls er 25 km gönguleið milli Skógafoss og Þórsmerkur yfir hálendiðvið Eyjafjallajökul með glæsilegu útsýni.',
    'Hornstrandir': 'Hornstrandir er friðland í Vestfjörðum með ósnertri náttúru, fuglalífi og landslagi sem býður upp á fjölbreyttar gönguleiðir.',
    'Askja': 'Gönguleiðir við Öskjuvatn og Víti, bláa lónið í miðju hálendisjökla.',
    'Landmannalaugar': 'Fjölbreyttar gönguleiðir um litríkt hálendi með heitum laugum og hraunlandslagí.',
    'Þórsmörk': 'Þórsmörk býður upp á margar gönguleiðir í fallegum dal milli jökla með ótrúlegu útsýni.',
    'Glymur': 'Glymur er næsthæsti foss á Íslandi (198m) með stórkostlegri gönguleið að fossinum.',
    'Reykjadalur': 'Reykjadalur er vinsæl gönguleið með heitri á sem hægt er að baða sig í.',
    'Hverfjall': 'Hverfjall er gígargarður við Mývatn með auðveldri gönguleið upp í gíginn.',
    'Dettifoss': 'Gönguleiðir að Dettifossi, öflugasta fossi Evrópu.',
}

def get_trail_description(trail_name: str) -> str:
    """Sækir eða býr til lýsingu á gönguleið"""
    
    # Check if it's a famous trail
    for famous_name, desc in FAMOUS_TRAILS.items():
        if famous_name.lower() in trail_name.lower():
            return desc
    
    # Generic descriptions based on difficulty
    return ''

def enrich_trail(trail: Dict) -> Dict:
    """Enrichar gönguleið"""
    name = trail.get('name', 'Unknown Trail')
    difficulty = trail.get('difficulty', 'moderate')
    distance = trail.get('distance_km', 0)
    duration = trail.get('duration_hours', 0)
    elevation = trail.get('elevation_gain_m', 0)
    
    # Get or generate description
    description = get_trail_description(name)
    
    if not description:
        # Generate based on stats
        if difficulty == 'easy':
            description = f'{name} er auðveld gönguleið sem hentar öllum aldurshópum.'
        elif difficulty == 'moderate':
            description = f'{name} er miðlungs erfið gönguleið með fallegu útsýni yfir íslenska náttúru.'
        elif difficulty == 'challenging':
            description = f'{name} er krefjandi gönguleið fyrir reyndan göngumann með stórkostlegu útsýni.'
        else:
            description = f'{name} er erfiðþung gönguleið fyrir mjög reynda göngumenn.'
        
        # Add distance info
        if distance > 0:
            description += f' Leiðin er {distance:.1f} km að lengd'
            if duration > 0:
                description += f' og tekur um {duration:.1f} klukkustundir'
            description += '.'
    
    # Get coordinates
    start_lat = trail.get('start', {}).get('lat')
    start_lng = trail.get('start', {}).get('lng')
    
    # Build enriched trail data
    enriched = {
        'id': trail.get('id'),
        'name': name,
        'type': 'hiking',
        'category': 'hiking',
        'difficulty': difficulty,
        'distance_km': distance,
        'duration_hours': duration,
        'elevation_gain_m': elevation,
        'lat': start_lat,
        'lon': start_lng,
        'latitude': start_lat,
        'longitude': start_lng,
        'start': trail.get('start'),
        'end': trail.get('end'),
        'description': {
            'short': description[:200] if description else '',
            'full': description,
            'terrain': trail.get('surface', 'trail'),
            'highlights': ''
        },
        'trail_info': {
            'surface': trail.get('surface', 'trail'),
            'sac_scale': trail.get('sac_scale'),
            'trail_visibility': trail.get('trail_visibility'),
            'network': trail.get('network'),
            'region': trail.get('region', 'Iceland')
        },
        'media': {
            'images': [],
            'thumbnail': None,
            'hero_image': None
        },
        'rating': 4.2,
        'country': 'IS',
        'website': trail.get('website'),
        'operator': trail.get('operator')
    }
    
    return enriched

def select_best_trails(trails: List[Dict], max_count: int = 100) -> List[Dict]:
    """Velur bestu gönguleiðirnar"""
    
    # Filter out very short trails (< 1km)
    valid_trails = [t for t in trails if t.get('distance_km', 0) >= 1]
    
    # Sort by distance (prefer medium length trails)
    def trail_score(trail):
        distance = trail.get('distance_km', 0)
        # Prefer trails between 5-20km
        if 5 <= distance <= 20:
            return distance * 2
        elif 2 <= distance < 5:
            return distance
        elif 20 < distance <= 50:
            return distance * 0.8
        else:
            return distance * 0.3
    
    sorted_trails = sorted(valid_trails, key=trail_score, reverse=True)
    
    return sorted_trails[:max_count]

def main():
    print('🥾 HIKING TRAILS ENRICHMENT')
    print('=' * 60)
    
    # Load trails
    with open('data/iceland_trails.json', 'r', encoding='utf-8') as f:
        all_trails = json.load(f)
    
    print(f'📦 Loaded {len(all_trails)} trails from database')
    
    # Select best trails
    print(f'\n🎯 Selecting best trails...')
    selected_trails = select_best_trails(all_trails, max_count=100)
    
    print(f'✅ Selected {len(selected_trails)} trails to enrich')
    
    # Show difficulty breakdown
    from collections import Counter
    difficulty_counts = Counter(t.get('difficulty') for t in selected_trails)
    print(f'\n📊 Difficulty breakdown:')
    for diff, count in sorted(difficulty_counts.items(), key=lambda x: x[1], reverse=True):
        print(f'   {diff:20} {count:3}')
    
    # Enrich all selected trails
    print(f'\n🚀 Enriching trails...')
    enriched_trails = {}
    
    for i, trail in enumerate(selected_trails, 1):
        name = trail.get('name', 'Unknown')
        
        if i % 10 == 0:
            print(f'   {i}/{len(selected_trails)} - {name}')
        
        enriched = enrich_trail(trail)
        trail_id = enriched['id']
        enriched_trails[trail_id] = enriched
    
    # Save enriched trails
    output_file = Path('data/firestore_trails_enriched.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(enriched_trails, f, indent=2, ensure_ascii=False)
    
    print(f'\n✅ SUCCESS!')
    print(f'💾 Saved to: {output_file}')
    print(f'📦 Total enriched trails: {len(enriched_trails)}')
    print(f'\n🔥 Ready to upload to Firebase!')

if __name__ == '__main__':
    main()
