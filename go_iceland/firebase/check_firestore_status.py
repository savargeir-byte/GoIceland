#!/usr/bin/env python3
"""Check Firestore database status"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Count documents
places_count = len(db.collection('places').get())
trails_count = len(db.collection('trails').get())

print(f"\n📊 FIRESTORE STATUS:")
print(f"  Places: {places_count} documents")
print(f"  Trails: {trails_count} documents")

# Sample one place to see structure
if places_count > 0:
    sample = db.collection('places').limit(1).get()[0]
    data = sample.to_dict()
    print(f"\n📍 Sample place: {data.get('name', 'Unknown')}")
    print(f"  Category: {data.get('category', 'N/A')}")
    print(f"  Images: {len(data.get('images', []))} images")
    has_desc = 'content' in data or 'description' in data
    print(f"  Description: {'✅' if has_desc else '❌'}")

# Sample one trail to see structure
if trails_count > 0:
    sample = db.collection('trails').limit(1).get()[0]
    data = sample.to_dict()
    print(f"\n🥾 Sample trail: {data.get('name', 'Unknown')}")
    print(f"  Map: {'✅' if data.get('mapImage') or data.get('map_preview') else '❌'}")
    print(f"  Images: {len(data.get('images', []))} images")
    has_desc = 'content' in data or 'description' in data
    print(f"  Description: {'✅' if has_desc else '❌'}")

print()
