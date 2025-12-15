#!/usr/bin/env python3
"""
SUMMARY - Hvað er í öllum data files
"""

import json
from pathlib import Path
from collections import Counter

def summarize_file(filepath: Path):
    """Summarize one data file"""
    if not filepath.exists():
        return None
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        if isinstance(data, list):
            count = len(data)
            sample = data[0] if data else {}
        elif isinstance(data, dict):
            count = len(data.keys())
            sample = list(data.values())[0] if data else {}
        else:
            return None
        
        # Check what fields are available
        fields = list(sample.keys()) if isinstance(sample, dict) else []
        
        # Check for descriptions and images
        has_description = 'description' in fields
        has_image = 'image' in fields or 'images' in fields or ('media' in fields)
        has_lat_lng = 'lat' in fields or 'latitude' in fields
        
        return {
            'count': count,
            'has_description': has_description,
            'has_image': has_image,
            'has_lat_lng': has_lat_lng,
            'sample_fields': fields[:10]
        }
    except Exception as e:
        return {'error': str(e)}

def main():
    print('📊 DATA SUMMARY')
    print('=' * 80)
    
    data_dir = Path('data')
    
    files_to_check = [
        ('iceland_clean.json', 'Raw places (no enrichment)'),
        ('firestore_top_places.json', 'Top 55 places (enriched)'),
        ('firestore_complete_enriched.json', '287 places (enriched)'),
        ('firestore_trails_enriched.json', '100 hiking trails (enriched)'),
        ('iceland_trails.json', 'Raw trails (404 total)'),
    ]
    
    print('\n📦 FILES:')
    print('-' * 80)
    
    for filename, description in files_to_check:
        filepath = data_dir / filename
        summary = summarize_file(filepath)
        
        if summary is None:
            print(f'\n❌ {filename}')
            print(f'   {description}')
            print(f'   Status: NOT FOUND')
        elif 'error' in summary:
            print(f'\n⚠️  {filename}')
            print(f'   {description}')
            print(f'   Error: {summary["error"]}')
        else:
            status_icons = []
            if summary['has_description']:
                status_icons.append('📝')
            if summary['has_image']:
                status_icons.append('🖼️')
            if summary['has_lat_lng']:
                status_icons.append('📍')
            
            print(f'\n✅ {filename}')
            print(f'   {description}')
            print(f'   Count: {summary["count"]}')
            print(f'   Features: {" ".join(status_icons)}')
            print(f'   Fields: {", ".join(summary["sample_fields"][:5])}...')
    
    print('\n' + '=' * 80)
    print('\n📋 NEXT STEPS:')
    print('   1. Get Firebase serviceAccountKey.json')
    print('   2. Upload enriched places: python upload_top_to_firebase.py')
    print('   3. Upload trails: python upload_trails_to_firebase.py')
    print('   4. Test app with new data')
    print('\n🎯 EXPECTED RESULT:')
    print('   - 287+ places with descriptions and images')
    print('   - 100 hiking trails with descriptions')
    print('   - All categories working (viewpoint, restaurant, hotel, etc.)')
    print('   - App shows complete information')

if __name__ == '__main__':
    main()
