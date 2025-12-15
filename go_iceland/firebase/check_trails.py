#!/usr/bin/env python3
"""Check trail descriptions in Firestore"""

from firebase_admin import credentials, firestore
import firebase_admin

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_trails')
db = firestore.client(app)

print("📊 CHECKING TRAIL DESCRIPTIONS")
print("=" * 60)

# Get all trails
trails_ref = db.collection('trails')
all_trails = list(trails_ref.stream())

print(f"\n✨ Total trails: {len(all_trails)}")

# Count trails with/without descriptions
with_desc = 0
without_desc = 0
with_content = 0

print("\n📝 SAMPLE TRAILS:\n")
for i, trail_doc in enumerate(all_trails[:10]):
    trail = trail_doc.to_dict()
    name = trail.get('name', 'Unnamed')
    
    # Check for description field
    has_description = 'description' in trail and trail.get('description')
    
    # Check for content.en.description
    has_content_desc = False
    if 'content' in trail:
        content = trail.get('content', {})
        if isinstance(content, dict) and 'en' in content:
            en_content = content.get('en', {})
            if isinstance(en_content, dict):
                has_content_desc = 'description' in en_content and en_content.get('description')
    
    # Get description text
    desc_text = ""
    if has_description:
        desc_text = trail.get('description', '')
    elif has_content_desc:
        desc_text = trail.get('content', {}).get('en', {}).get('description', '')
    
    status = "✅" if (has_description or has_content_desc) else "❌"
    
    print(f"{status} {i+1}. {name}")
    print(f"   Description field: {has_description}")
    print(f"   Content.en.description: {has_content_desc}")
    if desc_text:
        preview = desc_text[:80] + "..." if len(desc_text) > 80 else desc_text
        print(f"   Preview: {preview}")
    else:
        print(f"   Preview: NONE")
    print()

# Count all
print("\n📊 STATISTICS:")
print("=" * 60)
for trail_doc in all_trails:
    trail = trail_doc.to_dict()
    
    has_description = 'description' in trail and trail.get('description')
    has_content_desc = False
    
    if 'content' in trail:
        content = trail.get('content', {})
        if isinstance(content, dict) and 'en' in content:
            en_content = content.get('en', {})
            if isinstance(en_content, dict):
                has_content_desc = 'description' in en_content and en_content.get('description')
    
    if has_description or has_content_desc:
        with_desc += 1
    else:
        without_desc += 1
    
    if has_content_desc:
        with_content += 1

print(f"✅ Trails with descriptions: {with_desc}/{len(all_trails)} ({with_desc*100//len(all_trails)}%)")
print(f"❌ Trails without descriptions: {without_desc}/{len(all_trails)} ({without_desc*100//len(all_trails) if len(all_trails) > 0 else 0}%)")
print(f"📝 Using content.en.description format: {with_content}")

# Clean up
firebase_admin.delete_app(app)
print("\n✅ Done!")
