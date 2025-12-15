#!/usr/bin/env python3
"""Check specific trail in Firestore"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_trail')
db = firestore.client(app)

# Get Laugavegur trail
docs = db.collection('trails').where('name', '==', 'Laugavegur').get()

if docs:
    trail = docs[0].to_dict()
    print(f"\n🥾 Trail: {trail.get('name')}")
    print(f"   ID: {docs[0].id}")
    print(f"   Has mapImage: {'✅' if 'mapImage' in trail else '❌'}")
    if 'mapImage' in trail:
        print(f"   Map URL: {trail['mapImage'][:80]}...")
    print(f"   Keys: {list(trail.keys())[:15]}")
else:
    print("Trail not found")

firebase_admin.delete_app(app)
