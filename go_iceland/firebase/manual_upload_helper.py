#!/usr/bin/env python3
"""
🔥 FIREBASE UPLOADER - með Admin SDK eða manual JSON output
Uploadar enriched POI gögn í Firestore
"""

import json
import sys
from pathlib import Path

def create_firestore_commands(json_file: str):
    """Býr til Firebase CLI commands til að uploada"""
    
    with open(json_file, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    print(f"📦 Creating Firebase commands for {len(places)} places...")
    print("\n" + "="*60)
    print("🔥 FIREBASE CLI COMMANDS")
    print("="*60 + "\n")
    
    for place in places:
        doc_id = place.get('id', place.get('name', '').lower().replace(' ', '_'))
        
        # Remove fields that can't be easily set via CLI
        clean_place = place.copy()
        
        print(f"# {place.get('name')}")
        print(f"firebase firestore:set places/{doc_id} '{json.dumps(clean_place, ensure_ascii=False)}' --project YOUR_PROJECT_ID")
        print()
    
    print("\n" + "="*60)
    print(f"✅ Commands for {len(places)} places ready!")
    print("\nOr use Firebase Console to import JSON directly.")
    print("="*60)


def output_for_manual_import(json_file: str, output_file: str):
    """Býr til formatted JSON fyrir manual Firebase import"""
    
    with open(json_file, 'r', encoding='utf-8') as f:
        places = json.load(f)
    
    # Create a dict with document IDs as keys
    firestore_format = {}
    
    for place in places:
        doc_id = place.get('id', place.get('name', '').lower().replace(' ', '_'))
        firestore_format[doc_id] = place
    
    output_path = Path(output_file)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(firestore_format, f, indent=2, ensure_ascii=False)
    
    print(f"\n✅ Firestore-formatted JSON saved to: {output_file}")
    print(f"📋 {len(places)} places ready for import")
    print("\n📝 To import in Firebase Console:")
    print("   1. Go to Firestore Database")
    print("   2. Click on 'places' collection (or create it)")
    print("   3. Use Firebase CLI or manually add documents")


def main():
    input_file = "data/iceland_enriched_full.json"
    
    if not Path(input_file).exists():
        print(f"❌ File not found: {input_file}")
        print("   Run enrichment pipeline first!")
        sys.exit(1)
    
    print("🔥 FIREBASE UPLOAD HELPER\n")
    print("Choose upload method:")
    print("  1. Generate Firebase CLI commands")
    print("  2. Create Firestore-formatted JSON")
    print("  3. Both")
    
    choice = input("\nChoice (1/2/3): ").strip()
    
    if choice in ['1', '3']:
        create_firestore_commands(input_file)
    
    if choice in ['2', '3']:
        output_for_manual_import(input_file, "data/firestore_import_ready.json")
    
    print("\n🎉 Done! Upload data to Firebase Console now.")


if __name__ == "__main__":
    main()
