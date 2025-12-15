import json
import os

files_to_check = [
    'c:/GitHub/Radio_App/GoIceland/travel_super_app/places_with_images.json',
    'c:/GitHub/Radio_App/GoIceland/go_iceland/iceland_places_master_with_descriptions.json',
    'c:/GitHub/Radio_App/GoIceland/go_iceland/firebase/iceland_places_master.json',
]

print("Checking backup files:\n")

for filepath in files_to_check:
    if os.path.exists(filepath):
        with open(filepath, encoding='utf-8') as f:
            data = json.load(f)
        
        # Handle both list and dict formats
        if isinstance(data, list):
            places = data
        elif isinstance(data, dict):
            print(f"📄 {os.path.basename(filepath)}")
            print(f"   Format: Dictionary with {len(data)} keys")
            print()
            continue
        else:
            print(f"❌ Unknown format: {filepath}\n")
            continue
        
        if places:
            sample = places[0]
            has_images = bool(sample.get('images') and len(sample.get('images', [])) > 0)
            has_content = bool(sample.get('content'))
            
            # Count totals
            total_with_images = sum(1 for p in places if p.get('images') and len(p.get('images', [])) > 0)
            total_with_content = sum(1 for p in places if p.get('content'))
            
            print(f"📄 {os.path.basename(filepath)}")
            print(f"   Total: {len(places)} places")
            print(f"   With images: {total_with_images}")
            print(f"   With content: {total_with_content}")
            
            if has_images:
                print(f"   Sample image: {sample['images'][0][:80]}...")
            print()
    else:
        print(f"❌ Not found: {filepath}\n")
