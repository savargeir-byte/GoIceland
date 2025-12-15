import json

# Check enriched places
print("=" * 80)
print("ENRICHED DATA STATUS")
print("=" * 80)

with open('data/iceland_places_enriched.json', 'r', encoding='utf-8') as f:
    places = json.load(f)

print(f"\n📍 PLACES:")
print(f"   Total enriched: {len(places)}")
places_with_images = [p for p in places if p.get('images')]
print(f"   With images: {len(places_with_images)}")

if places_with_images:
    sample = places_with_images[0]
    print(f"\n🖼️  Sample place with images:")
    print(f"   Name: {sample.get('name')}")
    images = sample.get('images', [])
    print(f"   Images: {len(images)}")
    if images:
        first_img = images[0]
        if isinstance(first_img, dict):
            print(f"   First image: {first_img.get('url', first_img)[:60]}...")
        else:
            print(f"   First image: {str(first_img)[:60]}...")
    desc = sample.get('description', {})
    if isinstance(desc, dict):
        en_desc = desc.get('en', '')
    else:
        en_desc = str(desc)
    print(f"   Description: {en_desc[:80]}...")

# Check trails
with open('data/iceland_trails_enriched.json', 'r', encoding='utf-8') as f:
    trails = json.load(f)

print(f"\n🗺️  TRAILS:")
print(f"   Total: {len(trails)}")
trails_with_maps = [t for t in trails if t.get('mapImage')]
print(f"   With maps: {len(trails_with_maps)}")

if trails_with_maps:
    sample = trails_with_maps[0]
    print(f"\n🗺️  Sample trail with map:")
    print(f"   Name: {sample.get('name')}")
    print(f"   Map URL: {sample.get('mapImage')[:60]}...")
    desc = sample.get('description', {})
    if isinstance(desc, dict):
        en_desc = desc.get('en', '')
    else:
        en_desc = str(desc)
    print(f"   Description: {en_desc[:80]}...")

print("\n" + "=" * 80)
