#!/usr/bin/env python3
"""Check trail map data"""

import json

# Try iceland_trails_enriched.json (array format)
try:
    with open('iceland_trails_enriched.json', 'r', encoding='utf-8') as f:
        trails = json.load(f)
    
    if isinstance(trails, list):
        print(f"\n🥾 TRAIL MAPS STATUS (iceland_trails_enriched.json):")
        print(f"  Total trails: {len(trails)}")
        
        # Count trails with maps
        with_maps = sum(1 for t in trails if t.get('mapImage'))
        print(f"  With mapImage: {with_maps}/{len(trails)} ({with_maps*100//len(trails) if len(trails) > 0 else 0}%)")
        
        # Show sample
        if with_maps > 0:
            sample = [t for t in trails if t.get('mapImage')][0]
            print(f"\n📍 Sample trail with map: {sample.get('name', 'Unknown')}")
            print(f"  Map URL: {sample.get('mapImage', '')[:80]}...")
        else:
            print("\n⚠️  No trails have mapImage field!")
            print("  Keys in sample:", list(trails[0].keys())[:10])
except Exception as e:
    print(f"Error: {e}")
