import firebase_admin
from firebase_admin import credentials, firestore
from collections import Counter

# Initialize
if not firebase_admin._apps:
    cred = credentials.Certificate("../go_iceland/firebase/go-iceland-firebase-adminsdk-key.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()

print("\n📊 Checking Categories in Firestore...")
print("=" * 70)

# Get all places
places_ref = db.collection('places')
places = places_ref.stream()

categories = []
for place in places:
    data = place.to_dict()
    cat = data.get('category', 'unknown')
    categories.append(cat)

# Count categories
category_counts = Counter(categories)

print(f"\n✅ Total places: {len(categories)}")
print(f"✅ Unique categories: {len(category_counts)}")
print("\n" + "=" * 70)

# Sort by count
sorted_cats = sorted(category_counts.items(), key=lambda x: x[1], reverse=True)

print("\n📋 Categories in Firestore (sorted by count):\n")
for cat, count in sorted_cats:
    print(f"   {cat:30} : {count:4} places")

print("\n" + "=" * 70)

# Check which are missing from app
app_categories = [
    'waterfall', 'glacier', 'glacier_lagoon', 'volcano', 'hot_spring',
    'geothermal', 'beach', 'canyon', 'cave', 'lake', 'peak', 'viewpoint',
    'museum', 'landmark', 'church', 'hotel', 'hostel', 'camping',
    'restaurant', 'cafe', 'bar', 'info_center', 'parking', 'shopping',
    'gas_station', 'other'
]

firestore_cats = set(cat for cat, _ in sorted_cats)
app_cats = set(app_categories)

missing_in_app = firestore_cats - app_cats
missing_in_firestore = app_cats - firestore_cats

if missing_in_app:
    print(f"\n⚠️  Categories in Firestore but NOT in app ({len(missing_in_app)}):\n")
    for cat in sorted(missing_in_app):
        count = category_counts[cat]
        print(f"   {cat:30} : {count:4} places")

if missing_in_firestore:
    print(f"\n⚠️  Categories in app but NOT used in Firestore ({len(missing_in_firestore)}):\n")
    for cat in sorted(missing_in_firestore):
        print(f"   {cat}")

print("\n✅ Check complete!\n")
