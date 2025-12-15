#!/usr/bin/env python3
"""Check trail enriched data"""

import json

with open('iceland_trails_enriched.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"\n🥾 TRAILS DATA STATUS:")
print(f"  Total trails: {len(data)}")

# Check first trail
sample = data[0]
print(f"\n📍 Sample trail: {sample.get('name', 'Unknown')}")
print(f"  Has mapImage: {'✅' if 'mapImage' in sample else '❌'}")
print(f"  Has map_preview: {'✅' if 'map_preview' in sample else '❌'}")
print(f"  Has description: {'✅' if 'description' in sample else '❌'}")
print(f"  Has content: {'✅' if 'content' in sample else '❌'}")

# Count how many have maps
with_map = sum(1 for t in data if t.get('mapImage') or t.get('map_preview'))
print(f"\n📊 Trails with maps: {with_map}/{len(data)}")

# Show keys
print(f"\n🔑 Available keys: {list(sample.keys())[:15]}")

if 'mapImage' in sample:
    print(f"\n🗺️  Map URL: {sample['mapImage'][:80]}...")
elif 'map_preview' in sample:
    print(f"\n🗺️  Map URL: {sample['map_preview'][:80]}...")
