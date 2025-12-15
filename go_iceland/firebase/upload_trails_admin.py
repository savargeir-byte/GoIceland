"""
GO ICELAND - Trail Uploader to Firestore
Uploads enriched trail data to Firebase Firestore using Admin SDK
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
    """Upload a batch of trails"""
    batch = db.batch()
    
    for trail in batch_data:
        trail_id = trail.get("id", "")
        if not trail_id:
            continue
            
        doc_ref = db.collection(COLLECTION).document(trail_id)
        
        # Remove 'id' field since it's the document ID
        upload_data = {k: v for k, v in trail.items() if k != "id"}
        
        batch.set(doc_ref, upload_data, merge=True)
    
    batch.commit()

def main():
    print("🗺️  GO ICELAND - Trail Uploader")
    print("=" * 80)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    print("✅ Firebase connected")
    print()
    
    # Load enriched trail data
    if not os.path.exists(INPUT_FILE):
        print(f"❌ Input file not found: {INPUT_FILE}")
        print("Run generate_trail_maps.py first!")
        return
    
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        trails = json.load(f)
    
    print(f"📊 Loaded {len(trails)} trails")
    
    # Count trails with maps
    trails_with_maps = sum(1 for t in trails if t.get("mapImage"))
    print(f"🗺️  Trails with maps: {trails_with_maps}")
    print()
    
    # Upload in batches
    total = len(trails)
    uploaded = 0
    
    for i in range(0, total, BATCH_SIZE):
        batch = trails[i:i + BATCH_SIZE]
        batch_num = i // BATCH_SIZE + 1
        total_batches = (total + BATCH_SIZE - 1) // BATCH_SIZE
        
        print(f"📦 Batch {batch_num}/{total_batches} ({len(batch)} trails)...", end=" ", flush=True)
        
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
    print("✅ TRAIL UPLOAD COMPLETE!")
    print("=" * 80)
    print(f"📊 SUMMARY:")
    print(f"   Total trails: {total}")
    print(f"   Uploaded: {uploaded}")
    print()
    print("Next step: Open https://go-iceland.web.app to view trails")

if __name__ == "__main__":
    main()
