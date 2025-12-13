"""
Quick uploader - Uses existing JSON files to upload to Firestore
"""
import json
import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate("firebase/serviceAccountKey.json")
if not firebase_admin._apps:
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Quick Firebase Upload")
print("=" * 50)

# Load places
print("\n📖 Loading places...")
with open("data/firestore_places.json", 'r', encoding='utf-8') as f:
    places_dict = json.load(f)
places = list(places_dict.values())
print(f"   ✅ Loaded {len(places)} places")

# Load trails
print("\n📖 Loading trails...")
with open("data/firestore_trails.json", 'r', encoding='utf-8') as f:
    trails_dict = json.load(f)
trails = list(trails_dict.values())
print(f"   ✅ Loaded {len(trails)} trails")

# Upload places
print("\n📤 Uploading places...")
batch = db.batch()
count = 0
for place in places:
    if 'id' in place:
        doc_ref = db.collection('places').document(place['id'])
        batch.set(doc_ref, place)
        count += 1
        if count % 500 == 0:
            batch.commit()
            print(f"   ✅ Uploaded {count} places...")
            batch = db.batch()

if count % 500 != 0:
    batch.commit()
print(f"   ✅ Uploaded {count} places total!")

# Upload trails  
print("\n📤 Uploading trails...")
batch = db.batch()
count = 0
for trail in trails:
    if 'id' in trail:
        doc_ref = db.collection('trails').document(trail['id'])
        batch.set(doc_ref, trail)
        count += 1
        if count % 500 == 0:
            batch.commit()
            print(f"   ✅ Uploaded {count} trails...")
            batch = db.batch()

if count % 500 != 0:
    batch.commit()
print(f"   ✅ Uploaded {count} trails total!")

print("\n🎉 UPLOAD COMPLETE!")
