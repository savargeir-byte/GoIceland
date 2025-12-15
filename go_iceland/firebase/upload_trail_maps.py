#!/usr/bin/env python3
"""
GO ICELAND - Upload Trail Maps to Firestore
Updates trails with OpenStreetMap embed URLs
"""
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from time import sleep

SERVICE_ACCOUNT = "./serviceAccountKey.json"
INPUT_FILE = "../data/iceland_trails_enriched.json"
COLLECTION = "trails"
BATCH_SIZE = 100

def init_firebase():
    """Initialize Firebase Admin SDK"""
    if not os.path.exists(SERVICE_ACCOUNT):
        print(f"❌ Service account key not found: {SERVICE_ACCOUNT}")
        return None
    
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        return None

def upload_batch(db, batch_data, batch_num, total_batches):
    """Upload a batch of trails"""
    batch = db.batch()
    
    for trail_id, trail_data in batch_data.items():
        doc_ref = db.collection(COLLECTION).document(trail_id)
        
        # Use merge=True to update existing trails with map data
        batch.set(doc_ref, trail_data, merge=True)
    
    batch.commit()
    print(f"  ✅ Batch {batch_num}/{total_batches} uploaded ({len(batch_data)} trails)")

def main():
    print("\n🗺️  GO ICELAND - Upload Trail Maps to Firestore")
    print("=" * 60)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    # Load trail map data
    if not os.path.exists(INPUT_FILE):
        print(f"❌ Input file not found: {INPUT_FILE}")
        return
    
    print(f"📂 Loading trail maps from: {INPUT_FILE}")
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        trails_list = json.load(f)
    
    # Convert list to dict if needed
    if isinstance(trails_list, list):
        trails_dict = {t.get('id', t['name'].replace(' ', '_')): t for t in trails_list}
    else:
        trails_dict = trails_list
    
    print(f"📊 Total trails: {len(trails_dict)}")
    
    # Count trails with maps
    with_maps = sum(1 for t in trails_dict.values() if t.get('mapImage'))
    print(f"   With maps: {with_maps} ({with_maps*100//len(trails_dict) if len(trails_dict) > 0 else 0}%)")
    
    # Calculate batches
    items = list(trails_dict.items())
    total_batches = (len(items) + BATCH_SIZE - 1) // BATCH_SIZE
    print(f"\n🚀 Uploading in {total_batches} batches of {BATCH_SIZE}...")
    
    # Upload in batches
    for i in range(0, len(items), BATCH_SIZE):
        batch_items = items[i:i + BATCH_SIZE]
        batch_data = dict(batch_items)
        batch_num = (i // BATCH_SIZE) + 1
        
        try:
            upload_batch(db, batch_data, batch_num, total_batches)
            sleep(0.5)
        except Exception as e:
            print(f"❌ Error uploading batch {batch_num}: {e}")
            continue
    
    print(f"\n✅ SUCCESS! Updated {len(trails_dict)} trails in Firestore")
    print(f"   Collection: {COLLECTION}")
    print(f"   With maps: {with_maps} trails")
    print("\n🎉 Trail maps are now in Firestore!")
    print("   Admin panel will show the maps after rebuild")

if __name__ == "__main__":
    main()
