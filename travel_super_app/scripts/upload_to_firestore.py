"""
GO ICELAND - Firestore Uploader
Upload POI data to Firebase Cloud Firestore

Input: places_firestore.json
Output: Firestore /places collection with 2000+ documents

Prerequisites:
1. Firebase project created (go-iceland)
2. serviceAccountKey.json downloaded from Firebase Console
3. Python packages: firebase-admin

Usage:
    python upload_to_firestore.py
    
Options:
    --dry-run: Preview upload without making changes
    --batch-size 500: Number of documents per batch (default: 500)
    --collection places: Target collection name (default: places)
"""

import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1.base_query import FieldFilter
import json
import argparse
from datetime import datetime
from time import sleep

INPUT_FILE = "places_firestore.json"
DEFAULT_BATCH_SIZE = 500

def init_firebase(cred_path="serviceAccountKey.json"):
    """Initialize Firebase Admin SDK"""
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        print("✅ Firebase initialized successfully")
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        print()
        print("Make sure serviceAccountKey.json exists in the scripts/ directory.")
        print("Download it from: Firebase Console → Project Settings → Service Accounts")
        exit(1)

def upload_batch(db, collection_name, places, batch_size=500, dry_run=False):
    """Upload places in batches to Firestore"""
    total = len(places)
    uploaded = 0
    failed = 0
    
    print(f"📤 Uploading {total} places to /{collection_name}")
    print(f"   Batch size: {batch_size}")
    print(f"   Dry run: {dry_run}")
    print()
    
    for i in range(0, total, batch_size):
        batch_places = places[i:i + batch_size]
        batch_num = (i // batch_size) + 1
        total_batches = (total + batch_size - 1) // batch_size
        
        print(f"Batch {batch_num}/{total_batches} ({len(batch_places)} places)...")
        
        if dry_run:
            print("   [DRY RUN] Skipping upload")
            uploaded += len(batch_places)
            continue
        
        try:
            batch = db.batch()
            
            for place in batch_places:
                # Use place ID as document ID for consistency
                doc_id = place.get("id", place.get("name", "unknown"))
                doc_ref = db.collection(collection_name).document(doc_id)
                
                # Add server timestamp
                place["uploadedAt"] = firestore.SERVER_TIMESTAMP
                
                batch.set(doc_ref, place, merge=True)
            
            # Commit batch
            batch.commit()
            uploaded += len(batch_places)
            print(f"   ✅ Uploaded {len(batch_places)} places")
            
            # Rate limiting to avoid overwhelming Firestore
            sleep(0.5)
            
        except Exception as e:
            failed += len(batch_places)
            print(f"   ❌ Batch failed: {e}")
    
    print()
    print("=" * 60)
    print(f"✅ Upload complete!")
    print(f"   Uploaded: {uploaded}")
    print(f"   Failed: {failed}")
    print("=" * 60)
    
    return uploaded, failed

def create_indexes(db, collection_name, dry_run=False):
    """Create recommended Firestore indexes"""
    print()
    print("📋 Recommended Firestore indexes:")
    print()
    
    indexes = [
        "type, region, popularity (DESC)",
        "subtype, region, popularity (DESC)",
        "region, popularity (DESC)",
        "type, popularity (DESC)",
        "quality_score (DESC), popularity (DESC)"
    ]
    
    for idx in indexes:
        print(f"   • {idx}")
    
    print()
    print("⚠️  Create these indexes in Firebase Console:")
    print(f"    Firestore → Indexes → Composite → Add Index")
    print(f"    Collection: {collection_name}")
    print()

def verify_upload(db, collection_name):
    """Verify uploaded data"""
    print("🔍 Verifying upload...")
    print()
    
    try:
        # Count total documents
        docs = db.collection(collection_name).limit(1).stream()
        doc_count = sum(1 for _ in db.collection(collection_name).stream())
        
        print(f"   Total documents: {doc_count}")
        
        # Sample by type
        types = ["natural", "tourism", "historic", "outdoor", "place"]
        for type_name in types:
            count = sum(1 for _ in db.collection(collection_name)
                       .where(filter=FieldFilter("type", "==", type_name))
                       .limit(1000)
                       .stream())
            print(f"   {type_name:15s}: {count:4d}")
        
        print()
        
        # Sample document
        sample = next(db.collection(collection_name).limit(1).stream(), None)
        if sample:
            print("   Sample document:")
            data = sample.to_dict()
            print(f"      ID: {sample.id}")
            print(f"      Name: {data.get('name')}")
            print(f"      Type: {data.get('type')} / {data.get('subtype')}")
            print(f"      Region: {data.get('region')}")
            print(f"      Coordinates: ({data.get('lat')}, {data.get('lng')})")
            print()
        
        return True
    except Exception as e:
        print(f"   ❌ Verification failed: {e}")
        return False

def main():
    """Main upload function"""
    parser = argparse.ArgumentParser(description="Upload POI data to Firestore")
    parser.add_argument("--dry-run", action="store_true", help="Preview without uploading")
    parser.add_argument("--batch-size", type=int, default=DEFAULT_BATCH_SIZE, help="Batch size")
    parser.add_argument("--collection", default="places", help="Target collection name")
    parser.add_argument("--cred", default="serviceAccountKey.json", help="Service account key path")
    args = parser.parse_args()
    
    print("=" * 60)
    print("GO ICELAND - Firestore Uploader")
    print("=" * 60)
    print(f"Input file: {INPUT_FILE}")
    print(f"Collection: /{args.collection}")
    print(f"Batch size: {args.batch_size}")
    print(f"Dry run: {args.dry_run}")
    print("=" * 60)
    print()
    
    # Load data
    print("📂 Loading place data...")
    try:
        with open(INPUT_FILE, "r", encoding="utf-8") as f:
            places = json.load(f)
        print(f"   Loaded {len(places)} places")
        print()
    except FileNotFoundError:
        print(f"❌ File not found: {INPUT_FILE}")
        print("Run transform_pois_for_firestore.py first")
        exit(1)
    
    # Initialize Firebase
    db = init_firebase(args.cred)
    print()
    
    # Upload
    uploaded, failed = upload_batch(
        db, 
        args.collection, 
        places, 
        args.batch_size, 
        args.dry_run
    )
    
    if not args.dry_run and uploaded > 0:
        # Verify
        verify_upload(db, args.collection)
        
        # Index recommendations
        create_indexes(db, args.collection, args.dry_run)
    
    print()
    print("🎉 All done!")
    print()
    print("Next steps:")
    print("1. Create Firestore indexes (see recommendations above)")
    print("2. Update security rules in Firebase Console")
    print("3. Test queries in your Flutter app")
    print("=" * 60)

if __name__ == "__main__":
    main()
