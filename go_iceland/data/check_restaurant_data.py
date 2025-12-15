#!/usr/bin/env python3
"""Check sample place data structure"""

import json

with open('iceland_places_enriched.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Get restaurants
restaurants = [p for p in data if p.get('category') == 'restaurant']

print(f"\n📊 RESTAURANT DATA ANALYSIS:")
print(f"Total restaurants: {len(restaurants)}\n")

# Sample with data
with_data = [r for r in restaurants if r.get('content') or r.get('description')]
without_data = [r for r in restaurants if not (r.get('content') or r.get('description'))]

if with_data:
    sample = with_data[0]
    print(f"✅ Sample WITH data: {sample.get('name')}")
    print(f"   Images: {len(sample.get('images', []))}")
    print(f"   Content: {sample.get('content', sample.get('description', 'None'))}")

print()

if without_data:
    sample = without_data[0]
    print(f"❌ Sample WITHOUT data: {sample.get('name')}")
    print(f"   Images: {len(sample.get('images', []))}")
    print(f"   Has content field: {'content' in sample}")
    print(f"   Has description field: {'description' in sample}")
    print(f"   Available keys: {list(sample.keys())[:15]}")
