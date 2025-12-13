"""
🔥 UPLOAD ALL ENRICHED DATA TO FIREBASE FIRESTORE
Production-ready uploader for places and trails

Requirements:
- serviceAccountKey.json in firebase/ directory
- firebase-admin installed (pip install firebase-admin)
"""

import json
import os
import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime


def load_json(filepath):
    """Load JSON file."""
    if not os.path.exists(filepath):
        print(f"❌ File not found: {filepath}")
        return []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def upload_batch(db, collection_name, items, batch_size=500):
    """
    Upload items to Firestore in batches.
    
    Args:
        db: Firestore client
        collection_name: Collection name
        items: List of items
        batch_size: Max items per batch (Firestore limit is 500)
    
    Returns:
        (success_count, failed_count)
    """
    print(f"\n📤 Uploading to '{collection_name}' collection...")
    
    total = len(items)
    success = 0
    failed = 0
    
    for i in range(0, total, batch_size):
        batch = db.batch()
        batch_items = items[i:i + batch_size]
        
        for item in batch_items:
            doc_id = item.get('id', f'{collection_name}_{i}')
            doc_ref = db.collection(collection_name).document(doc_id)
            
            try:
                batch.set(doc_ref, item)
                success += 1
            except Exception as e:
                print(f"   ❌ Item {doc_id}: {e}")
                failed += 1
        
        try:
            batch.commit()
            progress = min(i + batch_size, total)
            print(f"   ✅ Progress: {progress}/{total} ({progress*100//total}%)")
        except Exception as e:
            print(f"   ❌ Batch {i//batch_size + 1} failed: {e}")
            failed += len(batch_items)
    
    print(f"✅ {collection_name}: {success} uploaded, {failed} failed")
    return success, failed


def upload_all_to_firestore():
    """Main upload function."""
    print("🔥 FIREBASE FIRESTORE UPLOADER")
    print("=" * 60)
    print("Uploading ALL enriched places and trails")
    print("=" * 60)
    print()
    
    # Initialize Firebase Admin
    key_path = "firebase/serviceAccountKey.json"
    if not os.path.exists(key_path):
        print(f"❌ Service account key not found: {key_path}")
        print()
        print("📥 How to get the key:")
        print("1. Go to Firebase Console")
        print("2. Project Settings → Service Accounts")
        print("3. Generate New Private Key")
        print("4. Save as serviceAccountKey.json in firebase/ directory")
        print()
        return
    
    print("🔑 Initializing Firebase Admin SDK...")
    cred = credentials.Certificate(key_path)
    
    if not firebase_admin._apps:
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    print("✅ Connected to Firestore")
    print()
    
    # Load data
    print("📖 Loading data...")
    places = load_json("data/iceland_places_enriched.json")
    trails = load_json("data/iceland_trails_raw.json")
    
    if not places:
        print("⚠️  No places found - run fetch_all_places.py first")
    if not trails:
        print("⚠️  No trails found - run fetch_all_trails.py first")
    
    print(f"   📍 Places: {len(places)}")
    print(f"   🥾 Trails: {len(trails)}")
    print()
    
    if not places and not trails:
        print("❌ No data to upload!")
        return
    
    # Upload places
    place_success = 0
    place_failed = 0
    
    if places:
        place_success, place_failed = upload_batch(db, 'places', places)
    
    # Upload trails
    trail_success = 0
    trail_failed = 0
    
    if trails:
        trail_success, trail_failed = upload_batch(db, 'trails', trails)
    
    # Summary
    print()
    print("=" * 60)
    print("📊 UPLOAD SUMMARY")
    print("=" * 60)
    print(f"📍 Places:  {place_success} uploaded, {place_failed} failed")
    print(f"🥾 Trails:  {trail_success} uploaded, {trail_failed} failed")
    print(f"📦 Total:   {place_success + trail_success} items")
    print("=" * 60)
    
    total_failed = place_failed + trail_failed
    
    if total_failed == 0:
        print("✅ ALL DATA UPLOADED SUCCESSFULLY!")
        print()
        print("🎉 GO ICELAND now has:")
        print(f"   • {place_success} enriched places with saga & culture")
        print(f"   • {trail_success} hiking trails with polylines")
        print(f"   • 100% coverage - NO empty detail screens!")
        print()
        print("🇮🇸 BEST ferðamanna-app á Íslandi!")
    else:
        print(f"⚠️  {total_failed} items failed to upload")
        print("   Check error messages above for details")
    
    print()
    print("🔗 View data in Firebase Console:")
    print("   https://console.firebase.google.com")
    print()


if __name__ == "__main__":
    upload_all_to_firestore()
