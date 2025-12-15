"""
Script to check which places are missing images and descriptions in Firestore
"""
import os
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = r'C:\Users\Computer\go-iceland-firebase-adminsdk.json'

import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.ApplicationDefault()
    firebase_admin.initialize_app(cred, {
        'projectId': 'go-iceland'
    })
db = firestore.client()

def check_missing_data():
    """Check all places for missing data"""
    places_ref = db.collection('places')
    places = list(places_ref.stream())
    
    missing_images = []
    missing_descriptions = []
    missing_both = []
    complete = []
    
    for place in places:
        data = place.to_dict()
        place_id = place.id
        name = data.get('name', 'Unknown')
        category = data.get('category', 'unknown')
        
        # Check images
        images = data.get('images', [])
        has_images = len(images) > 0
        
        # Check descriptions
        content = data.get('content', {})
        en_desc = content.get('en', {}).get('description', '')
        zh_desc = content.get('zh', {}).get('description', '')
        is_desc = content.get('is', {}).get('description', '')
        has_descriptions = bool(en_desc or zh_desc or is_desc)
        
        place_info = {
            'id': place_id,
            'name': name,
            'category': category,
            'lat': data.get('latitude'),
            'lng': data.get('longitude'),
            'images_count': len(images),
            'has_en_desc': bool(en_desc),
            'has_zh_desc': bool(zh_desc),
            'has_is_desc': bool(is_desc)
        }
        
        if not has_images and not has_descriptions:
            missing_both.append(place_info)
        elif not has_images:
            missing_images.append(place_info)
        elif not has_descriptions:
            missing_descriptions.append(place_info)
        else:
            complete.append(place_info)
    
    # Print summary
    print(f"\n{'='*80}")
    print(f"SAMANTEKT - Gögn í Firestore")
    print(f"{'='*80}\n")
    
    print(f"📊 Heildarstaðir: {len(places)}")
    print(f"✅ Fullbúnir (myndir + lýsingar): {len(complete)}")
    print(f"🖼️  Vantar aðeins myndir: {len(missing_images)}")
    print(f"📝 Vantar aðeins lýsingar: {len(missing_descriptions)}")
    print(f"❌ Vantar bæði myndir og lýsingar: {len(missing_both)}")
    
    # Category breakdown for missing images
    print(f"\n{'='*80}")
    print(f"STAÐIR SEM VANTAR MYNDIR (eftir flokkum)")
    print(f"{'='*80}\n")
    
    categories_missing_images = {}
    for place in missing_images + missing_both:
        cat = place['category']
        if cat not in categories_missing_images:
            categories_missing_images[cat] = []
        categories_missing_images[cat].append(place)
    
    for cat in sorted(categories_missing_images.keys()):
        places_list = categories_missing_images[cat]
        print(f"\n{cat.upper()} ({len(places_list)} staðir):")
        for p in places_list[:10]:  # Show first 10
            print(f"  - {p['name']}")
        if len(places_list) > 10:
            print(f"  ... og {len(places_list) - 10} til viðbótar")
    
    # Focus on restaurants and hotels
    print(f"\n{'='*80}")
    print(f"VEITINGASTAÐIR OG HÓTEL SEM VANTAR MYNDIR")
    print(f"{'='*80}\n")
    
    restaurants_no_images = [p for p in missing_images + missing_both if p['category'] == 'restaurant']
    hotels_no_images = [p for p in missing_images + missing_both if p['category'] == 'hotel']
    
    print(f"🍽️  Veitingastaðir án mynda: {len(restaurants_no_images)}")
    for p in restaurants_no_images:
        print(f"  - {p['name']} (ID: {p['id']})")
    
    print(f"\n🏨 Hótel án mynda: {len(hotels_no_images)}")
    for p in hotels_no_images:
        print(f"  - {p['name']} (ID: {p['id']})")
    
    # Save detailed report
    report = {
        'summary': {
            'total': len(places),
            'complete': len(complete),
            'missing_images_only': len(missing_images),
            'missing_descriptions_only': len(missing_descriptions),
            'missing_both': len(missing_both)
        },
        'missing_images': missing_images,
        'missing_descriptions': missing_descriptions,
        'missing_both': missing_both,
        'restaurants_no_images': restaurants_no_images,
        'hotels_no_images': hotels_no_images
    }
    
    with open('../data/missing_data_report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*80}")
    print(f"📄 Nákvæm skýrsla vistuð í: data/missing_data_report.json")
    print(f"{'='*80}\n")

if __name__ == '__main__':
    check_missing_data()
