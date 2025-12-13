#!/usr/bin/env python3
"""
🔥 FIREBASE BATCH UPLOADER
Uploadar POIs og Trails í Firebase í einu
Manual upload með Firebase CLI commands eða JSON export
"""

import json
import sys
from pathlib import Path


def load_json(file_path: str):
    """Load JSON file"""
    path = Path(file_path)
    if not path.exists():
        return None
    
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def create_firestore_batch_json(pois: list, trails: list, output_file: str):
    """Býr til unified JSON með öllum gögnum fyrir Firebase"""
    
    firestore_data = {
        '__collections__': {
            'places': {},
            'trails': {}
        }
    }
    
    # Add POIs
    for poi in pois:
        doc_id = poi.get('id', poi.get('name', '').lower().replace(' ', '_'))
        firestore_data['__collections__']['places'][doc_id] = poi
    
    # Add Trails
    for trail in trails:
        doc_id = trail.get('id', trail.get('name', '').lower().replace(' ', '_'))
        firestore_data['__collections__']['trails'][doc_id] = trail
    
    # Save
    output_path = Path(output_file)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(firestore_data, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Created Firestore import file: {output_file}")
    print(f"   📍 {len(pois)} places")
    print(f"   🥾 {len(trails)} trails")


def create_separate_json_files(pois: list, trails: list):
    """Býr til aðskildar JSON skrár"""
    
    # POIs
    poi_dict = {}
    for poi in pois:
        doc_id = poi.get('id', poi.get('name', '').lower().replace(' ', '_'))
        poi_dict[doc_id] = poi
    
    with open('data/firestore_places.json', 'w', encoding='utf-8') as f:
        json.dump(poi_dict, f, indent=2, ensure_ascii=False)
    
    # Trails
    trail_dict = {}
    for trail in trails:
        doc_id = trail.get('id', trail.get('name', '').lower().replace(' ', '_'))
        trail_dict[doc_id] = trail
    
    with open('data/firestore_trails.json', 'w', encoding='utf-8') as f:
        json.dump(trail_dict, f, indent=2, ensure_ascii=False)
    
    print(f"✅ Created separate files:")
    print(f"   📍 data/firestore_places.json ({len(pois)} places)")
    print(f"   🥾 data/firestore_trails.json ({len(trails)} trails)")


def print_firebase_commands(pois: list, trails: list, max_items: int = 5):
    """Print Firebase CLI commands (sample)"""
    
    print("\n" + "="*60)
    print("🔥 FIREBASE CLI COMMANDS (Sample)")
    print("="*60 + "\n")
    
    print("# Set Firebase project:")
    print("firebase use YOUR_PROJECT_ID\n")
    
    print("# Sample POIs:")
    for poi in pois[:max_items]:
        doc_id = poi.get('id')
        print(f"firebase firestore:set places/{doc_id} '{json.dumps(poi, ensure_ascii=False)}' --project YOUR_PROJECT_ID")
    
    if len(pois) > max_items:
        print(f"# ... and {len(pois) - max_items} more places\n")
    
    print("\n# Sample Trails:")
    for trail in trails[:max_items]:
        doc_id = trail.get('id')
        print(f"firebase firestore:set trails/{doc_id} '{json.dumps(trail, ensure_ascii=False)}' --project YOUR_PROJECT_ID")
    
    if len(trails) > max_items:
        print(f"# ... and {len(trails) - max_items} more trails\n")


def main():
    print("🔥 FIREBASE BATCH UPLOADER\n")
    
    # Load data
    print("📖 Loading data...")
    pois = load_json('data/iceland_enriched_full.json')
    trails = load_json('data/iceland_trails.json')
    
    if not pois:
        print("⚠️  No POI data found (data/iceland_enriched_full.json)")
        pois = []
    else:
        print(f"   ✅ {len(pois)} POIs loaded")
    
    if not trails:
        print("⚠️  No trail data found (data/iceland_trails.json)")
        trails = []
    else:
        print(f"   ✅ {len(trails)} trails loaded")
    
    if not pois and not trails:
        print("\n❌ No data to upload!")
        sys.exit(1)
    
    print("\n" + "="*60)
    print("Choose upload format:")
    print("  1. Unified JSON (all collections in one file)")
    print("  2. Separate JSON files (places.json + trails.json)")
    print("  3. Firebase CLI commands (sample)")
    print("  4. All of the above")
    print("="*60)
    
    choice = input("\nChoice (1/2/3/4): ").strip()
    
    if choice in ['1', '4']:
        create_firestore_batch_json(pois, trails, 'data/firestore_complete.json')
    
    if choice in ['2', '4']:
        create_separate_json_files(pois, trails)
    
    if choice in ['3', '4']:
        print_firebase_commands(pois, trails, max_items=3)
    
    print("\n" + "="*60)
    print("📤 UPLOAD INSTRUCTIONS")
    print("="*60)
    print("\n🔥 Option A: Firebase Console (Easiest)")
    print("   1. Go to https://console.firebase.google.com")
    print("   2. Select your project")
    print("   3. Firestore Database → Import data")
    print("   4. Select JSON file")
    print("   5. Choose target collection (places or trails)")
    
    print("\n🔥 Option B: Firebase CLI")
    print("   firebase firestore:import data/firestore_complete.json --project YOUR_PROJECT_ID")
    
    print("\n🔥 Option C: Node.js Script")
    print("   1. Download service account key from Firebase")
    print("   2. Save as serviceAccountKey.json")
    print("   3. npm install firebase-admin")
    print("   4. node ../travel_super_app/upload_places.js")
    
    print("\n" + "="*60)
    print(f"\n✅ Ready to upload:")
    print(f"   📍 {len(pois)} places with Wikipedia descriptions, images, services")
    print(f"   🥾 {len(trails)} trails from OSM with polylines, stats")
    print("\n🎉 This will make GO ICELAND the BEST Iceland travel app!")


if __name__ == "__main__":
    main()
