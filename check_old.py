import json

with open('old_places.json', encoding='utf-8') as f:
    data = json.load(f)

print(f'Places: {len(data)}')
if data:
    sample = data[0]
    print(f'Sample name: {sample.get("name")}')
    print(f'Has images: {bool(sample.get("images"))}')
    print(f'Images count: {len(sample.get("images", []))}')
    print(f'Has content: {bool(sample.get("content"))}')
    print(f'Keys: {list(sample.keys())}')
