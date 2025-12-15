#!/usr/bin/env python3
"""
GO ICELAND - Upload Enriched Places to Firestore
Uploads enriched places with Pexels images and descriptions
"""
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from time import sleep

SERVICE_ACCOUNT = "./serviceAccountKey.json"
INPUT_FILE = "../data/iceland_places_enriched.json"
COLLECTION = "places"
BATCH_SIZE = 100

def init_firebase():
    """Initialize Firebase Admin SDK"""
    if not os.path.exists(SERVICE_ACCOUNT):
        print(f"❌ Service account key not found: {SERVICE_ACCOUNT}")
        print("Download it from Firebase Console → Project Settings → Service Accounts")
        return None
    
    try:
        cred = credentials.Certificate(SERVICE_ACCOUNT)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        return None

def upload_batch(db, batch_data, batch_num, total_batches):
    """Upload a batch of places"""
    batch = db.batch()
    
    for place in batch_data:
        place_id = place.get("id", "")
        if not place_id:
            # Generate ID from name
            place_id = place["name"].replace(" ", "_").replace("/", "_")
            
        doc_ref = db.collection(COLLECTION).document(place_id)
        
        # Remove 'id' field since it's the document ID
        upload_data = {k: v for k, v in place.items() if k != "id"}
        
        # Use merge=True to update existing documents with new images/descriptions
        batch.set(doc_ref, upload_data, merge=True)
    
    batch.commit()
    print(f"  ✅ Batch {batch_num}/{total_batches} uploaded ({len(batch_data)} places)")

def main():
    print("\n🔥 GO ICELAND - Upload Enriched Places to Firestore")
    print("=" * 60)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    # Load enriched data
    if not os.path.exists(INPUT_FILE):
        print(f"❌ Input file not found: {INPUT_FILE}")
        return
    
    print(f"📂 Loading enriched data from: {INPUT_FILE}")
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📊 Total places: {len(places)}")
    
    # Count enriched places
    with_images = sum(1 for p in places if p.get('images') and len(p.get('images', [])) > 0)
    with_desc = sum(1 for p in places if p.get('content') or p.get('description'))
    
    print(f"   With images: {with_images} ({with_images*100//len(places)}%)")
    print(f"   With descriptions: {with_desc} ({with_desc*100//len(places)}%)")
    
    # Calculate batches
    total_batches = (len(places) + BATCH_SIZE - 1) // BATCH_SIZE
    print(f"\n🚀 Uploading in {total_batches} batches of {BATCH_SIZE}...")
    
    # Upload in batches
    for i in range(0, len(places), BATCH_SIZE):
        batch_data = places[i:i + BATCH_SIZE]
        batch_num = (i // BATCH_SIZE) + 1
        
        try:
            upload_batch(db, batch_data, batch_num, total_batches)
            sleep(0.5)  # Small delay between batches
        except Exception as e:
            print(f"❌ Error uploading batch {batch_num}: {e}")
            continue
    
    print(f"\n✅ SUCCESS! Uploaded {len(places)} places to Firestore")
    print(f"   Collection: {COLLECTION}")
    print(f"   With images: {with_images} places")
    print(f"   With descriptions: {with_desc} places")
    print("\n🎉 All enriched data is now in Firestore!")
    print("   Next: Rebuild admin panel and deploy to see the images")

if __name__ == "__main__":
    main()
