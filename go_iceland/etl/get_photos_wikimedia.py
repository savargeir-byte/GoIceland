#!/usr/bin/env python3
"""
get_photos_wikimedia.py
Fetches free images from Wikimedia Commons based on POI names
"""
import json
import os
import time
import requests
from urllib.parse import quote

INPUT = './data/iceland_with_osm_images.json'
OUTPUT = './data/iceland_with_all_images.json'

def fetch_wikimedia_images(name, limit=3):
    """Search Wikimedia Commons for images matching the POI name"""
    search_query = f"{name} Iceland"
    url = (
        f"https://commons.wikimedia.org/w/api.php"
        f"?action=query"
        f"&format=json"
        f"&generator=search"
        f"&gsrsearch={quote(search_query)}"
        f"&gsrlimit={limit}"
        f"&prop=imageinfo"
        f"&iiprop=url|size"
        f"&iiurlwidth=800"
    )
    
    try:
        response = requests.get(url, timeout=15)
        response.raise_for_status()
        data = response.json()
        
        images = []
        pages = data.get('query', {}).get('pages', {})
        
        for page_id, page_data in pages.items():
            imageinfo = page_data.get('imageinfo', [])
            if imageinfo:
                img_url = imageinfo[0].get('url') or imageinfo[0].get('thumburl')
                if img_url and img_url.startswith('http'):
                    images.append(img_url)
        
        return images
    
    except Exception as e:
        print(f"⚠️  Wikimedia error for '{name}': {e}")
        return []

def enrich_with_wikimedia():
    """Add Wikimedia Commons images to POIs"""
    if not os.path.exists(INPUT):
        print(f"❌ Input file not found: {INPUT}")
        print("Run enrich_pois.py and utils_geohash.py first")
        return
    
    with open(INPUT, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    print(f"🔍 Searching Wikimedia Commons for {len(data)} POIs...")
    print("⏳ This may take several minutes...")
    
    enriched = 0
    for i, poi in enumerate(data):
        name = poi.get('name', '')
        
        # Skip if already has images
        if poi.get('images') and len(poi['images']) >= 3:
            continue
        
        # Fetch Wikimedia images
        wikimedia_images = fetch_wikimedia_images(name, limit=3)
        
        if wikimedia_images:
            if 'images' not in poi:
                poi['images'] = []
            
            # Add unique images
            for img in wikimedia_images:
                if img not in poi['images']:
                    poi['images'].append(img)
            
            enriched += 1
            print(f"  [{i+1}/{len(data)}] ✅ {name}: +{len(wikimedia_images)} images")
        
        # Rate limiting
        time.sleep(0.5)
        
        # Progress update every 50 POIs
        if (i + 1) % 50 == 0:
            print(f"  Progress: {i+1}/{len(data)} POIs processed ({enriched} enriched)")
    
    # Save output
    os.makedirs(os.path.dirname(OUTPUT), exist_ok=True)
    with open(OUTPUT, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Wikimedia enrichment complete!")
    print(f"📁 Saved to: {OUTPUT}")
    print(f"📊 Total POIs: {len(data)}")
    print(f"🖼️  POIs with new images: {enriched}")

if __name__ == '__main__':
    enrich_with_wikimedia()
