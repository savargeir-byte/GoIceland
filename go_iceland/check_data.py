import json
import os

# Check local data
with open('data/iceland_places_master.json', encoding='utf-8') as f:
    places = json.load(f)

print(f'Places í local: {len(places)}')

if places:
    sample = places[0]
    print(f'\nSample place: {sample.get("name")}')
    print(f'Keys: {list(sample.keys())}')
    print(f'Images: {len(sample.get("images", []))}')
    print(f'Content languages: {list(sample.get("content", {}).keys())}')
    
    if sample.get("images"):
        print(f'First image: {sample["images"][0][:100]}...')
    
    if sample.get("content"):
        for lang, content in sample.get("content", {}).items():
            desc = content.get("description", "")
            print(f'{lang} description length: {len(desc)}')

# Check if we have the backup file
if os.path.exists('iceland_places_master.json'):
    with open('iceland_places_master.json', encoding='utf-8') as f:
        backup = json.load(f)
    print(f'\n\nBackup file: {len(backup)} places')
