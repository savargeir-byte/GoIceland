#!/usr/bin/env python3
"""
🔥 Firebase Upload Script - GO ICELAND
Uploads all enriched POIs and trails to Firebase Firestore
Uses Firebase Admin SDK for authenticated uploads
"""

import json
import os
from pathlib import Path
import firebase_admin
from firebase_admin import credentials, firestore

# Paths
SCRIPT_DIR = Path(__file__).parent
DATA_DIR = SCRIPT_DIR.parent / 'data'
SERVICE_ACCOUNT_KEY = SCRIPT_DIR / 'serviceAccountKey.json'

PLACES_JSON = DATA_DIR / 'iceland_enriched_full.json'
TRAILS_JSON = DATA_DIR / 'iceland_trails_encoded.json'  # Using encoded polylines

def load_json(filepath):
    """Load JSON file"""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    if not SERVICE_ACCOUNT_KEY.exists():
        print(f"❌ Service account key not found: {SERVICE_ACCOUNT_KEY}")
        print("   Download from Firebase Console → Project Settings → Service Accounts")
        return None
    
    try:
        cred = credentials.Certificate(str(SERVICE_ACCOUNT_KEY))
        firebase_admin.initialize_app(cred)
        print("✅ Firebase Admin SDK initialized")
        return firestore.client()
    except Exception as e:
        print(f"❌ Firebase initialization error: {e}")
        return None

def upload_places(db, places_data):
    """Upload POIs to Firestore /places collection"""
    print(f"\n📍 Uploading {len(places_data)} places...")
    
    success_count = 0
    error_count = 0
    
    for place in places_data:
        try:
            # Use place ID as document ID
            doc_id = place.get('id', f"place_{success_count}")
            
            # Upload to Firestore
            db.collection('places').document(doc_id).set(place)
            
            success_count += 1
            print(f"   ✅ {place['name']} ({doc_id})")
            
        except Exception as e:
            error_count += 1
            print(f"   ❌ {place.get('name', 'Unknown')}: {e}")
    
    print(f"\n✅ Places upload complete: {success_count} success, {error_count} errors")
    return success_count, error_count

def upload_trails(db, trails_data):
    """Upload trails to Firestore /trails collection"""
    print(f"\n🥾 Uploading {len(trails_data)} trails...")
    
    success_count = 0
    error_count = 0
    
    for trail in trails_data:
        try:
            # Use trail ID as document ID
            doc_id = trail.get('id', f"trail_{success_count}")
            
            # Upload to Firestore
            db.collection('trails').document(doc_id).set(trail)
            
            success_count += 1
            
            # Progress indicator every 50 trails
            if success_count % 50 == 0:
                print(f"   ✅ {success_count}/{len(trails_data)} trails uploaded...")
            
        except Exception as e:
            error_count += 1
            print(f"   ❌ Trail {trail.get('id', 'Unknown')}: {e}")
    
    print(f"\n✅ Trails upload complete: {success_count} success, {error_count} errors")
    return success_count, error_count

def main():
    print("=" * 60)
    print("🔥 FIREBASE UPLOAD - GO ICELAND")
    print("=" * 60)
    
    # Load data
    print("\n📖 Loading data...")
    
    if not PLACES_JSON.exists():
        print(f"❌ Places file not found: {PLACES_JSON}")
        return
    
    if not TRAILS_JSON.exists():
        print(f"❌ Trails file not found: {TRAILS_JSON}")
        return
    
    places = load_json(PLACES_JSON)
    trails = load_json(TRAILS_JSON)
    
    print(f"   ✅ {len(places)} POIs loaded")
    print(f"   ✅ {len(trails)} trails loaded")
    
    # Initialize Firebase
    print("\n🔥 Initializing Firebase...")
    db = initialize_firebase()
    
    if not db:
        print("\n❌ Failed to initialize Firebase. Exiting.")
        return
    
    # Confirm upload
    print("\n" + "=" * 60)
    print("📤 READY TO UPLOAD:")
    print(f"   📍 {len(places)} places with:")
    print("      • Icelandic Wikipedia descriptions")
    print("      • Services (parking, toilet, etc.)")
    print("      • Visit info (best time, crowds, duration)")
    print("      • Images (hero, thumbnail, gallery)")
    print("      • Ratings (Google, TripAdvisor)")
    print(f"   🥾 {len(trails)} trails with:")
    print("      • Full polylines for map rendering")
    print("      • Distance, duration, elevation")
    print("      • Difficulty classification")
    print("      • Start/end coordinates")
    print("      • Region assignments")
    print("=" * 60)
    
    confirm = input("\n⚠️  Upload to Firebase Firestore? (yes/no): ").strip().lower()
    
    if confirm not in ['yes', 'y']:
        print("❌ Upload cancelled")
        return
    
    # Upload places
    places_success, places_errors = upload_places(db, places)
    
    # Upload trails
    trails_success, trails_errors = upload_trails(db, trails)
    
    # Summary
    print("\n" + "=" * 60)
    print("🎉 UPLOAD COMPLETE!")
    print("=" * 60)
    print(f"📍 Places: {places_success}/{len(places)} uploaded")
    print(f"🥾 Trails: {trails_success}/{len(trails)} uploaded")
    print(f"❌ Total errors: {places_errors + trails_errors}")
    print("\n✅ Verify at: https://console.firebase.google.com/project/go-iceland/firestore")
    print("\n🇮🇸 GO ICELAND - Best hiking app á Íslandi!")

if __name__ == '__main__':
    main()
