#!/usr/bin/env python3
"""
Enricha top 100 staði með öllum upplýsingum og uploada í Firebase
"""

import json
import time
import sys
from pathlib import Path

def main():
    # Load all places
    with open('data/iceland_clean.json', 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    # Sort by popularity and get top 100
    sorted_places = sorted(places, key=lambda x: x.get('popularity', 0), reverse=True)
    top_100 = sorted_places[:100]
    
    print(f'🌟 Top 100 places to enrich and upload:')
    print(f'=' * 60)
    for i, p in enumerate(top_100[:20], 1):
        name = p.get('name', 'Unknown')
        pop = p.get('popularity', 0)
        cat = p.get('category', 'unknown')
        print(f'{i:2}. {name:40} {cat:15} pop:{pop:.2f}')
    
    print(f'\n... and {len(top_100)-20} more')
    print(f'\nTotal to process: {len(top_100)} places')
    print(f'\nNext: Run enrichment pipeline on these places')

if __name__ == '__main__':
    main()
