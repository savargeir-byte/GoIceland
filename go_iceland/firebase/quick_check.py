from firebase_admin import credentials, firestore
import firebase_admin

cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='test')
db = firestore.client(app)

# Check total count
places = list(db.collection('places').limit(10).stream())
print(f'\n📊 Total places checked: {len(places)}')

# Check different categories
categories = ['restaurant', 'hotel', 'cafe', 'hostel', 'camping']
for cat in categories:
    docs = list(db.collection('places').where('category', '==', cat).limit(3).stream())
    print(f'\n🔸 {cat.upper()}: {len(docs)} found')
    for doc in docs:
        data = doc.to_dict()
        has_content = 'content' in data and 'en' in data.get('content', {})
        has_desc = has_content and 'description' in data['content']['en']
        print(f'   - {data.get("name")}: content.en.description = {has_desc}')

firebase_admin.delete_app(app)
print('\n✅ Done')
