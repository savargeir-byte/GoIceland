"""
GO ICELAND - Add GeoPoint & Geohash to POI data
Adds Firebase GeoPoint format and geohash for geoflutterfire queries

This script enriches POI data with location data suitable for:
- Firebase GeoPoint queries
- geoflutterfire radius searches
- Geohash-based spatial indexing

Usage:
    python add_geohash.py input.json output.json
"""

import json
import sys
import hashlib
from typing import Dict, Tuple

def encode_geohash(lat: float, lng: float, precision: int = 9) -> str:
    """
    Encode latitude/longitude to geohash
    
    Precision levels:
    - 5: ~5km
    - 6: ~1.2km
    - 7: ~150m
    - 8: ~38m
    - 9: ~5m (recommended for POIs)
    """
    base32 = '0123456789bcdefghjkmnpqrstuvwxyz'
    
    lat_min, lat_max = -90.0, 90.0
    lng_min, lng_max = -180.0, 180.0
    
    geohash = []
    bits = 0
    bit = 0
    even = True
    
    while len(geohash) < precision:
        if even:
            mid = (lng_min + lng_max) / 2
            if lng > mid:
                bit |= (1 << (4 - bits))
                lng_min = mid
            else:
                lng_max = mid
        else:
            mid = (lat_min + lat_max) / 2
            if lat > mid:
                bit |= (1 << (4 - bits))
                lat_min = mid
            else:
                lat_max = mid
        
        even = not even
        bits += 1
        
        if bits == 5:
            geohash.append(base32[bit])
            bits = 0
            bit = 0
    
    return ''.join(geohash)

def add_location_data(poi: Dict) -> Dict:
    """Add GeoPoint and geohash to POI"""
    lat = poi.get('lat')
    lng = poi.get('lng')
    
    if lat is None or lng is None:
        print(f"⚠️  Skipping {poi.get('name', 'unknown')} - missing coordinates")
        return poi
    
    # Add GeoPoint structure for Firebase
    poi['location'] = {
        'geopoint': {
            '_latitude': lat,
            '_longitude': lng
        },
        'geohash': encode_geohash(lat, lng, precision=9)
    }
    
    # Add geohash variations for different radius queries
    poi['geohashes'] = {
        'g5': encode_geohash(lat, lng, precision=5),  # ~5km
        'g6': encode_geohash(lat, lng, precision=6),  # ~1.2km
        'g7': encode_geohash(lat, lng, precision=7),  # ~150m
        'g8': encode_geohash(lat, lng, precision=8),  # ~38m
        'g9': encode_geohash(lat, lng, precision=9),  # ~5m
    }
    
    return poi

def deduplicate_pois(pois: list) -> list:
    """Remove duplicate POIs based on location and name"""
    seen = set()
    deduped = []
    duplicates = 0
    
    for poi in pois:
        # Create key from rounded coordinates and normalized name
        lat = poi.get('lat')
        lng = poi.get('lng')
        name = (poi.get('name') or '').strip().lower()
        
        if lat is None or lng is None:
            continue
        
        # Round to ~100m precision for deduplication
        key = (round(lat, 4), round(lng, 4), name)
        
        if key in seen:
            duplicates += 1
            continue
        
        seen.add(key)
        deduped.append(poi)
    
    print(f"   Removed {duplicates} duplicates")
    return deduped

def main():
    if len(sys.argv) < 3:
        print("Usage: python add_geohash.py input.json output.json")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    print("=" * 60)
    print("GO ICELAND - Add GeoPoint & Geohash")
    print("=" * 60)
    print(f"Input:  {input_file}")
    print(f"Output: {output_file}")
    print("=" * 60)
    print()
    
    # Load data
    print("📂 Loading POI data...")
    with open(input_file, 'r', encoding='utf-8') as f:
        pois = json.load(f)
    
    original_count = len(pois)
    print(f"   Loaded {original_count} POIs")
    print()
    
    # Deduplicate
    print("🔍 Deduplicating...")
    pois = deduplicate_pois(pois)
    print(f"   {len(pois)} unique POIs")
    print()
    
    # Add location data
    print("📍 Adding GeoPoint & geohash...")
    enriched = []
    skipped = 0
    
    for poi in pois:
        enriched_poi = add_location_data(poi)
        if 'location' in enriched_poi:
            enriched.append(enriched_poi)
        else:
            skipped += 1
    
    print(f"   Enriched {len(enriched)} POIs")
    if skipped > 0:
        print(f"   Skipped {skipped} POIs (missing coordinates)")
    print()
    
    # Save
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(enriched, f, indent=2, ensure_ascii=False)
    
    print("=" * 60)
    print(f"✅ Saved {len(enriched)} POIs to {output_file}")
    print("=" * 60)
    print()
    
    # Sample output
    if enriched:
        print("📊 Sample POI:")
        sample = enriched[0]
        print(f"   Name: {sample.get('name')}")
        print(f"   Coordinates: ({sample.get('lat')}, {sample.get('lng')})")
        if 'location' in sample:
            print(f"   Geohash: {sample['location']['geohash']}")
            print(f"   GeoPoint: {sample['location']['geopoint']}")
        print()
    
    print("Next step: Upload to Firestore with upload_to_firestore.py")
    print("=" * 60)

if __name__ == "__main__":
    main()
