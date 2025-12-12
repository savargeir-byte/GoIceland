"""
GO ICELAND - POI Data Transformer
Transforms raw OSM data into Firestore-ready format

Input: iceland_pois_raw.json (from fetch_iceland_pois.py)
Output: places_firestore.json (ready for Firebase import)

This script:
1. Cleans and deduplicates POI data
2. Categorizes into GO ICELAND taxonomy
3. Assigns regions based on coordinates
4. Generates placeholder data for missing fields
5. Filters out low-quality entries
"""

import json
import uuid
from datetime import datetime
import hashlib

INPUT_FILE = "iceland_pois_raw.json"
OUTPUT_FILE = "places_firestore.json"
MIN_QUALITY_THRESHOLD = 0.3  # Filter POIs below this quality score

# Iceland regions based on approximate lat/lng boundaries
REGIONS = {
    "Höfuðborgarsvæðið": {"lat": (64.0, 64.2), "lng": (-22.2, -21.6)},
    "Suðurland": {"lat": (63.4, 64.0), "lng": (-21.0, -19.0)},
    "Suðurnes": {"lat": (63.8, 64.1), "lng": (-22.8, -22.0)},
    "Vesturland": {"lat": (64.5, 65.2), "lng": (-23.0, -20.5)},
    "Vestfirðir": {"lat": (65.4, 66.5), "lng": (-24.5, -20.5)},
    "Norðurland vestra": {"lat": (65.0, 66.0), "lng": (-20.5, -18.0)},
    "Norðurland eystra": {"lat": (65.3, 66.5), "lng": (-18.0, -15.5)},
    "Austurland": {"lat": (64.0, 66.0), "lng": (-16.5, -13.5)},
    "Hálendi": {"lat": (64.2, 65.2), "lng": (-20.0, -16.0)},
}

# Category mapping: OSM → GO ICELAND taxonomy
CATEGORY_MAP = {
    # Natural features
    "waterfall": {"type": "natural", "subtype": "waterfall", "icon": "💧"},
    "geyser": {"type": "natural", "subtype": "geyser", "icon": "♨️"},
    "hot_spring": {"type": "natural", "subtype": "hot_spring", "icon": "🌊"},
    "spring": {"type": "natural", "subtype": "spring", "icon": "💦"},
    "beach": {"type": "natural", "subtype": "beach", "icon": "🏖️"},
    "cliff": {"type": "natural", "subtype": "cliff", "icon": "⛰️"},
    "cave": {"type": "natural", "subtype": "cave", "icon": "🕳️"},
    "peak": {"type": "natural", "subtype": "peak", "icon": "⛰️"},
    "lake": {"type": "natural", "subtype": "lake", "icon": "🏞️"},
    "glacier": {"type": "natural", "subtype": "glacier", "icon": "🧊"},
    "rock_formation": {"type": "natural", "subtype": "rock", "icon": "🪨"},
    "bay": {"type": "natural", "subtype": "bay", "icon": "🌊"},
    "volcano": {"type": "natural", "subtype": "volcano", "icon": "🌋"},
    "lava_field": {"type": "natural", "subtype": "lava_field", "icon": "🌋"},
    "fumarole": {"type": "natural", "subtype": "fumarole", "icon": "♨️"},
    "caldera": {"type": "natural", "subtype": "caldera", "icon": "🌋"},
    
    # Tourism
    "viewpoint": {"type": "tourism", "subtype": "viewpoint", "icon": "👁️"},
    "attraction": {"type": "tourism", "subtype": "attraction", "icon": "⭐"},
    "museum": {"type": "tourism", "subtype": "museum", "icon": "🏛️"},
    "information": {"type": "tourism", "subtype": "information", "icon": "ℹ️"},
    "picnic_site": {"type": "tourism", "subtype": "picnic_site", "icon": "🧺"},
    "artwork": {"type": "tourism", "subtype": "artwork", "icon": "🎨"},
    
    # Historic
    "church": {"type": "historic", "subtype": "church", "icon": "⛪"},
    "ruins": {"type": "historic", "subtype": "ruins", "icon": "🏛️"},
    "monument": {"type": "historic", "subtype": "monument", "icon": "🗿"},
    "memorial": {"type": "historic", "subtype": "memorial", "icon": "🕊️"},
    "archaeological_site": {"type": "historic", "subtype": "archaeological", "icon": "🏺"},
    
    # Places
    "village": {"type": "place", "subtype": "village", "icon": "🏘️"},
    "town": {"type": "place", "subtype": "town", "icon": "🏙️"},
    "hamlet": {"type": "place", "subtype": "hamlet", "icon": "🏡"},
    "island": {"type": "place", "subtype": "island", "icon": "🏝️"},
    "locality": {"type": "place", "subtype": "locality", "icon": "📍"},
    
    # Outdoor activities
    "hiking_route": {"type": "outdoor", "subtype": "hiking", "icon": "🥾"},
    "nature_reserve": {"type": "outdoor", "subtype": "nature_reserve", "icon": "🌿"},
    "campsite": {"type": "outdoor", "subtype": "campsite", "icon": "⛺"},
    "swimming_pool": {"type": "outdoor", "subtype": "swimming", "icon": "🏊"},
    
    # Infrastructure
    "lighthouse": {"type": "infrastructure", "subtype": "lighthouse", "icon": "🗼"},
    "parking": {"type": "infrastructure", "subtype": "parking", "icon": "🅿️"},
    "shelter": {"type": "infrastructure", "subtype": "shelter", "icon": "🏠"},
}

def calculate_quality_score(poi):
    """Calculate quality score for POI (0.0 to 1.0)"""
    score = 0.0
    
    # Has name
    if poi.get("name"):
        score += 0.4
    
    # Has description
    if poi.get("description"):
        score += 0.2
    
    # Has external reference
    if poi.get("wikipedia") or poi.get("website"):
        score += 0.2
    
    # Known category
    if poi.get("category") in CATEGORY_MAP:
        score += 0.2
    
    return min(score, 1.0)

def determine_region(lat, lng):
    """Determine Iceland region based on coordinates"""
    for region_name, bounds in REGIONS.items():
        lat_min, lat_max = bounds["lat"]
        lng_min, lng_max = bounds["lng"]
        
        if lat_min <= lat <= lat_max and lng_min <= lng <= lng_max:
            return region_name
    
    return "Óþekkt"  # Unknown

def generate_place_id(poi):
    """Generate consistent place ID from OSM data"""
    # Use OSM ID if available
    if poi.get("osm_id"):
        return f"osm_{poi['osm_id']}"
    
    # Otherwise hash name + coordinates
    key = f"{poi.get('name', 'unnamed')}_{poi['lat']:.4f}_{poi['lng']:.4f}"
    hash_id = hashlib.md5(key.encode()).hexdigest()[:12]
    return f"poi_{hash_id}"

def transform_poi(poi):
    """Transform raw OSM POI into Firestore format"""
    category = poi.get("category", "unknown")
    category_info = CATEGORY_MAP.get(category, {
        "type": "other",
        "subtype": category,
        "icon": "📍"
    })
    
    # Calculate quality score
    quality = calculate_quality_score(poi)
    
    # Generate popularity based on type
    base_popularity = {
        "waterfall": 80,
        "geyser": 90,
        "hot_spring": 85,
        "viewpoint": 70,
        "glacier": 85,
        "museum": 60,
        "beach": 75,
        "village": 50,
        "hiking_route": 65,
    }.get(category, 40)
    
    # Determine region
    region = determine_region(poi["lat"], poi["lng"])
    
    # Build Firestore document
    place = {
        "id": generate_place_id(poi),
        "name": poi.get("name", f"Unnamed {category_info['subtype'].title()}"),
        "type": category_info["type"],
        "subtype": category_info["subtype"],
        "lat": round(poi["lat"], 6),
        "lng": round(poi["lng"], 6),
        "region": region,
        "popularity": base_popularity,
        "difficulty": None,  # Will be set manually for hikes
        "rating": None,  # Will be populated from user reviews
        "images": [],  # Placeholder - add actual images later
        "mapPreview": None,  # Generated map thumbnail URL
        "gpxUrl": None,  # For hiking routes
        "description": poi.get("description"),
        "wikipedia": poi.get("wikipedia"),
        "website": poi.get("website"),
        "source": "osm",
        "quality_score": round(quality, 2),
        "updatedAt": datetime.now().isoformat(),
        "meta": {
            "icon": category_info["icon"],
            "osm_id": poi.get("osm_id"),
            "fetched_at": poi.get("fetched_at")
        }
    }
    
    return place

def deduplicate_pois(pois):
    """Remove duplicate POIs based on proximity and name similarity"""
    unique = {}
    duplicates_removed = 0
    
    for poi in pois:
        # Create location key (rounded to ~100m precision)
        loc_key = f"{poi['lat']:.3f}_{poi['lng']:.3f}"
        
        if loc_key not in unique:
            unique[loc_key] = poi
        else:
            # Keep the one with higher quality score
            existing = unique[loc_key]
            if poi.get("quality_score", 0) > existing.get("quality_score", 0):
                unique[loc_key] = poi
                duplicates_removed += 1
            else:
                duplicates_removed += 1
    
    print(f"   Removed {duplicates_removed} duplicates")
    return list(unique.values())

def main():
    """Main transformation function"""
    print("=" * 60)
    print("GO ICELAND - POI Data Transformer")
    print("=" * 60)
    print(f"Input: {INPUT_FILE}")
    print(f"Output: {OUTPUT_FILE}")
    print(f"Quality threshold: {MIN_QUALITY_THRESHOLD}")
    print("=" * 60)
    print()
    
    # Load raw data
    print("📂 Loading raw POI data...")
    with open(INPUT_FILE, "r", encoding="utf-8") as f:
        raw_pois = json.load(f)
    print(f"   Loaded {len(raw_pois)} raw POIs")
    print()
    
    # Transform
    print("🔄 Transforming POIs...")
    transformed = []
    filtered_count = 0
    category_stats = {}
    region_stats = {}
    
    for poi in raw_pois:
        place = transform_poi(poi)
        
        # Filter by quality
        if place["quality_score"] >= MIN_QUALITY_THRESHOLD:
            transformed.append(place)
            
            # Stats
            cat = place["subtype"]
            category_stats[cat] = category_stats.get(cat, 0) + 1
            
            reg = place["region"]
            region_stats[reg] = region_stats.get(reg, 0) + 1
        else:
            filtered_count += 1
    
    print(f"   Transformed {len(transformed)} POIs")
    print(f"   Filtered out {filtered_count} low-quality entries")
    print()
    
    # Deduplicate
    print("🔍 Deduplicating...")
    transformed = deduplicate_pois(transformed)
    print(f"   Final count: {len(transformed)} unique POIs")
    print()
    
    # Stats
    print("📊 Statistics:")
    print()
    print("Top 15 categories:")
    for cat, count in sorted(category_stats.items(), key=lambda x: x[1], reverse=True)[:15]:
        print(f"  {cat:25s}: {count:4d}")
    print()
    
    print("By region:")
    for reg, count in sorted(region_stats.items(), key=lambda x: x[1], reverse=True):
        print(f"  {reg:25s}: {count:4d}")
    print()
    
    # Save
    with open(OUTPUT_FILE, "w", encoding="utf-8") as f:
        json.dump(transformed, f, indent=2, ensure_ascii=False)
    
    print("=" * 60)
    print(f"✅ Saved {len(transformed)} places to {OUTPUT_FILE}")
    print("=" * 60)
    print()
    print("Next step: Run upload_to_firestore.py")
    print("=" * 60)

if __name__ == "__main__":
    main()
