import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase Admin
cred = credentials.Certificate("C:/GitHub/Radio_App/GoIceland/go_iceland/firebase/go-iceland-firebase-adminsdk-key.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

print("\n🗺️ Checking Trail Map Data...")
print("=" * 60)

# Get one trail to inspect
trails_ref = db.collection('trails').limit(3)
trails = trails_ref.stream()

for trail in trails:
    data = trail.to_dict()
    print(f"\n📍 Trail: {data.get('name', 'Unknown')}")
    print(f"   ID: {trail.id}")
    
    # Check for coordinate fields
    print(f"\n   Coordinate fields:")
    print(f"   - start_lat: {data.get('start_lat', 'MISSING')}")
    print(f"   - start_lng: {data.get('start_lng', 'MISSING')}")
    print(f"   - startLat: {data.get('startLat', 'MISSING')}")
    print(f"   - startLng: {data.get('startLng', 'MISSING')}")
    print(f"   - latitude: {data.get('latitude', 'MISSING')}")
    print(f"   - longitude: {data.get('longitude', 'MISSING')}")
    
    # Check polyline
    if 'polyline' in data:
        polyline = data['polyline']
        print(f"\n   ✅ Polyline exists: {len(polyline)} points")
        if len(polyline) > 0:
            print(f"   - First point: {polyline[0]}")
            print(f"   - Last point: {polyline[-1]}")
    else:
        print(f"\n   ❌ No polyline data")
    
    print("-" * 60)

print("\n✅ Check complete!\n")
