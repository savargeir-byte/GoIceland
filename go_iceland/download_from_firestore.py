"""
Download all data from Firestore to local JSON files
"""
import json
import os
import sys

# We'll use Firebase REST API to download data
import requests

PROJECT_ID = "go-iceland"
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

def download_collection(collection_name):
    """Download entire collection from Firestore"""
    print(f"\n📥 Downloading {collection_name}...")
    
    url = f"{BASE_URL}/{collection_name}"
    
    all_docs = []
    page_token = None
    
    while True:
        params = {"pageSize": 300}
        if page_token:
            params["pageToken"] = page_token
        
        response = requests.get(url, params=params)
        
        if response.status_code != 200:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return None
        
        data = response.json()
        documents = data.get("documents", [])
        
        print(f"  Downloaded {len(documents)} documents...")
        
        for doc in documents:
            all_docs.append(parse_firestore_doc(doc))
        
        page_token = data.get("nextPageToken")
        if not page_token:
            break
    
    print(f"✅ Total: {len(all_docs)} documents")
    return all_docs

def parse_firestore_doc(doc):
    """Parse Firestore document to normal Python dict"""
    fields = doc.get("fields", {})
    result = {}
    
    for key, value in fields.items():
        result[key] = parse_firestore_value(value)
    
    # Add document ID
    doc_path = doc.get("name", "")
    doc_id = doc_path.split("/")[-1]
    result["id"] = doc_id
    
    return result

def parse_firestore_value(value):
    """Parse Firestore value to Python value"""
    if "stringValue" in value:
        return value["stringValue"]
    elif "integerValue" in value:
        return int(value["integerValue"])
    elif "doubleValue" in value:
        return float(value["doubleValue"])
    elif "booleanValue" in value:
        return value["booleanValue"]
    elif "arrayValue" in value:
        values = value["arrayValue"].get("values", [])
        return [parse_firestore_value(v) for v in values]
    elif "mapValue" in value:
        fields = value["mapValue"].get("fields", {})
        return {k: parse_firestore_value(v) for k, v in fields.items()}
    elif "nullValue" in value:
        return None
    elif "timestampValue" in value:
        return value["timestampValue"]
    else:
        return None

def main():
    print("="*80)
    print("🔄 DOWNLOADING ALL DATA FROM FIRESTORE")
    print("="*80)
    
    # Download places
    places = download_collection("places")
    if places:
        # Save to data directory
        os.makedirs("data", exist_ok=True)
        with open("data/iceland_places_master.json", "w", encoding="utf-8") as f:
            json.dump(places, f, indent=2, ensure_ascii=False)
        print(f"\n💾 Saved {len(places)} places to data/iceland_places_master.json")
        
        # Check what we got
        with_images = sum(1 for p in places if p.get("images") and len(p.get("images", [])) > 0)
        with_content = sum(1 for p in places if p.get("content"))
        
        print(f"\n📊 SUMMARY:")
        print(f"  Total places: {len(places)}")
        print(f"  With images: {with_images}")
        print(f"  With content: {with_content}")
    
    # Download trails
    trails = download_collection("trails")
    if trails:
        with open("data/iceland_trails.json", "w", encoding="utf-8") as f:
            json.dump(trails, f, indent=2, ensure_ascii=False)
        print(f"\n💾 Saved {len(trails)} trails to data/iceland_trails.json")
        
        # Check trails
        with_images = sum(1 for t in trails if t.get("images") and len(t.get("images", [])) > 0)
        with_map = sum(1 for t in trails if t.get("mapImage") or t.get("map_preview"))
        
        print(f"\n📊 TRAILS SUMMARY:")
        print(f"  Total trails: {len(trails)}")
        print(f"  With images: {with_images}")
        print(f"  With maps: {with_map}")
    
    print("\n" + "="*80)
    print("✅ DOWNLOAD COMPLETE!")
    print("="*80)

if __name__ == "__main__":
    main()
