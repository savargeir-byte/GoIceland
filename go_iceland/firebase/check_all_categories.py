#!/usr/bin/env python3
"""Get all unique categories from Firestore"""

import firebase_admin
from firebase_admin import credentials, firestore
from collections import Counter

# Initialize
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_cats')
db = firestore.client(app)

# Get ALL places
print("\n📊 Fetching all places from Firestore...")
docs = db.collection('places').get()

print(f"Total places: {len(docs)}")

# Count categories
categories = Counter()
places_by_cat = {}

for doc in docs:
    data = doc.to_dict()
    cat = data.get('category', 'none')
    categories[cat] += 1
    
    if cat not in places_by_cat:
        places_by_cat[cat] = []
    places_by_cat[cat].append(data.get('name', 'Unknown'))

print(f"\n📋 CATEGORIES ({len(categories)} unique):\n")

for cat, count in categories.most_common():
    print(f"  {cat}: {count} places")
    # Show first 3 examples
    examples = places_by_cat[cat][:3]
    for ex in examples:
        print(f"    - {ex}")

firebase_admin.delete_app(app)
