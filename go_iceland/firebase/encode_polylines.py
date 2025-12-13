"""
Encode trail polylines to avoid Firebase nested array issue.
Converts [[lat,lng],...] to encoded string format.
"""
import json


def encode_polyline(coordinates):
    """
    Encode a list of [lat, lng] coordinates to a polyline string.
    Uses Google's polyline encoding algorithm.
    """
    if not coordinates:
        return ""
    
    def encode_value(value):
        value = int(round(value * 1e5))
        value = ~(value << 1) if value < 0 else (value << 1)
        encoded = []
        while value >= 0x20:
            encoded.append(chr((0x20 | (value & 0x1f)) + 63))
            value >>= 5
        encoded.append(chr(value + 63))
        return ''.join(encoded)
    
    output = []
    prev_lat = 0
    prev_lng = 0
    
    for lat, lng in coordinates:
        delta_lat = lat - prev_lat
        delta_lng = lng - prev_lng
        output.append(encode_value(delta_lat))
        output.append(encode_value(delta_lng))
        prev_lat = lat
        prev_lng = lng
    
    return ''.join(output)


def flatten_polyline(coordinates):
    """
    Flatten polyline from [[lat,lng],...] to [lat,lng,lat,lng,...]
    Simpler alternative to encoding.
    """
    if not coordinates:
        return []
    flattened = []
    for lat, lng in coordinates:
        flattened.extend([lat, lng])
    return flattened


def process_trails(input_file, output_file, use_encoding=True):
    """
    Process trails JSON to convert polylines.
    
    Args:
        input_file: Path to iceland_trails.json
        output_file: Path to output file
        use_encoding: If True, encode polylines. If False, flatten them.
    """
    print(f"📖 Loading trails from {input_file}")
    with open(input_file, 'r', encoding='utf-8') as f:
        trails = json.load(f)
    
    print(f"🔄 Processing {len(trails)} trails...")
    processed = 0
    
    for trail in trails:
        if 'polyline' in trail and trail['polyline']:
            if use_encoding:
                # Encode to string
                trail['polyline_encoded'] = encode_polyline(trail['polyline'])
                # Keep original polyline length for reference
                trail['polyline_points'] = len(trail['polyline'])
                # Remove nested array
                del trail['polyline']
            else:
                # Flatten to single array
                trail['polyline'] = flatten_polyline(trail['polyline'])
            
            processed += 1
    
    print(f"✅ Processed {processed} trails with polylines")
    
    print(f"💾 Saving to {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(trails, f, ensure_ascii=False, indent=2)
    
    print("✅ Done!")
    return trails


if __name__ == '__main__':
    import sys
    
    # Default paths
    input_file = 'data/iceland_trails.json'
    output_file = 'data/iceland_trails_flat.json'
    
    # Use flattened array (simpler, works with Firestore)
    print("🏔️ TRAIL POLYLINE PROCESSOR")
    print("=" * 60)
    print("Converting nested arrays to flat format for Firebase")
    print("=" * 60)
    print()
    
    trails = process_trails(input_file, output_file, use_encoding=False)
    
    # Show sample
    if trails:
        sample = trails[0]
        print()
        print("📋 Sample trail:")
        print(f"   Name: {sample['name']}")
        print(f"   Distance: {sample['distance_km']} km")
        if 'polyline' in sample:
            print(f"   Polyline: flat array with {len(sample['polyline'])} values ({len(sample['polyline'])//2} points)")
        elif 'polyline_encoded' in sample:
            print(f"   Polyline: encoded string ({sample['polyline_points']} points)")
