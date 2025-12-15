#!/usr/bin/env python3
"""Check descriptions in Firestore"""

import firebase_admin
from firebase_admin import credentials, firestore

# Initialize
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_desc')
db = firestore.client(app)

# Get sample places by category
categories = ['restaurant', 'cafe', 'hotel', 'waterfall', 'glacier', 'hot_spring']

print("\n📋 CHECKING DESCRIPTIONS IN FIRESTORE:\n")

for category in categories:
    docs = db.collection('places').where('category', '==', category).limit(3).get()
    
    print(f"\n🔸 {category.upper()}:")
    if not docs:
        print(f"  No {category} found")
        continue
    
    for doc in docs:
        data = doc.to_dict()
        name = data.get('name', 'Unknown')
        
        # Check different description fields
        has_content = 'content' in data
        has_description = 'description' in data
        
        images_count = len(data.get('images', []))
        
        desc_text = None
        if has_content:
            content = data.get('content', {})
            if isinstance(content, dict):
                if 'en' in content:
                    desc_text = content['en'].get('description', '')
                elif 'description' in content:
                    desc_text = content.get('description', '')
        elif has_description:
            desc = data.get('description', '')
            desc_text = desc if isinstance(desc, str) else ''
        
        status = "✅" if desc_text and len(desc_text) > 20 else "❌"
        print(f"  {status} {name}")
        print(f"     Images: {images_count}, Desc length: {len(desc_text) if desc_text else 0}")
        if desc_text and len(desc_text) > 0:
            print(f"     Preview: {desc_text[:80]}...")

firebase_admin.delete_app(app)
