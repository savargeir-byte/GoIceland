#!/usr/bin/env python3
"""
🥾 ICELAND TRAILS FETCHER
Sækir ALLAR gönguleiðir á Íslandi frá OSM + reiknar stats
"""

import json
import math
import time
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import requests
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

# Overpass API endpoint
OVERPASS_URL = "https://overpass-api.de/api/interpreter"

# Iceland bounding box
ICELAND_BBOX = "63.0,-25.0,67.5,-12.0"  # south,west,north,east

# Session with retries
session = requests.Session()
retry = Retry(connect=3, backoff_factor=1.0)
adapter = HTTPAdapter(max_retries=retry)
session.mount('http://', adapter)
session.mount('https://', adapter)


def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """Calculate distance between two points in km"""
    R = 6371  # Earth radius in km
    
    lat1_rad = math.radians(lat1)
    lat2_rad = math.radians(lat2)
    delta_lat = math.radians(lat2 - lat1)
    delta_lon = math.radians(lon2 - lon1)
    
    a = (math.sin(delta_lat / 2) ** 2 +
         math.cos(lat1_rad) * math.cos(lat2_rad) *
         math.sin(delta_lon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    
    return R * c


def calculate_trail_stats(points: List[Tuple[float, float]]) -> Dict:
    """Calculate distance, elevation gain, duration from points"""
    
    if len(points) < 2:
        return {
            'distance_km': 0,
            'elevation_gain_m': 0,
            'duration_hours': 0
        }
    
    # Calculate distance
    total_distance = 0
    for i in range(len(points) - 1):
        lat1, lon1 = points[i]
        lat2, lon2 = points[i + 1]
        total_distance += haversine_distance(lat1, lon1, lat2, lon2)
    
    # Estimate duration (Naismith's rule: 5km/h + 1h per 600m elevation)
    # For now, simple estimate: 4km/h average
    duration_hours = total_distance / 4.0
    
    return {
        'distance_km': round(total_distance, 2),
        'elevation_gain_m': 0,  # Need GPX with elevation data
        'duration_hours': round(duration_hours, 1)
    }


def determine_difficulty(distance_km: float, elevation_gain: int) -> str:
    """Determine trail difficulty"""
    
    if distance_km < 5 and elevation_gain < 300:
        return "easy"
    elif distance_km < 15 and elevation_gain < 800:
        return "moderate"
    elif distance_km < 25 and elevation_gain < 1500:
        return "challenging"
    else:
        return "expert"


def fetch_iceland_trails() -> List[Dict]:
    """Fetch all hiking trails from OSM"""
    
    print("🥾 Fetching hiking trails from OpenStreetMap...")
    print(f"   Bounding box: {ICELAND_BBOX}")
    
    # Overpass QL query for hiking routes
    query = f"""
    [out:json][timeout:60];
    (
      // Hiking routes
      relation["route"="hiking"]({ICELAND_BBOX});
      
      // Marked hiking paths
      way["highway"="path"]["sac_scale"]({ICELAND_BBOX});
      way["highway"="path"]["trail_visibility"]({ICELAND_BBOX});
      
      // Named trails
      way["highway"="path"]["name"]({ICELAND_BBOX});
    );
    out geom;
    """
    
    try:
        response = session.post(
            OVERPASS_URL,
            data={'data': query},
            timeout=90
        )
        
        if response.status_code != 200:
            print(f"❌ Overpass API error: {response.status_code}")
            return []
        
        data = response.json()
        elements = data.get('elements', [])
        
        print(f"✅ Found {len(elements)} trail elements")
        return elements
        
    except Exception as e:
        print(f"❌ Error fetching trails: {e}")
        return []


def process_trail_relation(relation: Dict) -> Optional[Dict]:
    """Process OSM relation into trail object"""
    
    tags = relation.get('tags', {})
    name = tags.get('name', 'Unnamed Trail')
    
    # Get members (ways that make up the route)
    members = relation.get('members', [])
    
    # Extract points from geometry
    points = []
    for member in members:
        if member.get('type') == 'way' and 'geometry' in member:
            geometry = member['geometry']
            for point in geometry:
                points.append((point['lat'], point['lon']))
    
    if len(points) < 2:
        return None
    
    # Calculate stats
    stats = calculate_trail_stats(points)
    
    # Determine difficulty
    difficulty = determine_difficulty(stats['distance_km'], stats['elevation_gain_m'])
    
    # Build trail object
    trail = {
        'id': f"trail_{relation['id']}",
        'name': name,
        'type': 'hiking',
        'osm_id': relation['id'],
        
        # Stats
        'distance_km': stats['distance_km'],
        'duration_hours': stats['duration_hours'],
        'elevation_gain_m': stats['elevation_gain_m'],
        'difficulty': difficulty,
        
        # Location
        'start': {
            'lat': points[0][0],
            'lng': points[0][1],
            'name': tags.get('from', 'Start')
        },
        'end': {
            'lat': points[-1][0],
            'lng': points[-1][1],
            'name': tags.get('to', 'End')
        },
        
        # Polyline (simplified - keep every 10th point for Firebase)
        'polyline': points[::10] if len(points) > 100 else points,
        'polyline_full_available': len(points) > 100,
        
        # Metadata
        'surface': tags.get('surface', tags.get('highway', 'trail')),
        'sac_scale': tags.get('sac_scale'),
        'trail_visibility': tags.get('trail_visibility'),
        'network': tags.get('network'),  # lwn, rwn, nwn
        
        # Additional info
        'description': tags.get('description', ''),
        'website': tags.get('website'),
        'operator': tags.get('operator'),
        
        # Sources
        'sources': ['osm'],
        'osm_type': 'relation'
    }
    
    # Region detection
    trail['region'] = detect_region(points[0][0], points[0][1])
    
    return trail


def process_trail_way(way: Dict) -> Optional[Dict]:
    """Process OSM way into trail object"""
    
    tags = way.get('tags', {})
    name = tags.get('name')
    
    if not name:
        return None  # Skip unnamed paths
    
    # Get geometry
    geometry = way.get('geometry', [])
    if len(geometry) < 2:
        return None
    
    points = [(p['lat'], p['lon']) for p in geometry]
    
    # Calculate stats
    stats = calculate_trail_stats(points)
    
    # Skip very short trails
    if stats['distance_km'] < 0.5:
        return None
    
    difficulty = determine_difficulty(stats['distance_km'], stats['elevation_gain_m'])
    
    trail = {
        'id': f"trail_w{way['id']}",
        'name': name,
        'type': 'hiking',
        'osm_id': way['id'],
        
        'distance_km': stats['distance_km'],
        'duration_hours': stats['duration_hours'],
        'elevation_gain_m': stats['elevation_gain_m'],
        'difficulty': difficulty,
        
        'start': {
            'lat': points[0][0],
            'lng': points[0][1],
            'name': 'Start'
        },
        'end': {
            'lat': points[-1][0],
            'lng': points[-1][1],
            'name': 'End'
        },
        
        'polyline': points[::5] if len(points) > 50 else points,
        'polyline_full_available': len(points) > 50,
        
        'surface': tags.get('surface', 'trail'),
        'sac_scale': tags.get('sac_scale'),
        'trail_visibility': tags.get('trail_visibility'),
        
        'description': tags.get('description', ''),
        'website': tags.get('website'),
        
        'region': detect_region(points[0][0], points[0][1]),
        'sources': ['osm'],
        'osm_type': 'way'
    }
    
    return trail


def detect_region(lat: float, lon: float) -> str:
    """Detect Icelandic region from coordinates"""
    
    # Simple region detection
    if lat > 65.5:
        return "North Iceland"
    elif lat < 63.8:
        return "South Iceland"
    elif lon < -21:
        return "West Iceland"
    elif lon > -16:
        return "East Iceland"
    else:
        return "Central Highlands"


def add_famous_trails() -> List[Dict]:
    """Add famous Icelandic trails with detailed info"""
    
    famous = [
        {
            'id': 'trail_laugavegur',
            'name': 'Laugavegur',
            'type': 'hiking',
            'distance_km': 55,
            'duration_hours': 16,
            'elevation_gain_m': 470,
            'difficulty': 'moderate',
            'region': 'Central Highlands',
            
            'start': {'lat': 63.9833, 'lng': -19.0581, 'name': 'Landmannalaugar'},
            'end': {'lat': 63.6833, 'lng': -19.4667, 'name': 'Þórsmörk'},
            
            'description': {
                'short': 'Frægasta gönguleið Íslands. 55 km í gegnum fjöll, lónhverasvæði og eyðimerkur.',
                'long': 'Laugavegurinn er ein vinsælasta gönguleið á Íslandi. Leiðin tekur 3-4 daga og gengur frá Landmannalaugum til Þórsmerkur í gegnum fjölbreytt landslag með litríkum rýólítfjöllum, svörtum sandinum við Hrafntinnusker, grænum dalnum og jökulám.'
            },
            
            'season': 'June–September',
            'warnings': ['Weather changes fast', 'River crossings', 'Book huts in advance'],
            
            'images': [
                'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800'
            ],
            
            'sources': ['manual', 'fi']
        },
        {
            'id': 'trail_fimmvorduhals',
            'name': 'Fimmvörðuháls',
            'type': 'hiking',
            'distance_km': 25,
            'duration_hours': 10,
            'elevation_gain_m': 1000,
            'difficulty': 'challenging',
            'region': 'South Iceland',
            
            'start': {'lat': 63.5321, 'lng': -19.5117, 'name': 'Skógafoss'},
            'end': {'lat': 63.6833, 'lng': -19.4667, 'name': 'Þórsmörk'},
            
            'description': {
                'short': 'Stórkostleg eins dags ganga á milli jöklanna Eyjafjallajökuls og Mýrdalsjökuls.',
                'long': 'Fimmvörðuháls er 25 km gönguleið sem liggur á milli tveggja jökla. Leiðin byrjar við Skógafoss og endar í Þórsmörk. Á leiðinni eru 26 fossar og útsýni yfir nýja gíginn frá gosinu 2010.'
            },
            
            'season': 'July–September',
            'warnings': ['Very exposed', 'No shelter', 'Weather dependent'],
            
            'images': [
                'https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800'
            ],
            
            'sources': ['manual', 'fi']
        },
        {
            'id': 'trail_hornstrandir',
            'name': 'Hornstrandir',
            'type': 'hiking',
            'distance_km': 140,
            'duration_hours': 56,
            'elevation_gain_m': 2500,
            'difficulty': 'expert',
            'region': 'Westfjords',
            
            'start': {'lat': 66.4, 'lng': -22.3, 'name': 'Hesteyri'},
            'end': {'lat': 66.5, 'lng': -21.8, 'name': 'Hornvík'},
            
            'description': {
                'short': 'Villt og ósnert náttúrusvæði í Hornströndum með refum og fuglum.',
                'long': 'Hornstrandir eru algjörlega einangruð og óbyggð svæði í Vestfjörðum. Ósnert náttúra, melrakkar, fuglar og stórbrotið landslag. Engin vegur, engin verslun - alvöru wilderness.'
            },
            
            'season': 'June–August',
            'warnings': ['Remote wilderness', 'No services', 'Self-sufficient only', 'Polar fox territory'],
            
            'images': [],
            
            'sources': ['manual']
        }
    ]
    
    return famous


def save_trails(trails: List[Dict], output_file: str):
    """Save trails to JSON"""
    
    output_path = Path(output_file)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(trails, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Saved {len(trails)} trails to: {output_file}")


def main():
    print("🥾 ICELAND TRAILS FETCHER")
    print("="*60)
    
    # Fetch from OSM
    elements = fetch_iceland_trails()
    
    trails = []
    
    # Process relations (official routes)
    print("\n📍 Processing trail relations...")
    for elem in elements:
        if elem['type'] == 'relation':
            trail = process_trail_relation(elem)
            if trail:
                trails.append(trail)
                print(f"   ✅ {trail['name']} - {trail['distance_km']} km")
    
    # Process ways (paths)
    print("\n📍 Processing trail ways...")
    for elem in elements:
        if elem['type'] == 'way':
            trail = process_trail_way(elem)
            if trail:
                trails.append(trail)
                print(f"   ✅ {trail['name']} - {trail['distance_km']} km")
    
    # Add famous trails with detailed info
    print("\n⭐ Adding famous trails...")
    famous = add_famous_trails()
    for trail in famous:
        trails.append(trail)
        print(f"   ✅ {trail['name']} - {trail['distance_km']} km")
    
    # Save
    output_file = "data/iceland_trails.json"
    save_trails(trails, output_file)
    
    # Stats
    print("\n" + "="*60)
    print("📊 TRAIL STATS")
    print("="*60)
    print(f"Total trails: {len(trails)}")
    print(f"Easy: {sum(1 for t in trails if t.get('difficulty') == 'easy')}")
    print(f"Moderate: {sum(1 for t in trails if t.get('difficulty') == 'moderate')}")
    print(f"Challenging: {sum(1 for t in trails if t.get('difficulty') == 'challenging')}")
    print(f"Expert: {sum(1 for t in trails if t.get('difficulty') == 'expert')}")
    print(f"\nTotal distance: {sum(t.get('distance_km', 0) for t in trails):.1f} km")
    
    print("\n🎉 Trail fetching complete!")
    print(f"📤 Next: Enrich with images and upload to Firebase")


if __name__ == "__main__":
    main()
