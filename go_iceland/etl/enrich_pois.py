"""
GO ICELAND - POI Enrichment
Cleans and enriches raw OSM data with categories, descriptions, and metadata
"""
import json
import hashlib
import re

INPUT = "./data/iceland_raw.json"
OUTPUT = "./data/iceland_clean.json"

CATEGORY_MAP = {
    "waterfall": "waterfall",
    "geyser": "hot_spring",
    "spring": "hot_spring",
    "museum": "museum",
    "restaurant": "restaurant",
    "cafe": "cafe",
    "fast_food": "restaurant",
    "bar": "bar",
    "pub": "bar",
    "viewpoint": "viewpoint",
    "attraction": "landmark",
    "route=hiking": "hiking_route",
    "peak": "peak",
    "volcano": "volcano",
    "hotel": "hotel",
    "guest_house": "guesthouse",
    "hostel": "hostel",
    "motel": "hotel",
    "camp_site": "camping",
    "parking": "parking",
    "beach": "beach",
    "cave_entrance": "cave",
    "information": "info_center",
    "supermarket": "shopping"
}

REGION_MAP = {
    (64.0, 64.5, -22.5, -21.0): "Capital Region",
    (63.8, 64.2, -21.0, -19.0): "South",
    (63.4, 64.0, -19.0, -16.0): "Southeast",
    (64.0, 66.5, -18.0, -13.0): "East",
    (65.0, 66.5, -18.5, -16.5): "North",
    (65.5, 66.5, -20.5, -17.5): "Northeast",
    (64.5, 66.0, -24.0, -20.0): "Northwest",
    (65.0, 66.5, -25.0, -20.5): "Westfjords",
    (64.0, 65.0, -23.0, -20.5): "West"
}

def get_region(lat, lng):
    """Assign region based on coordinates"""
    for (lat_min, lat_max, lng_min, lng_max), region in REGION_MAP.items():
        if lat_min <= lat <= lat_max and lng_min <= lng <= lng_max:
            return region
    return "Other"

def get_category(raw_category):
    """Map raw OSM category to clean category"""
    for k, v in CATEGORY_MAP.items():
        if k in raw_category:
            return v
    return "other"

def generate_id(name, lat, lng):
    """Generate consistent ID from name and coordinates"""
    key = f"{name}_{lat:.4f}_{lng:.4f}".encode("utf-8")
    return hashlib.md5(key).hexdigest()[:12]

def parse_opening_hours(hours_str):
    """Parse OSM opening_hours into structured format"""
    if not hours_str:
        return None
    
    # Handle 24/7
    if hours_str.lower() in ["24/7", "24 hours", "always open"]:
        return {"type": "24/7", "always_open": True}
    
    # Simple format: "Mo-Fr 10:00-18:00"
    day_map = {
        "Mo": "monday", "Tu": "tuesday", "We": "wednesday",
        "Th": "thursday", "Fr": "friday", "Sa": "saturday", "Su": "sunday"
    }
    
    try:
        result = {"type": "structured", "days": {}}
        
        # Split by semicolon for multiple rules
        rules = hours_str.split(";")
        
        for rule in rules:
            rule = rule.strip()
            # Match pattern: "Mo-Fr 10:00-18:00"
            match = re.match(r"([A-Za-z\-,]+)\s+(\d{1,2}:\d{2})-(\d{1,2}:\d{2})", rule)
            
            if match:
                day_part = match.group(1)
                open_time = match.group(2)
                close_time = match.group(3)
                
                # Parse days
                days = []
                if "-" in day_part:
                    # Range: Mo-Fr
                    start, end = day_part.split("-")
                    day_list = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    start_idx = day_list.index(start)
                    end_idx = day_list.index(end)
                    days = [day_map[d] for d in day_list[start_idx:end_idx+1]]
                else:
                    # Single day or comma-separated
                    day_codes = day_part.replace(",", " ").split()
                    days = [day_map.get(d, d.lower()) for d in day_codes if d in day_map]
                
                # Apply to all matching days
                for day in days:
                    result["days"][day] = [{"open": open_time, "close": close_time}]
        
        return result if result["days"] else {"type": "raw", "value": hours_str}
    
    except Exception:
        # Fallback: return raw string
        return {"type": "raw", "value": hours_str}

def deduplicate(pois):
    """Remove duplicate POIs based on rounded coordinates"""
    seen = set()
    unique = []
    
    for p in pois:
        key = (round(p["lat"], 4), round(p["lng"], 4), p["name"])
        if key not in seen:
            seen.add(key)
            unique.append(p)
    
    return unique

def main():
    with open(INPUT, encoding="utf-8") as f:
        raw = json.load(f)

    clean = []

    for p in raw:
        cat = get_category(p["category"])
        region = get_region(p["lat"], p["lng"])
        poi_id = generate_id(p["name"], p["lat"], p["lng"])

        # Parse opening hours
        opening_hours_raw = p.get("opening_hours")
        opening_hours_parsed = parse_opening_hours(opening_hours_raw)
        
        clean.append({
            "id": poi_id,
            "name": p["name"],
            "lat": p["lat"],
            "lng": p["lng"],
            "category": cat,
            "region": region,
            "rating": p.get("rating"),
            "description": p.get("description"),
            "thumbnail": p.get("thumbnail"),
            "website": p.get("website"),
            "wikipedia": p.get("wikipedia"),
            "phone": p.get("phone"),
            "opening_hours": opening_hours_parsed,
            "opening_hours_raw": opening_hours_raw,
            "cuisine": p.get("cuisine"),
            "stars": p.get("stars"),
            "email": p.get("email"),
            "address": {
                "street": p.get("addr_street"),
                "city": p.get("addr_city"),
                "postcode": p.get("addr_postcode")
            } if any([p.get("addr_street"), p.get("addr_city"), p.get("addr_postcode")]) else None,
            "popularity": 0.5  # Default popularity score
        })

    # Remove duplicates
    clean = deduplicate(clean)

    print(f"Cleaned POIs: {len(clean)}")

    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(clean, f, indent=2, ensure_ascii=False)

    print(f"✅ Saved to: {OUTPUT}")

if __name__ == "__main__":
    main()
