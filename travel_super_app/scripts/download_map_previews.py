"""
GO ICELAND - Download Map Previews
Downloads static map images from Mapbox and uploads to Firebase Storage

Requires:
- MAPBOX_TOKEN environment variable
- Firebase Storage setup
- serviceAccountKey.json

Usage:
    python download_map_previews.py input.json output.json
    
Optional flags:
    --width 400 --height 300 --zoom 13
"""

import json
import sys
import os
import requests
import firebase_admin
from firebase_admin import credentials, storage
from urllib.parse import quote
from time import sleep
import argparse

MAPBOX_TOKEN = os.getenv('MAPBOX_TOKEN', '')
MAPBOX_STYLE = 'mapbox/outdoors-v12'  # Good for Iceland terrain
IMAGE_WIDTH = 400
IMAGE_HEIGHT = 300
ZOOM_LEVEL = 13

def get_mapbox_static_url(lat: float, lng: float, width: int, height: int, zoom: int) -> str:
    """Generate Mapbox static image URL"""
    if not MAPBOX_TOKEN:
        return None
    
    url = (
        f"https://api.mapbox.com/styles/v1/{MAPBOX_STYLE}/static/"
        f"pin-s+ff0000({lng},{lat})/"
        f"{lng},{lat},{zoom},0/{width}x{height}@2x"
        f"?access_token={MAPBOX_TOKEN}"
    )
    return url

def download_and_upload_preview(poi: dict, bucket, width: int, height: int, zoom: int) -> str:
    """Download map preview and upload to Firebase Storage"""
    lat = poi.get('lat')
    lng = poi.get('lng')
    poi_id = poi.get('id', 'unknown')
    
    if not lat or not lng:
        return None
    
    # Get Mapbox URL
    map_url = get_mapbox_static_url(lat, lng, width, height, zoom)
    if not map_url:
        return None
    
    try:
        # Download image
        response = requests.get(map_url, timeout=10)
        response.raise_for_status()
        
        # Upload to Firebase Storage
        blob = bucket.blob(f"map_previews/{poi_id}.png")
        blob.upload_from_string(response.content, content_type='image/png')
        blob.make_public()
        
        return blob.public_url
    
    except Exception as e:
        print(f"   ❌ Failed for {poi.get('name')}: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description="Download map previews")
    parser.add_argument("input", help="Input JSON file")
    parser.add_argument("output", help="Output JSON file")
    parser.add_argument("--width", type=int, default=400, help="Image width")
    parser.add_argument("--height", type=int, default=300, help="Image height")
    parser.add_argument("--zoom", type=int, default=13, help="Zoom level")
    parser.add_argument("--skip-existing", action="store_true", help="Skip POIs with existing mapPreview")
    args = parser.parse_args()
    
    print("=" * 60)
    print("GO ICELAND - Download Map Previews")
    print("=" * 60)
    print(f"Input:  {args.input}")
    print(f"Output: {args.output}")
    print(f"Size: {args.width}x{args.height}, Zoom: {args.zoom}")
    print("=" * 60)
    print()
    
    # Check Mapbox token
    if not MAPBOX_TOKEN:
        print("⚠️  MAPBOX_TOKEN not set - skipping preview generation")
        print("   Set with: export MAPBOX_TOKEN=pk.your_token")
        print()
        print("Copying input to output without previews...")
        
        with open(args.input, 'r', encoding='utf-8') as f:
            data = json.load(f)
        with open(args.output, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
        
        print("✅ Done (no previews generated)")
        return
    
    # Initialize Firebase
    try:
        cred = credentials.Certificate("serviceAccountKey.json")
        firebase_admin.initialize_app(cred, {
            'storageBucket': f"{os.getenv('FIRESTORE_PROJECT_ID', 'go-iceland')}.appspot.com"
        })
        bucket = storage.bucket()
        print("✅ Firebase Storage initialized")
    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        print("   Make sure serviceAccountKey.json exists")
        return
    
    print()
    
    # Load data
    print("📂 Loading POI data...")
    with open(args.input, 'r', encoding='utf-8') as f:
        pois = json.load(f)
    
    print(f"   Loaded {len(pois)} POIs")
    print()
    
    # Download previews
    print("🗺️  Downloading map previews...")
    processed = 0
    skipped = 0
    failed = 0
    
    for i, poi in enumerate(pois, 1):
        if args.skip_existing and poi.get('mapPreview'):
            skipped += 1
            continue
        
        print(f"   [{i}/{len(pois)}] {poi.get('name', 'Unknown')[:40]}", end='')
        
        preview_url = download_and_upload_preview(poi, bucket, args.width, args.height, args.zoom)
        
        if preview_url:
            poi['mapPreview'] = preview_url
            processed += 1
            print(" ✓")
        else:
            failed += 1
            print(" ✗")
        
        # Rate limiting
        sleep(0.3)
    
    print()
    print(f"   Processed: {processed}")
    print(f"   Skipped: {skipped}")
    print(f"   Failed: {failed}")
    print()
    
    # Save
    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(pois, f, indent=2, ensure_ascii=False)
    
    print("=" * 60)
    print(f"✅ Saved to {args.output}")
    print("=" * 60)

if __name__ == "__main__":
    main()
