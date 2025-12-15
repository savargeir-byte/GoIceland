"""
Upload enriched top places to Firebase Firestore
"""
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os
from pathlib import Path

def init_firebase():
    """Initialize Firebase Admin SDK"""
    # Try multiple possible locations for service account
    possible_paths = [
        Path("firebase/serviceAccountKey.json"),
        Path("../firebase/serviceAccountKey.json"),
        Path("serviceAccountKey.json")
    ]
    
    service_account = None
    for path in possible_paths:
        if path.exists():
            service_account = str(path)
            break
    
    if not service_account:
        print("❌ Service account key not found!")
        print("Please add serviceAccountKey.json to firebase/ folder")
        return None
    
    try:
        # Close existing app if any
        try:
            firebase_admin.delete_app(firebase_admin.get_app())
        except:
            pass
        
        cred = credentials.Certificate(service_account)
        firebase_admin.initialize_app(cred)
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization failed: {e}")
        return None

def upload_places(db, places_data):
    """Upload places to Firestore"""
    batch = db.batch()
    count = 0
    
    for place_id, place_data in places_data.items():
        doc_ref = db.collection('places').document(place_id)
        batch.set(doc_ref, place_data, merge=True)
        count += 1
        
        # Commit every 500 docs (Firestore limit)
        if count % 500 == 0:
            batch.commit()
            print(f'   💾 Committed {count} places')
            batch = db.batch()
    
    # Commit remaining
    if count % 500 != 0:
        batch.commit()
    
    return count

def main():
    print('🔥 UPLOADING TO FIREBASE')
    print('=' * 60)
    
    # Initialize Firebase
    db = init_firebase()
    if not db:
        return
    
    print('✅ Firebase connected')
    
    # Load enriched data
    input_file = Path('data/firestore_top_places.json')
    if not input_file.exists():
        print(f'❌ File not found: {input_file}')
        print('Run enrich_and_upload_top.py first')
        return
    
    with open(input_file, 'r', encoding='utf-8') as f:
        places_data = json.load(f)
    
    print(f'\n📦 Loaded {len(places_data)} places from {input_file}')
    print(f'🚀 Uploading to Firestore...\n')
    
    count = upload_places(db, places_data)
    
    print(f'\n✅ SUCCESS!')
    print(f'📊 Uploaded {count} places to Firebase')
    print(f'🌐 Check Firebase Console to verify')

if __name__ == '__main__':
    main()
