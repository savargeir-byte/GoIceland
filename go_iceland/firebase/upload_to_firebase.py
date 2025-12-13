"""
Upload enriched POIs and trails to Firebase Firestore.
Uses Firebase Admin SDK with service account key.
"""
import json
import os
import firebase_admin
from firebase_admin import credentials, firestore


def load_json(filepath):
    """Load JSON file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def upload_collection(db, collection_name, items, batch_size=500):
    """
    Upload items to Firestore collection in batches.
    
    Args:
        db: Firestore client
        collection_name: Name of collection
        items: List of items to upload
        batch_size: Max items per batch (Firestore limit is 500)
    """
    print(f"\n📤 Uploading to '{collection_name}' collection...")
    
    total = len(items)
    uploaded = 0
    failed = 0
    
    for i in range(0, total, batch_size):
        batch = db.batch()
        batch_items = items[i:i + batch_size]
        
        for item in batch_items:
            doc_id = item.get('id', f'{collection_name}_{i}')
            doc_ref = db.collection(collection_name).document(doc_id)
            try:
                batch.set(doc_ref, item)
                uploaded += 1
            except Exception as e:
                print(f"   ❌ {collection_name} {doc_id}: {e}")
                failed += 1
        
        try:
            batch.commit()
            print(f"   ✅ Batch {i//batch_size + 1}: {len(batch_items)} items")
        except Exception as e:
            print(f"   ❌ Batch {i//batch_size + 1} failed: {e}")
            failed += len(batch_items)
    
    print(f"\n✅ {collection_name}: {uploaded} uploaded, {failed} failed")
    return uploaded, failed


def upload_data():
    """Upload enriched POIs and trails to Firebase."""
    print("🔥 FIREBASE UPLOADER")
    print("=" * 60)
    
    # Initialize Firebase Admin
    cred_path = '../travel_super_app/serviceAccountKey.json'
    if not os.path.exists(cred_path):
        print(f"❌ Service account key not found: {cred_path}")
        print("   Download from Firebase Console → Project Settings → Service Accounts")
        return
    
    cred = credentials.Certificate(cred_path)
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    
    # Load data
    print("\n📖 Loading data...")
    pois = load_json('data/iceland_enriched_full.json')
    trails = load_json('data/iceland_trails_flat.json')  # Use flattened trails
    
    print(f"   ✅ {len(pois)} POIs loaded")
    print(f"   ✅ {len(trails)} trails loaded (with flat polylines)")
    
    # Upload POIs
    poi_success, poi_failed = upload_collection(db, 'places', pois)
    
    # Upload trails
    trail_success, trail_failed = upload_collection(db, 'trails', trails)
    
    # Summary
    print("\n" + "=" * 60)
    print("📊 UPLOAD SUMMARY")
    print("=" * 60)
    print(f"📍 Places:  {poi_success} uploaded, {poi_failed} failed")
    print(f"🥾 Trails:  {trail_success} uploaded, {trail_failed} failed")
    print(f"📦 Total:   {poi_success + trail_success} uploaded")
    print("=" * 60)
    
    if poi_failed + trail_failed == 0:
        print("🎉 ALL DATA UPLOADED SUCCESSFULLY!")
        print("🇮🇸 GO ICELAND is now the BEST hiking app á Íslandi!")
    else:
        print(f"⚠️  {poi_failed + trail_failed} items failed")


if __name__ == '__main__':
    upload_data()
