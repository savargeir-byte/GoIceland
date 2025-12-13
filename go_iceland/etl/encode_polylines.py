#!/usr/bin/env python3
"""
🗺️ Polyline Encoder - GO ICELAND
Converts trail polylines from nested arrays to encoded strings
Uses Google's Polyline Algorithm (used by Google Maps, Mapbox, etc.)
"""

import json
from pathlib import Path

def encode_polyline(coordinates):
    """
    Encode a list of [lat, lng] coordinates into a polyline string.
    Uses Google's Polyline Algorithm.
    
    Args:
        coordinates: List of [lat, lng] pairs
    
    Returns:
        Encoded polyline string
    """
    if not coordinates:
        return ""
    
    def encode_value(value):
        """Encode a single coordinate value"""
        # Scale to 1e5 and convert to int
        value = int(round(value * 1e5))
        # Convert to signed value
        value = ~(value << 1) if value < 0 else (value << 1)
        # Split into chunks and encode
        chunks = []
        while value >= 0x20:
            chunks.append((0x20 | (value & 0x1f)) + 63)
            value >>= 5
        chunks.append(value + 63)
        return ''.join(chr(chunk) for chunk in chunks)
    
    encoded = []
    prev_lat = 0
    prev_lng = 0
    
    for lat, lng in coordinates:
        # Calculate delta from previous point
        lat_delta = lat - prev_lat
        lng_delta = lng - prev_lng
        
        # Encode deltas
        encoded.append(encode_value(lat_delta))
        encoded.append(encode_value(lng_delta))
        
        # Update previous values
        prev_lat = lat
        prev_lng = lng
    
    return ''.join(encoded)

def convert_trails_polylines(input_file, output_file):
    """Convert all trail polylines to encoded strings"""
    print(f"📖 Loading trails from: {input_file}")
    
    with open(input_file, 'r', encoding='utf-8') as f:
        trails = json.load(f)
    
    print(f"✅ Loaded {len(trails)} trails")
    print(f"🔄 Encoding polylines...")
    
    converted = 0
    errors = 0
    
    for trail in trails:
        try:
            # Get polyline array
            polyline = trail.get('polyline', [])
            
            if polyline and isinstance(polyline, list):
                # Encode polyline
                encoded = encode_polyline(polyline)
                
                # Replace with encoded string
                trail['polyline_encoded'] = encoded
                
                # Keep simplified points for quick preview (first, last, midpoint)
                if len(polyline) >= 3:
                    trail['polyline_preview'] = [
                        polyline[0],
                        polyline[len(polyline) // 2],
                        polyline[-1]
                    ]
                else:
                    trail['polyline_preview'] = polyline
                
                # Remove full polyline array to save space
                del trail['polyline']
                
                converted += 1
                
                if converted % 50 == 0:
                    print(f"   ✅ {converted}/{len(trails)} encoded...")
            else:
                errors += 1
                print(f"   ⚠️ Trail {trail.get('id')} has no polyline")
                
        except Exception as e:
            errors += 1
            print(f"   ❌ Error encoding trail {trail.get('id')}: {e}")
    
    # Save converted trails
    print(f"\n💾 Saving to: {output_file}")
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(trails, f, ensure_ascii=False, indent=2)
    
    print(f"\n✅ Conversion complete!")
    print(f"   📊 {converted} trails encoded")
    print(f"   ❌ {errors} errors")
    print(f"\n💡 Polylines are now encoded strings (Firebase-compatible)")
    print(f"   Use polyline_preview for quick map display")
    print(f"   Decode polyline_encoded for full trail rendering")

if __name__ == '__main__':
    SCRIPT_DIR = Path(__file__).parent
    DATA_DIR = SCRIPT_DIR.parent / 'data'
    
    INPUT_FILE = DATA_DIR / 'iceland_trails.json'
    OUTPUT_FILE = DATA_DIR / 'iceland_trails_encoded.json'
    
    if not INPUT_FILE.exists():
        print(f"❌ Input file not found: {INPUT_FILE}")
        exit(1)
    
    convert_trails_polylines(INPUT_FILE, OUTPUT_FILE)
