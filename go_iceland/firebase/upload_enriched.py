"""
Upload enriched places to Firestore using REST API
"""
import json
import requests
from time import sleep

PROJECT_ID = "go-iceland"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def python_to_firestore_value(value):
    """Convert Python value to Firestore format"""
    if value is None:
        return {"nullValue": None}
    elif isinstance(value, bool):
        return {"booleanValue": value}
    elif isinstance(value, int):
        return {"integerValue": str(value)}
    elif isinstance(value, float):
        return {"doubleValue": value}
    elif isinstance(value, str):
        return {"stringValue": value}
    elif isinstance(value, list):
        return {
            "arrayValue": {
                "values": [python_to_firestore_value(item) for item in value]
            }
        }
    elif isinstance(value, dict):
        return {
            "mapValue": {
                "fields": {
                    k: python_to_firestore_value(v) for k, v in value.items()
                }
            }
        }
    else:
        return {"stringValue": str(value)}

def upload_place(place):
    """Upload a single place to Firestore"""
    place_id = place.get('id', place.get('place_id', ''))
    if not place_id:
        print(f"  ⚠️  Skipping place without ID: {place.get('name')}")
        return False
    
    # Convert to Firestore format
    fields = {}
    for key, value in place.items():
        if key != 'id':  # ID is in document path, not fields
            fields[key] = python_to_firestore_value(value)
    
    doc_data = {"fields": fields}
    
    # Update document
    url = f"{BASE_URL}/places/{place_id}"
    
    try:
        response = requests.patch(url, json=doc_data, timeout=30)
        
        if response.status_code in [200, 201]:
            return True
        else:
            print(f"  ❌ Error {response.status_code}: {response.text[:200]}")
            return False
    except Exception as e:
        print(f"  ❌ Error: {e}")
        return False

def main():
    print("="*80)
    print("📤 UPLOADING TO FIRESTORE")
    print("="*80)
    print()
    
    # Load enriched places
    input_file = '../data/iceland_places_enriched.json'
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            places = json.load(f)
    except FileNotFoundError:
        print(f"❌ File not found: {input_file}")
        print("   Run bulk_enrich.py first!")
        return
    
    print(f"📊 Loaded {len(places)} places")
    print()
    
    # Count enriched places
    enriched = [p for p in places if p.get('images') and p.get('content')]
    print(f"📈 Enriched places: {len(enriched)}")
    print()
    
    if len(enriched) == 0:
        print("⚠️  No enriched places found. Run bulk_enrich.py first!")
        return
    
    print("Starting upload...")
    print()
    
    uploaded = 0
    failed = 0
    
    for i, place in enumerate(places, 1):
        name = place.get('name', 'Unknown')
        print(f"[{i}/{len(places)}] {name}", end=" ")
        
        if upload_place(place):
            uploaded += 1
            print("✅")
        else:
            failed += 1
            print("❌")
        
        # Rate limit - be nice to Firebase
        sleep(0.2)
        
        # Progress update every 100
        if i % 100 == 0:
            print(f"\n📊 Progress: {uploaded} uploaded, {failed} failed\n")
    
    print()
    print("="*80)
    print("✅ UPLOAD COMPLETE!")
    print("="*80)
    print()
    print(f"📊 SUMMARY:")
    print(f"   Total: {len(places)}")
    print(f"   Uploaded: {uploaded}")
    print(f"   Failed: {failed}")
    print()
    print(f"🌐 Check your admin panel:")
    print(f"   https://go-iceland.web.app")

if __name__ == "__main__":
    main()
