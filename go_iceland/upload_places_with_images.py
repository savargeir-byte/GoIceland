#!/usr/bin/env python3
"""
Upload mock places with Unsplash images to Firebase Firestore
This ensures the app has data with proper images
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json

# Mock data with Unsplash images
PLACES_WITH_IMAGES = [
    # Waterfalls
    {
        "id": "mock_skogafoss",
        "name": "Skógafoss",
        "category": "waterfall",
        "type": "waterfall",
        "lat": 63.5321,
        "lon": -19.5117,
        "latitude": 63.5321,
        "longitude": -19.5117,
        "rating": 4.9,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800",
        "images": ["https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800"]
    },
    {
        "id": "mock_gullfoss",
        "name": "Gullfoss",
        "category": "waterfall",
        "type": "waterfall",
        "lat": 64.3271,
        "lon": -20.1211,
        "latitude": 64.3271,
        "longitude": -20.1211,
        "rating": 4.9,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800",
        "images": ["https://images.unsplash.com/photo-1504893524553-b855bce32c67?w=800"]
    },
    {
        "id": "mock_seljalandsfoss",
        "name": "Seljalandsfoss",
        "category": "waterfall",
        "type": "waterfall",
        "lat": 63.6156,
        "lon": -19.9889,
        "latitude": 63.6156,
        "longitude": -19.9889,
        "rating": 4.8,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800",
        "images": ["https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800"]
    },
    {
        "id": "mock_dettifoss",
        "name": "Dettifoss",
        "category": "waterfall",
        "type": "waterfall",
        "lat": 65.8144,
        "lon": -16.3847,
        "latitude": 65.8144,
        "longitude": -16.3847,
        "rating": 4.8,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=800",
        "images": ["https://images.unsplash.com/photo-1533738363-b7f9aef128ce?w=800"]
    },
    # Hot Springs
    {
        "id": "mock_blue_lagoon",
        "name": "Blue Lagoon",
        "category": "hot_spring",
        "type": "hot_spring",
        "lat": 63.8799,
        "lon": -22.4495,
        "latitude": 63.8799,
        "longitude": -22.4495,
        "rating": 4.7,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1578271887552-5ac3a72752bc?w=800",
        "images": ["https://images.unsplash.com/photo-1578271887552-5ac3a72752bc?w=800"]
    },
    {
        "id": "mock_geysir",
        "name": "Geysir",
        "category": "geyser",
        "type": "geyser",
        "lat": 64.3103,
        "lon": -20.3031,
        "latitude": 64.3103,
        "longitude": -20.3031,
        "rating": 4.6,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800",
        "images": ["https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=800"]
    },
    # Glaciers
    {
        "id": "mock_jokulsarlon",
        "name": "Jökulsárlón",
        "category": "glacier_lagoon",
        "type": "glacier_lagoon",
        "lat": 64.0486,
        "lon": -16.1799,
        "latitude": 64.0486,
        "longitude": -16.1799,
        "rating": 4.9,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800",
        "images": ["https://images.unsplash.com/photo-1531366936337-7c912a4589a7?w=800"]
    },
    # Beaches
    {
        "id": "mock_reynisfjara",
        "name": "Reynisfjara",
        "category": "beach",
        "type": "beach",
        "lat": 63.4045,
        "lon": -19.0447,
        "latitude": 63.4045,
        "longitude": -19.0447,
        "rating": 4.8,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800",
        "images": ["https://images.unsplash.com/photo-1520208422220-d12a3c588e6c?w=800"]
    },
    {
        "id": "mock_diamond_beach",
        "name": "Diamond Beach",
        "category": "beach",
        "type": "beach",
        "lat": 64.0425,
        "lon": -16.1764,
        "latitude": 64.0425,
        "longitude": -16.1764,
        "rating": 4.9,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800",
        "images": ["https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800"]
    },
    # Viewpoints
    {
        "id": "mock_kirkjufell",
        "name": "Kirkjufell",
        "category": "viewpoint",
        "type": "viewpoint",
        "lat": 64.9244,
        "lon": -23.3111,
        "latitude": 64.9244,
        "longitude": -23.3111,
        "rating": 4.8,
        "country": "IS",
        "image": "https://images.unsplash.com/photo-1483354483454-4cd359948304?w=800",
        "images": ["https://images.unsplash.com/photo-1483354483454-4cd359948304?w=800"]
    },
    # Restaurants
    {
        "id": "mock_grillmarket",
        "name": "Grillmarkaðurinn",
        "category": "restaurant",
        "type": "restaurant",
        "lat": 64.1466,
        "lon": -21.9426,
        "latitude": 64.1466,
        "longitude": -21.9426,
        "rating": 4.7,
        "country": "IS",
        "open": "17:00-23:00",
        "image": "https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800",
        "images": ["https://images.unsplash.com/photo-1544148103-0773bf10d330?w=800"]
    },
    {
        "id": "mock_dill",
        "name": "Dill Restaurant",
        "category": "restaurant",
        "type": "restaurant",
        "lat": 64.1465,
        "lon": -21.9426,
        "latitude": 64.1465,
        "longitude": -21.9426,
        "rating": 4.6,
        "country": "IS",
        "open": "18:00-22:00",
        "image": "https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800",
        "images": ["https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=800"]
    },
    # Cafes
    {
        "id": "mock_reykjavik_roasters",
        "name": "Reykjavík Roasters",
        "category": "cafe",
        "type": "cafe",
        "lat": 64.1466,
        "lon": -21.9350,
        "latitude": 64.1466,
        "longitude": -21.9350,
        "rating": 4.7,
        "country": "IS",
        "open": "08:00-17:00",
        "image": "https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800",
        "images": ["https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800"]
    },
]


def upload_places_to_firestore():
    """Upload places with images to Firestore"""
    
    # Initialize Firebase
    if not firebase_admin._apps:
        cred = credentials.Certificate('../travel_super_app/android/app/google-services.json')
        firebase_admin.initialize_app(cred)
    
    db = firestore.client()
    collection = db.collection('places')
    
    print(f"🔥 Uploading {len(PLACES_WITH_IMAGES)} places to Firestore...")
    
    batch = db.batch()
    for i, place in enumerate(PLACES_WITH_IMAGES):
        doc_ref = collection.document(place['id'])
        batch.set(doc_ref, place, merge=True)
        
        if (i + 1) % 10 == 0:
            print(f"   Batched {i + 1}/{len(PLACES_WITH_IMAGES)} places...")
    
    batch.commit()
    print(f"✅ Successfully uploaded {len(PLACES_WITH_IMAGES)} places with images!")
    
    # Verify
    docs = collection.limit(5).stream()
    print("\n📋 Sample places in Firestore:")
    for doc in docs:
        data = doc.to_dict()
        has_image = 'image' in data and data['image']
        print(f"   • {data.get('name', 'Unknown')} - Image: {'✅' if has_image else '❌'}")


if __name__ == "__main__":
    upload_places_to_firestore()
