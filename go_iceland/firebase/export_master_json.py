"""
Script to generate master JSON file from current Firestore data
Run this to create the initial iceland_places_master.json
"""
import firebase_admin
from firebase_admin import credentials, firestore
import json
from datetime import datetime

# Initialize Firebase
cred = credentials.Certificate("./firebase/serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

print("🔥 Exporting Firestore data to master JSON...")

# Fetch all places
places_ref = db.collection('places')
places_snapshot = places_ref.stream()

places_list = []

for doc in places_snapshot:
    data = doc.to_dict()
    
    # Convert Firestore data to JSON-friendly format
    place = {
        "id": doc.id,
        "name": data.get("name"),
        "category": data.get("category"),
        "region": data.get("region"),
        "coordinates": {
            "lat": data.get("lat"),
            "lng": data.get("lng")
        },
        "description": data.get("description"),
        "rating": data.get("rating") or data.get("popularity"),
        "images": data.get("images", []),
        "metadata": {}
    }
    
    # Add optional metadata
    if data.get("website"):
        place["metadata"]["website"] = data["website"]
    if data.get("phone"):
        place["metadata"]["phone"] = data["phone"]
    if data.get("stars"):
        place["metadata"]["stars"] = data["stars"]
    if data.get("cuisine"):
        place["metadata"]["cuisine"] = data["cuisine"]
    if data.get("opening_hours"):
        place["metadata"]["opening_hours"] = data["opening_hours"]
    if data.get("difficulty"):
        place["metadata"]["difficulty"] = data["difficulty"]
    
    places_list.append(place)

# Create master JSON
master_data = {
    "updated": datetime.utcnow().isoformat() + "Z",
    "version": "1.0",
    "total": len(places_list),
    "places": places_list
}

# Save to file
output_file = "iceland_places_master.json"
with open(output_file, "w", encoding="utf-8") as f:
    json.dump(master_data, f, indent=2, ensure_ascii=False)

print(f"✅ Exported {len(places_list)} places to {output_file}")
print(f"\nNext steps:")
print(f"1. Upload {output_file} to a public URL (GitHub, CDN, etc.)")
print(f"2. Update functions/index.js with the URL")
print(f"3. Deploy functions: cd functions && npm install && firebase deploy --only functions")
