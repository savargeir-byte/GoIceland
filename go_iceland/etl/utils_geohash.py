"""
GO ICELAND - Geohash Utility
Adds geohash encoding to POI data for proximity queries
"""
import json

INPUT = "./data/iceland_clean.json"
OUTPUT = "./data/iceland_clean_geohash.json"

# Base32 encoding for geohash
BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz"

def encode_geohash(lat, lng, precision=6):
    """
    Encode latitude/longitude to geohash
    
    Precision levels:
    5 = ~5km
    6 = ~1.2km
    7 = ~150m
    8 = ~38m
    9 = ~5m
    """
    lat_range = [-90.0, 90.0]
    lng_range = [-180.0, 180.0]
    geohash = []
    bits = 0
    bit = 0
    even_bit = True

    while len(geohash) < precision:
        if even_bit:
            # Longitude
            mid = (lng_range[0] + lng_range[1]) / 2
            if lng > mid:
                bit |= (1 << (4 - bits))
                lng_range[0] = mid
            else:
                lng_range[1] = mid
        else:
            # Latitude
            mid = (lat_range[0] + lat_range[1]) / 2
            if lat > mid:
                bit |= (1 << (4 - bits))
                lat_range[0] = mid
            else:
                lat_range[1] = mid

        even_bit = not even_bit
        bits += 1

        if bits == 5:
            geohash.append(BASE32[bit])
            bits = 0
            bit = 0

    return "".join(geohash)

def add_geohash_levels(poi):
    """Add multiple geohash precision levels"""
    lat = poi["lat"]
    lng = poi["lng"]
    
    poi["geohash"] = encode_geohash(lat, lng, precision=6)
    poi["geohashes"] = {
        "g5": encode_geohash(lat, lng, 5),
        "g6": encode_geohash(lat, lng, 6),
        "g7": encode_geohash(lat, lng, 7),
        "g8": encode_geohash(lat, lng, 8),
        "g9": encode_geohash(lat, lng, 9)
    }
    
    # Add GeoPoint format for Firestore
    poi["location"] = {
        "geopoint": {
            "_latitude": lat,
            "_longitude": lng
        },
        "geohash": poi["geohash"]
    }
    
    return poi

def main():
    with open(INPUT, encoding="utf-8") as f:
        data = json.load(f)

    print(f"Adding geohash to {len(data)} POIs...")

    for p in data:
        add_geohash_levels(p)

    with open(OUTPUT, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ Added geohash → {OUTPUT}")

if __name__ == "__main__":
    main()
