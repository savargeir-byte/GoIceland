"""
Upload enriched trails to Firestore using REST API
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

def upload_trail(trail):
    """Upload a single trail to Firestore"""
    trail_id = trail.get('id', trail.get('trail_id', ''))
    if not trail_id:
        print(f"  ⚠️  Skipping trail without ID: {trail.get('name')}")
        return False
    
    # Convert to Firestore format
    fields = {}
    for key, value in trail.items():
        if key != 'id':  # ID is in document path, not fields
            fields[key] = python_to_firestore_value(value)
    
    doc_data = {"fields": fields}
    
    # Update document
    url = f"{BASE_URL}/trails/{trail_id}"
    
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
    print("📤 UPLOADING TRAILS TO FIRESTORE")
    print("="*80)
    print()
    
    # Load enriched trails
    input_file = '../data/iceland_trails_enriched.json'
    
    try:
        with open(input_file, 'r', encoding='utf-8') as f:
            trails = json.load(f)
    except FileNotFoundError:
        print(f"❌ File not found: {input_file}")
        print("   Run generate_trail_maps.py first!")
        return
    
    print(f"📊 Loaded {len(trails)} trails")
    print()
    
    # Count enriched trails
    enriched = [t for t in trails if t.get('mapImage') or t.get('map_preview')]
    print(f"📈 Trails with maps: {len(enriched)}")
    print()
    
    print("Starting upload...")
    print()
    
    uploaded = 0
    failed = 0
    
    for i, trail in enumerate(trails, 1):
        name = trail.get('name', 'Unknown')
        print(f"[{i}/{len(trails)}] {name}", end=" ")
        
        if upload_trail(trail):
            uploaded += 1
            print("✅")
        else:
            failed += 1
            print("❌")
        
        # Rate limit
        sleep(0.2)
    
    print()
    print("="*80)
    print("✅ UPLOAD COMPLETE!")
    print("="*80)
    print()
    print(f"📊 SUMMARY:")
    print(f"   Total: {len(trails)}")
    print(f"   Uploaded: {uploaded}")
    print(f"   Failed: {failed}")
    print()
    print(f"🌐 Check your admin panel:")
    print(f"   https://go-iceland.web.app")

if __name__ == "__main__":
    main()
