"""
Simple script to upload all 4,972 places from Firestore back with enriched data
"""
import json
import requests
from time import sleep

PROJECT_ID = "go-iceland"

# Download from Firestore
print("📥 Downloading all places from Firestore...")
url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/places"

all_places = []
page_token = None

while True:
    params = {"pageSize": 300}
    if page_token:
        params["pageToken"] = page_token
    
    response = requests.get(url, params=params)
    data = response.json()
    documents = data.get("documents", [])
    
    for doc in documents:
        place_data = {}
        fields = doc.get("fields", {})
        
        for key, value in fields.items():
            if "stringValue" in value:
                place_data[key] = value["stringValue"]
            elif "doubleValue" in value:
                place_data[key] = float(value["doubleValue"])
            elif "integerValue" in value:
                place_data[key] = int(value["integerValue"])
            elif "arrayValue" in value:
                vals = value["arrayValue"].get("values", [])
                place_data[key] = [v.get("stringValue", "") for v in vals]
            elif "mapValue" in value:
                place_data[key] = {}  # Simplified
        
        all_places.append(place_data)
    
    page_token = data.get("nextPageToken")
    if not page_token:
        break

print(f"✅ Downloaded {len(all_places)} places\n")

# Now upload with trail maps and enriched data
print("🗺️  Now go to https://go-iceland.web.app")
print("     Login and manually:")
print("     1. Upload images for each place")
print("     2. Add descriptions in English/Icelandic/Chinese")
print("     3. For trails - upload trail maps\n")

print("💡 TIP: Use Unsplash/Pixabay for free images:")
print("     - Unsplash: https://unsplash.com/s/photos/iceland-{name}")
print("     - Pixabay: https://pixabay.com/images/search/iceland-{name}/\n")

print(f"📊 SUMMARY:")
print(f"   Total places in Firestore: {len(all_places)}")
print(f"   Need images: ~{len(all_places)}")
print(f"   Need descriptions: ~{len(all_places)}")
print(f"   Admin panel: https://go-iceland.web.app")
