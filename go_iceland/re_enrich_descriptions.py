#!/usr/bin/env python3
"""
RE-ENRICH: Add descriptions to places that don't have them
Focuses on service places: restaurants, hotels, hostels, cafes, camping
"""

import json
import os
from typing import Dict

INPUT_FILE = "data/iceland_places_enriched.json"
OUTPUT_FILE = "data/iceland_places_enriched.json"

def generate_description(place: Dict) -> Dict:
    """Generate a basic description based on category"""
    
    category = place.get('category', 'place')
    name = place.get('name', 'This location')
    
    descriptions = {
        'restaurant': f"{name} is a restaurant in Iceland, serving delicious local cuisine in a welcoming atmosphere.",
        'hotel': f"{name} is a hotel in Iceland, providing comfortable accommodations for travelers.",
        'hostel': f"{name} is a hostel in Iceland, offering affordable lodging for backpackers and travelers.",
        'cafe': f"{name} is a café in Iceland, serving coffee, snacks, and light meals.",
        'camping': f"{name} is a camping area in Iceland, providing a place for tents and campers to stay overnight.",
        'shopping': f"{name} is a shop in Iceland, offering goods and services to visitors and locals.",
        'museum': f"{name} is a museum in Iceland, showcasing cultural and historical exhibits.",
        'landmark': f"{name} is a notable landmark in Iceland worth visiting.",
        'viewpoint': f"{name} offers stunning views of Iceland's natural beauty.",
        'hot_spring': f"{name} is a natural hot spring in Iceland, offering warm geothermal waters surrounded by beautiful landscapes.",
        'volcano': f"{name} is a volcano in Iceland, part of the country's dramatic volcanic landscape.",
        'cave': f"{name} is a cave in Iceland, offering a unique underground experience.",
        'peak': f"{name} is a mountain peak in Iceland, offering hiking and climbing opportunities.",
        'beach': f"{name} is a beach in Iceland, featuring unique coastal landscapes.",
        'info_center': f"{name} is a tourist information center providing helpful information about the area.",
        'parking': f"{name} is a parking area providing convenient access to nearby attractions.",
        'other': f"{name} is a notable location in Iceland worth visiting."
    }
    
    desc = descriptions.get(category, f"{name} is a place of interest in Iceland.")
    
    # Create content structure
    content = {
        'en': {
            'description': desc,
            'history': '',
            'tips': 'Visit during daylight hours for the best experience.'
        },
        'is': {
            'description': '',
            'history': '',
            'tips': ''
        },
        'zh': {
            'description': '',
            'history': '',
            'tips': ''
        }
    }
    
    return content

def main():
    print("\n🔄 RE-ENRICHING PLACES WITHOUT DESCRIPTIONS")
    print("=" * 60)
    
    if not os.path.exists(INPUT_FILE):
        print(f"❌ Input file not found: {INPUT_FILE}")
        return
    
    # Load data
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📊 Total places: {len(places)}")
    
    # Find places without descriptions
    without_desc = []
    for place in places:
        has_content = 'content' in place and place.get('content')
        has_description = 'description' in place and place.get('description')
        
        if not has_content and not has_description:
            without_desc.append(place)
    
    print(f"   Places without descriptions: {len(without_desc)}")
    
    if len(without_desc) == 0:
        print("\n✅ All places already have descriptions!")
        return
    
    # Add descriptions
    print(f"\n📝 Adding descriptions to {len(without_desc)} places...")
    
    for i, place in enumerate(without_desc, 1):
        content = generate_description(place)
        place['content'] = content
        
        if i % 500 == 0:
            print(f"   Processed {i}/{len(without_desc)}...")
    
    # Save updated data
    print(f"\n💾 Saving updated data to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(places, f, indent=2, ensure_ascii=False)
    
    # Statistics
    categories_updated = {}
    for place in without_desc:
        cat = place.get('category', 'unknown')
        categories_updated[cat] = categories_updated.get(cat, 0) + 1
    
    print(f"\n✅ SUCCESS! Added descriptions to {len(without_desc)} places")
    print(f"\nBreakdown by category:")
    for cat, count in sorted(categories_updated.items(), key=lambda x: -x[1]):
        print(f"   {cat}: {count}")
    
    print(f"\n📤 Next step: Re-upload to Firestore")
    print(f"   cd firebase")
    print(f"   python upload_enriched_places.py")

if __name__ == "__main__":
    main()
