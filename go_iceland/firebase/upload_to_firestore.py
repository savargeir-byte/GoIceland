"""
GO ICELAND - Firestore Uploader
Uploads POI data to Firebase Firestore
"""
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from time import sleep

SERVICE_ACCOUNT = "./firebase/serviceAccountKey.json"
INPUT = "./data/iceland_clean_geohash.json"
COLLECTION = "places"
BATCH_SIZE = 500

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
    """Upload a batch of documents"""
    batch = db.batch()
    
    for poi in batch_data:
        poi_id = poi.get("id", poi["name"].replace(" ", "_"))
        doc_ref = db.collection(COLLECTION).document(poi_id)
        
        # Remove 'id' field since it's the document ID
        upload_data = {k: v for k, v in poi.items() if k != "id"}
        
        batch.set(doc_ref, upload_data, merge=True)
    
    batch.commit()

def main():
    print("🔥 GO ICELAND - Firestore Uploader")
    print("=" * 50)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    # Load data
    if not os.path.exists(INPUT):
        print(f"❌ Input file not found: {INPUT}")
        print("Run the ETL pipeline first:")
        print("  1. python etl/fetch_iceland_pois.py")
        print("  2. python etl/enrich_pois.py")
        print("  3. python etl/utils_geohash.py")
        return
    
    with open(INPUT, encoding="utf-8") as f:
        data = json.load(f)
    
    print(f"\n📊 Uploading {len(data)} POIs to Firestore...")
    print(f"Collection: {COLLECTION}")
    print(f"Batch size: {BATCH_SIZE}")
    print()
    
    # Upload in batches
    for i in range(0, len(data), BATCH_SIZE):
        batch_data = data[i:i + BATCH_SIZE]
        batch_num = (i // BATCH_SIZE) + 1
        total_batches = (len(data) + BATCH_SIZE - 1) // BATCH_SIZE
        
        print(f"Uploading batch {batch_num}/{total_batches} ({len(batch_data)} docs)...")
        
        try:
            upload_batch(db, batch_data)
            print(f"✅ Batch {batch_num} uploaded")
            sleep(0.5)  # Rate limiting
        except Exception as e:
            print(f"❌ Batch {batch_num} failed: {e}")
    
    print()
    print("=" * 50)
    print(f"✅ Upload complete!")
    print(f"Total documents: {len(data)}")
    print(f"Collection: {COLLECTION}")
    print()
    print("Verify at:")
    print("https://console.firebase.google.com/project/go-iceland/firestore")

if __name__ == "__main__":
    main()
