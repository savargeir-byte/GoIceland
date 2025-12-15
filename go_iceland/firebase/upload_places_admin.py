"""
GO ICELAND - Places Uploader to Firestore
Uploads enriched place data to Firebase Firestore using Admin SDK
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

def upload_batch(db, batch_data):
    """Upload a batch of places"""
    batch = db.batch()
    
    for place in batch_data:
        place_id = place.get("id", "")
        if not place_id:
            continue
            
        doc_ref = db.collection(COLLECTION).document(place_id)
        
        # Remove 'id' field since it's the document ID
        upload_data = {k: v for k, v in place.items() if k != "id"}
        
        batch.set(doc_ref, upload_data, merge=True)
    
    batch.commit()

def main():
    print("📍 GO ICELAND - Places Uploader")
    print("=" * 80)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    print("✅ Firebase connected")
    print()
    
    # Load enriched place data
    if not os.path.exists(INPUT_FILE):
        print(f"❌ Input file not found: {INPUT_FILE}")
        print("Wait for bulk_enrich.py to complete first!")
        return
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📊 Loaded {len(places)} places")
    
    # Count places with images
    places_with_images = sum(1 for p in places if p.get("images"))
    print(f"🖼️  Places with images: {places_with_images}")
    print()
    
    # Upload in batches
    total = len(places)
    uploaded = 0
    
    for i in range(0, total, BATCH_SIZE):
        batch = places[i:i + BATCH_SIZE]
        batch_num = i // BATCH_SIZE + 1
        total_batches = (total + BATCH_SIZE - 1) // BATCH_SIZE
        
        print(f"📦 Batch {batch_num}/{total_batches} ({len(batch)} places)...", end=" ", flush=True)
        
        try:
            upload_batch(db, batch)
            uploaded += len(batch)
            print(f"✅ Uploaded ({uploaded}/{total})")
        except Exception as e:
            print(f"❌ Error: {str(e)}")
        
        # Small delay between batches
        if i + BATCH_SIZE < total:
            sleep(0.5)
    
    print()
    print("=" * 80)
    print("✅ PLACE UPLOAD COMPLETE!")
    print("=" * 80)
    print(f"📊 SUMMARY:")
    print(f"   Total places: {total}")
    print(f"   Uploaded: {uploaded}")
    print()
    print("Next step: Open https://go-iceland.web.app to view places")

if __name__ == "__main__":
    main()
