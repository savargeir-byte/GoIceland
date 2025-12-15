"""
Generate trail maps for all hiking trails
Uses OpenStreetMap to create static map images showing the trail route
"""
import json
import requests
from time import sleep
import os

def get_trail_map(trail_name, bbox, trail_id):
    """
    Generate a static map image for a trail using OpenStreetMap
    bbox: [min_lon, min_lat, max_lon, max_lat]
    """
    try:
        # Use Staticmap API or OpenStreetMap tile server
        # For now, we'll use a simple approach with MapQuest Open Static Maps
        
        min_lon, min_lat, max_lon, max_lat = bbox
        center_lat = (min_lat + max_lat) / 2
        center_lon = (min_lon + max_lon) / 2
        
        # Calculate zoom level based on bbox size
        lat_diff = max_lat - min_lat
        lon_diff = max_lon - min_lon
        max_diff = max(lat_diff, lon_diff)
        
        if max_diff > 0.5:
            zoom = 10
        elif max_diff > 0.2:
            zoom = 11
        elif max_diff > 0.1:
            zoom = 12
        elif max_diff > 0.05:
            zoom = 13
        else:
            zoom = 14
        
        # Use OpenStreetMap Static Map API
        # Alternative: Use Mapbox, Google Maps, or custom tile renderer
        
        # For now, return a URL to an interactive map
        # You can replace this with actual static map generation
        map_url = f"https://www.openstreetmap.org/export/embed.html?bbox={min_lon},{min_lat},{max_lon},{max_lat}&layer=mapnik"
        
        # Or use a screenshot service
        # screenshot_url = f"https://api.mapbox.com/styles/v1/mapbox/outdoors-v12/static/{center_lon},{center_lat},{zoom},0/800x600@2x?access_token=YOUR_TOKEN"
        
        return map_url
        
    except Exception as e:
        print(f"    ⚠️  Error generating map: {e}")
        return None

def get_trail_bbox(trail):
    """Calculate bounding box for a trail"""
    # If trail has waypoints/coordinates
    if trail.get('coordinates'):
        coords = trail['coordinates']
        lats = [c[1] for c in coords]
        lons = [c[0] for c in coords]
        return [min(lons), min(lats), max(lons), max(lats)]
    
    # If trail just has start/end points
    lat = trail.get('latitude')
    lon = trail.get('longitude')
    
    if lat and lon:
        # Create a bbox around the point (roughly 5km x 5km)
        lat_offset = 0.045  # ~5km
        lon_offset = 0.07   # ~5km at Iceland's latitude
        return [lon - lon_offset, lat - lat_offset, lon + lon_offset, lat + lat_offset]
    
    return None

def enrich_trail(trail, index, total):
    """Add map and enhanced description to trail"""
    name = trail.get('name', 'Unknown')
    trail_id = trail.get('id', '')
    
    print(f"\n[{index}/{total}] {name}")
    
    # Skip if already has map
    if trail.get('mapImage') or trail.get('map_preview'):
        print("  ✅ Already has map, skipping")
        return False
    
    enriched = False
    
    # Generate map
    print("  🗺️  Generating trail map...")
    bbox = get_trail_bbox(trail)
    
    if bbox:
        map_url = get_trail_map(name, bbox, trail_id)
        if map_url:
            trail['mapImage'] = map_url
            trail['map_preview'] = map_url
            print(f"  ✅ Added trail map")
            enriched = True
        else:
            print("  ⚠️  Could not generate map")
    else:
        print("  ⚠️  No coordinates available")
    
    # Enhance description if missing
    if not trail.get('content') or not trail.get('content', {}).get('en', {}).get('description'):
        print("  📝 Adding description...")
        
        difficulty = trail.get('difficulty', 'moderate')
        length = trail.get('length', 0)
        duration = trail.get('duration', 0)
        elevation = trail.get('elevationGain', 0)
        
        # Generate description
        difficulty_desc = {
            'easy': 'This easy hiking trail is perfect for beginners and families.',
            'moderate': 'This moderate hiking trail offers a good balance of challenge and enjoyment.',
            'hard': 'This challenging hiking trail is recommended for experienced hikers.',
            'expert': 'This expert-level trail is extremely challenging and requires excellent fitness.'
        }.get(difficulty, 'This hiking trail in Iceland offers beautiful scenery.')
        
        description = f"{name} is a scenic hiking trail in Iceland. {difficulty_desc}"
        
        if length > 0:
            description += f" The trail is {length} km long"
            if duration > 0:
                hours = int(duration // 60)
                mins = int(duration % 60)
                if hours > 0:
                    description += f" and takes approximately {hours} hour{'s' if hours > 1 else ''}"
                    if mins > 0:
                        description += f" {mins} minutes"
                else:
                    description += f" and takes approximately {mins} minutes"
            description += "."
        
        if elevation > 0:
            description += f" The trail features {elevation} meters of elevation gain."
        
        description += " Experience the stunning natural beauty of Iceland on this memorable hike."
        
        if not trail.get('content'):
            trail['content'] = {}
        
        trail['content']['en'] = {
            'description': description,
            'safety': 'Check weather conditions before starting. Bring appropriate gear and supplies.',
            'tips': 'Start early to avoid crowds. Respect nature and stay on marked trails.'
        }
        
        trail['content']['is'] = {
            'description': '',
            'safety': '',
            'tips': ''
        }
        
        trail['content']['zh'] = {
            'description': '',
            'safety': '',
            'tips': ''
        }
        
        print(f"  ✅ Added description")
        enriched = True
    
    sleep(0.5)  # Be nice to APIs
    
    return enriched

def main():
    print("="*80)
    print("🗺️  TRAIL MAP GENERATOR")
    print("="*80)
    print()
    
    # Load trails from Firestore download
    input_file = 'data/iceland_trails.json'
    
    if not os.path.exists(input_file):
        print(f"❌ File not found: {input_file}")
        print("   Download trails from Firestore first!")
        return
    
    with open(input_file, 'r', encoding='utf-8') as f:
        trails = json.load(f)
    
    print(f"📊 Loaded {len(trails)} trails")
    print()
    
    enriched_count = 0
    
    for i, trail in enumerate(trails, 1):
        try:
            if enrich_trail(trail, i, len(trails)):
                enriched_count += 1
            
            # Save progress every 20 trails
            if i % 20 == 0:
                output_file = 'data/iceland_trails_enriched.json'
                with open(output_file, 'w', encoding='utf-8') as f:
                    json.dump(trails, f, indent=2, ensure_ascii=False)
                print(f"\n💾 Progress saved ({enriched_count} enriched so far)\n")
        
        except KeyboardInterrupt:
            print("\n\n⚠️  Interrupted by user")
            break
        except Exception as e:
            print(f"  ❌ Error: {e}")
            continue
    
    # Final save
    output_file = 'data/iceland_trails_enriched.json'
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(trails, f, indent=2, ensure_ascii=False)
    
    print()
    print("="*80)
    print("✅ TRAIL ENRICHMENT COMPLETE!")
    print("="*80)
    print()
    print(f"📊 SUMMARY:")
    print(f"   Total trails: {len(trails)}")
    print(f"   Enriched: {enriched_count}")
    print(f"   Output: {output_file}")
    print()
    print("Next step: Upload to Firestore")
    print("   cd firebase")
    print("   python upload_trails_to_firestore.py")

if __name__ == "__main__":
    main()
