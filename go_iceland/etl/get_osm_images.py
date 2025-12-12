#!/usr/bin/env python3
"""
get_osm_images.py
Extracts image URLs from OSM tags (image, image:url, photo fields)
"""
import json
import os

INPUT = './data/iceland_clean_geohash.json'
OUTPUT = './data/iceland_with_osm_images.json'

def extract_osm_images():
    """Read enriched POIs and extract image URLs from OSM tags"""
    if not os.path.exists(INPUT):
        print(f"❌ Input file not found: {INPUT}")
        print("Run enrich_pois.py and utils_geohash.py first")
        return
    
    with open(INPUT, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    images_added = 0
    for poi in data:
        tags = poi.get('tags', {})
        
        # Check common OSM image fields
        img_url = (
            tags.get('image') or 
            tags.get('image:url') or 
            tags.get('photo') or
            tags.get('wikimedia_commons')
        )
        
        if img_url:
            if 'images' not in poi:
                poi['images'] = []
            
            # Avoid duplicates
            if img_url not in poi['images']:
                poi['images'].append(img_url)
                images_added += 1
    
    # Save output
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Extracted OSM images for {images_added} POIs")
    print(f"📁 Saved to: {OUTPUT}")
    print(f"📊 Total POIs: {len(data)}")

if __name__ == '__main__':
    extract_osm_images()
