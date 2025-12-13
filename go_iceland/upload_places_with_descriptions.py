#!/usr/bin/env python3
"""
Upload places with descriptions to Firebase Firestore
"""

import json
import sys

try:
    import firebase_admin
    from firebase_admin import credentials, firestore
except ImportError:
    print("❌ Firebase admin SDK vantar")
    print("Settu upp með: pip install firebase-admin")
    sys.exit(1)


def upload_places_to_firestore():
    """Upload places with descriptions to Firestore"""
    
    print('📁 Hleð inn gögn með lýsingum...')
    with open('iceland_places_master_with_descriptions.json', 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    places = data['places']
    
    # Filter only places with descriptions
    places_with_desc = [p for p in places if p.get('description')]
    print(f'📍 {len(places_with_desc)} staðir með lýsingar (af {len(places)} heildar)')
    
    # Initialize Firebase
    print('\n🔥 Tengist Firebase...')
    try:
        cred = credentials.Certificate('../travel_super_app/android/app/google-services.json')
        firebase_admin.initialize_app(cred)
        print('✅ Firebase initialized')
    except Exception as e:
        print(f'❌ Villa við Firebase init: {e}')
        print('\n💡 TIP: Þú þarft Firebase Service Account credentials')
        print('   Fara á: https://console.firebase.google.com')
        print('   Project Settings > Service Accounts > Generate new private key')
        return
    
    db = firestore.client()
    collection = db.collection('places')
    
    print('\n📤 Uploada staði með lýsingum...')
    uploaded = 0
    failed = 0
    
    for place in places_with_desc:
        try:
            # Prepare data for Firestore
            place_data = {
                'id': place['id'],
                'name': place['name'],
                'category': place['category'],
                'region': place.get('region', ''),
                'lat': place['coordinates']['lat'],
                'lng': place['coordinates']['lng'],
                'description': place['description'],
                'description_is': place.get('description_is', place['description']),
                'rating': place.get('rating', 0),
                'images': place.get('images', []),
                'metadata': place.get('metadata', {}),
            }
            
            # Upload to Firestore
            collection.document(place['id']).set(place_data)
            print(f'✅ {place["name"]} - uploaded')
            uploaded += 1
            
        except Exception as e:
            print(f'❌ {place["name"]} - failed: {e}')
            failed += 1
    
    print(f'\n📊 NIÐURSTÖÐUR:')
    print(f'✅ {uploaded} staðir uploadaðir')
    print(f'❌ {failed} staðir mistókust')
    print('\n✨ Lokið!')


if __name__ == '__main__':
    upload_places_to_firestore()
