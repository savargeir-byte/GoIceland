"""
Check which places are missing images and descriptions in local data
"""
import json
import os

def check_missing_data():
    """Check all places for missing data"""
    
    # Load local data
    data_path = '../go_iceland/data/iceland_places_master.json'
    if not os.path.exists(data_path):
        data_path = '../data/iceland_places_master.json'
    if not os.path.exists(data_path):
        data_path = '../../go_iceland/data/iceland_places_master.json'
    
    if not os.path.exists(data_path):
        print(f"❌ Cannot find iceland_places_master.json")
        return
    
    with open(data_path, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    missing_images = []
    missing_descriptions = []
    missing_both = []
    complete = []
    
    for place in places:
        name = place.get('name', 'Unknown')
        category = place.get('category', 'unknown')
        
        # Check images
        images = place.get('images', [])
        has_images = len(images) > 0
        
        # Check descriptions
        content = place.get('content', {})
        en_desc = content.get('en', {}).get('description', '')
        zh_desc = content.get('zh', {}).get('description', '')
        is_desc = content.get('is', {}).get('description', '')
        has_descriptions = bool(en_desc or zh_desc or is_desc)
        
        place_info = {
            'name': name,
            'category': category,
            'lat': place.get('latitude'),
            'lng': place.get('longitude'),
            'images_count': len(images),
            'has_en_desc': bool(en_desc),
            'has_zh_desc': bool(zh_desc),
            'has_is_desc': bool(is_desc),
            'osm_id': place.get('osm_id', ''),
            'place_id': place.get('place_id', '')
        }
        
        if not has_images and not has_descriptions:
            missing_both.append(place_info)
        elif not has_images:
            missing_images.append(place_info)
        elif not has_descriptions:
            missing_descriptions.append(place_info)
        else:
            complete.append(place_info)
    
    # Print summary
    print(f"\n{'='*80}")
    print(f"SAMANTEKT - Gögn í Local Database")
    print(f"{'='*80}\n")
    
    print(f"📊 Heildarstaðir: {len(places)}")
    print(f"✅ Fullbúnir (myndir + lýsingar): {len(complete)}")
    print(f"🖼️  Vantar aðeins myndir: {len(missing_images)}")
    print(f"📝 Vantar aðeins lýsingar: {len(missing_descriptions)}")
    print(f"❌ Vantar bæði myndir og lýsingar: {len(missing_both)}")
    
    # Category breakdown for missing images
    print(f"\n{'='*80}")
    print(f"STAÐIR SEM VANTAR MYNDIR (eftir flokkum)")
    print(f"{'='*80}\n")
    
    categories_missing_images = {}
    for place in missing_images + missing_both:
        cat = place['category']
        if cat not in categories_missing_images:
            categories_missing_images[cat] = []
        categories_missing_images[cat].append(place)
    
    for cat in sorted(categories_missing_images.keys()):
        places_list = categories_missing_images[cat]
        print(f"\n{cat.upper()} ({len(places_list)} staðir):")
        for p in places_list[:10]:  # Show first 10
            desc_status = []
            if p['has_en_desc']: desc_status.append('EN')
            if p['has_is_desc']: desc_status.append('IS')
            if p['has_zh_desc']: desc_status.append('ZH')
            desc_str = f" [Lýsingar: {', '.join(desc_status)}]" if desc_status else " [Engar lýsingar]"
            print(f"  - {p['name']}{desc_str}")
        if len(places_list) > 10:
            print(f"  ... og {len(places_list) - 10} til viðbótar")
    
    # Focus on restaurants and hotels
    print(f"\n{'='*80}")
    print(f"VEITINGASTAÐIR OG HÓTEL SEM VANTAR MYNDIR")
    print(f"{'='*80}\n")
    
    restaurants_no_images = [p for p in missing_images + missing_both if p['category'] == 'restaurant']
    hotels_no_images = [p for p in missing_images + missing_both if p['category'] == 'hotel']
    cafes_no_images = [p for p in missing_images + missing_both if p['category'] == 'cafe']
    
    print(f"🍽️  Veitingastaðir án mynda: {len(restaurants_no_images)}")
    for p in restaurants_no_images[:20]:
        print(f"  - {p['name']} ({p['lat']:.4f}, {p['lng']:.4f})")
    if len(restaurants_no_images) > 20:
        print(f"  ... og {len(restaurants_no_images) - 20} til viðbótar")
    
    print(f"\n🏨 Hótel án mynda: {len(hotels_no_images)}")
    for p in hotels_no_images[:20]:
        print(f"  - {p['name']} ({p['lat']:.4f}, {p['lng']:.4f})")
    if len(hotels_no_images) > 20:
        print(f"  ... og {len(hotels_no_images) - 20} til viðbótar")
    
    print(f"\n☕ Kaffihús án mynda: {len(cafes_no_images)}")
    for p in cafes_no_images[:20]:
        print(f"  - {p['name']} ({p['lat']:.4f}, {p['lng']:.4f})")
    if len(cafes_no_images) > 20:
        print(f"  ... og {len(cafes_no_images) - 20} til viðbótar")
    
    # Save detailed report
    report = {
        'summary': {
            'total': len(places),
            'complete': len(complete),
            'missing_images_only': len(missing_images),
            'missing_descriptions_only': len(missing_descriptions),
            'missing_both': len(missing_both)
        },
        'missing_images': missing_images[:100],  # First 100
        'missing_descriptions': missing_descriptions[:100],
        'missing_both': missing_both[:100],
        'restaurants_no_images': restaurants_no_images,
        'hotels_no_images': hotels_no_images,
        'cafes_no_images': cafes_no_images
    }
    
    with open('missing_data_report.json', 'w', encoding='utf-8') as f:
        json.dump(report, f, indent=2, ensure_ascii=False)
    
    print(f"\n{'='*80}")
    print(f"📄 Nákvæm skýrsla vistuð í: scripts/missing_data_report.json")
    print(f"{'='*80}\n")

if __name__ == '__main__':
    check_missing_data()
