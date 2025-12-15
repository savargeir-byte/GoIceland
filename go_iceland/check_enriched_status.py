#!/usr/bin/env python3
"""Check enriched places status"""

import json
import os

enriched_file = 'data/iceland_places_enriched.json'

if not os.path.exists(enriched_file):
    print(f"❌ File not found: {enriched_file}")
    exit(1)

with open(enriched_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

print(f"\n📊 ENRICHED PLACES STATUS:")
print(f"  Total places: {len(data)}")

# Count enriched places
with_images = sum(1 for p in data if p.get('images') and len(p.get('images', [])) > 0)
with_desc = sum(1 for p in data if p.get('content') or p.get('description'))

print(f"  With images: {with_images}/{len(data)} ({with_images*100//len(data)}%)")
print(f"  With description: {with_desc}/{len(data)} ({with_desc*100//len(data)}%)")

# Show sample with images
samples_with_images = [p for p in data if p.get('images') and len(p.get('images', [])) > 0]
if samples_with_images:
    sample = samples_with_images[0]
    print(f"\n📍 Sample enriched place: {sample.get('name', 'Unknown')}")
    print(f"  Category: {sample.get('category', 'N/A')}")
    print(f"  Images: {len(sample.get('images', []))} images")
    if sample.get('images'):
        print(f"  First image: {sample['images'][0][:60]}...")
    has_desc = 'content' in sample or 'description' in sample
    print(f"  Description: {'✅' if has_desc else '❌'}")

# Show progress
print(f"\n📈 Progress: {len(data)}/4972 places processed")
remaining = 4972 - len(data)
print(f"   Remaining: {remaining} places")
if remaining > 0:
    print(f"   ETA: ~{remaining * 2 // 60} minutes (at 2 sec/place)")
else:
    print("   ✅ ENRICHMENT COMPLETE!")
