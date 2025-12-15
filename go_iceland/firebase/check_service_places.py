#!/usr/bin/env python3
"""Check if restaurants, hotels, hostels, camping have descriptions"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_places')
db = firestore.client(app)

categories_to_check = {
    'restaurant': 'Veitingastaðir',
    'hotel': 'Hótel',
    'hostel': 'Gistiheimili',
    'camping': 'Tjaldsvæði',
    'cafe': 'Kaffihús'
}

print("\n📋 DESCRIPTION STATUS BY CATEGORY:\n")

for cat_id, cat_name in categories_to_check.items():
    docs = db.collection('places').where('category', '==', cat_id).get()
    
    total = len(docs)
    with_desc = 0
    with_images = 0
    without_anything = 0
    
    samples = []
    
    for doc in docs:
        data = doc.to_dict()
        name = data.get('name', 'Unknown')
        
        # Check description
        has_desc = False
        desc_text = None
        
        if 'content' in data:
            content = data.get('content', {})
            if isinstance(content, dict):
                if 'en' in content:
                    desc_text = content['en'].get('description', '')
                elif 'description' in content:
                    desc_text = content.get('description', '')
                has_desc = bool(desc_text and len(desc_text) > 20)
        elif 'description' in data:
            desc_text = data.get('description', '')
            has_desc = bool(desc_text and len(desc_text) > 20)
        
        # Check images
        images = data.get('images', [])
        has_images = len(images) > 0
        
        if has_desc:
            with_desc += 1
        if has_images:
            with_images += 1
        if not has_desc and not has_images:
            without_anything += 1
            if len(samples) < 5:
                samples.append(name)
    
    print(f"🔸 {cat_name.upper()} ({cat_id}):")
    print(f"   Total: {total}")
    print(f"   With descriptions: {with_desc} ({with_desc*100//total if total > 0 else 0}%)")
    print(f"   With images: {with_images} ({with_images*100//total if total > 0 else 0}%)")
    print(f"   Missing both: {without_anything} ({without_anything*100//total if total > 0 else 0}%)")
    
    if samples:
        print(f"   Examples without data:")
        for s in samples:
            print(f"     - {s}")
    print()

firebase_admin.delete_app(app)
