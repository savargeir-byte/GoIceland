"""
📝 ENRICH ALL PLACES WITH SAGA & CULTURE
Ensures EVERY place has description - NO empty detail screens!

Sources:
1. Wikipedia Icelandic API (for major attractions)
2. Professional fallback descriptions (for everything else)
3. Auto-generated saga & culture context
"""

import json
import time
import requests
from datetime import datetime


def get_wikipedia_summary(place_name, lang="is"):
    """
    Fetch Wikipedia summary for place.
    Returns (description, url) or (None, None) if not found.
    """
    try:
        url = f"https://{lang}.wikipedia.org/api/rest_v1/page/summary/{place_name}"
        response = requests.get(url, timeout=5)
        
        if response.status_code == 200:
            data = response.json()
            extract = data.get("extract", "")
            page_url = data.get("content_urls", {}).get("desktop", {}).get("page", "")
            
            if extract and len(extract) > 50:
                return extract, page_url
        
        # Try English fallback
        if lang == "is":
            return get_wikipedia_summary(place_name, lang="en")
        
        return None, None
        
    except Exception as e:
        return None, None


def generate_fallback_description(place):
    """
    Generate professional fallback description when Wikipedia not available.
    Ensures NO empty detail screens.
    """
    name = place["name"]
    category = place.get("category", "staður")
    
    # Category-specific templates
    templates = {
        "waterfall": f"{name} er foss á Íslandi sem endurspeglar kraft og fegurð íslenskrar náttúru. "
                     f"Fossinn hefur mótast af eldvirkni og jöklum í gegnum þúsundir ára. "
                     f"Staðurinn er vinsæll meðal ferðamanna og ljósmyndara.",
        
        "glacier": f"{name} er jökull á Íslandi sem endurspeglar krafta náttúrunnar. "
                   f"Jöklarnir á Íslandi hafa mótað landið í milljónir ára og eru "
                   f"órjúfanlegur hluti af sögu og menningu landsins.",
        
        "hot_spring": f"{name} er heitur lind á Íslandi sem minnir á eldvirkni eyjarinnar. "
                      f"Heitir lindir hafa verið notaðir til baða og þvotta í þúsundir ára "
                      f"og eru órjúfanlegur hluti af íslensku líferni.",
        
        "geyser": f"{name} er hver á Íslandi sem sýnir orkuríkan jarðhita landsins. "
                  f"Hverir hafa heillað ferðamenn í gegnum aldir og eru hluti af "
                  f"einstökum jarðfræði Íslands.",
        
        "beach": f"{name} er strönd á Íslandi þar sem hafið mætir landi. "
                 f"Strendur Íslands eru mótaðar af öflugum öldum, sjávargöngu og "
                 f"eldvirkni og bjóða upp á einstaka upplifun.",
        
        "church": f"{name} er kirkja á Íslandi sem endurspeglar trúarleg og menningarleg gildi þjóðarinnar. "
                  f"Kirkjur á Íslandi hafa verið miðstöð samfélaga í gegnum aldir "
                  f"og eru hluti af sögu landsins.",
        
        "restaurant": f"{name} er veitingastaður á Íslandi sem býður upp á matarupplifun. "
                      f"Íslensk matarhefð byggir á fersku hráefni úr náttúrunni - "
                      f"sjávarfangi, lamb og grænmeti.",
        
        "parking": f"{name} er bílastæði sem þjónar ferðamönnum og gestum svæðisins. "
                   f"Góðar aðstaða gerir ferðalög um Ísland þægilegri og öruggari.",
        
        "museum": f"{name} er safn á Íslandi sem varðveitir sögu og menningu. "
                  f"Söfn á Íslandi gegna mikilvægu hlutverki í að varðveita "
                  f"menningararfleifð þjóðarinnar.",
        
        "attraction": f"{name} er ferðamannastaður á Íslandi sem dregur að gestum. "
                      f"Staðurinn er hluti af ríkulegu úrvali náttúru- og menningarstaða "
                      f"sem Ísland hefur upp á að bjóða.",
        
        "viewpoint": f"{name} er útsýnisstaður á Íslandi þar sem víðáttumikil náttúra "
                     f"landsins opnast fyrir augum. Útsýnisstaðir sýna fegurð og "
                     f"margbreytileika íslensks landslags.",
    }
    
    # Get template or use generic one
    template = templates.get(category, 
        f"{name} er {category} á Íslandi sem endurspeglar samspil náttúru og menningar. "
        f"Staðurinn hefur mótast af eldvirkni, veðri og sögu fólks í gegnum aldir "
        f"og er hluti af ferðamennsku landsins í dag.")
    
    # Add context based on region
    tags = place.get("tags", {})
    
    # Add opening hours if available
    opening_context = ""
    if "opening_hours" in tags:
        opening_context = f" Opnunartímar eru: {tags['opening_hours']}."
    
    # Add accessibility info
    access_context = ""
    if tags.get("wheelchair") == "yes":
        access_context = " Staðurinn er aðgengilegur fyrir hjólastóla."
    
    return {
        "short": f"{name} - {category} á Íslandi",
        "saga_og_menning": template + opening_context + access_context,
        "nature": "Íslenskt landslag hefur mótast af eldvirkni, jöklum og veðri í milljónir ára. "
                  "Náttúran á Íslandi er einstök og margbreytileg - frá svörtum sandströndum "
                  "til hvítra jöklanna, frá grænni gróðri til svartrar hrauneyðimerkur.",
        "geology": "Ísland liggur á mótum tveggja meginflekaplötna - Norður-Ameríku og "
                   "Evrasíu - sem gerir landið eldvirkt og jarðfræðilega virkt.",
    }


def extract_services(tags):
    """Extract available services from OSM tags."""
    return {
        "parking": "parking" in str(tags.values()).lower() or tags.get("amenity") == "parking",
        "toilet": "toilet" in str(tags.values()).lower() or tags.get("amenity") == "toilets",
        "restaurant_nearby": tags.get("amenity") in ["restaurant", "cafe", "fast_food"],
        "wheelchair_access": tags.get("wheelchair") == "yes",
        "guided_tours": "guided" in str(tags.values()).lower(),
        "camping": tags.get("tourism") == "camp_site" or "camp" in str(tags.values()).lower(),
        "wifi": tags.get("internet_access") in ["yes", "wlan"],
        "atm": tags.get("atm") == "yes",
        "information": tags.get("tourism") == "information",
        "shelter": tags.get("amenity") == "shelter",
    }


def infer_visit_info(category, tags):
    """Infer visit information from category and tags."""
    # Best time to visit
    best_time = "May–September"
    if category in ["hot_spring", "geyser"]:
        best_time = "All year"
    elif category in ["glacier", "ice_cave"]:
        best_time = "December–March"
    
    # Crowds
    crowds = "Moderate"
    if tags.get("tourism") == "attraction":
        crowds = "High in summer"
    
    # Entry fee
    entry_fee = False
    if "fee" in tags and tags["fee"] in ["yes", "true"]:
        entry_fee = True
    
    # Suggested duration
    duration = "30-60 minutes"
    if category in ["museum", "attraction"]:
        duration = "1-2 hours"
    elif category in ["hiking", "trail"]:
        duration = "2-4 hours"
    
    return {
        "best_time": best_time,
        "crowds": crowds,
        "entry_fee": entry_fee,
        "suggested_duration": duration,
    }


def enrich_all_places():
    """Main function to enrich all places."""
    print("📝 ENRICHING ALL PLACES WITH SAGA & CULTURE")
    print("=" * 60)
    
    # Load raw data
    print("📖 Loading raw places...")
    with open("data/iceland_places_raw.json", "r", encoding="utf-8") as f:
        places = json.load(f)
    
    print(f"✅ Loaded {len(places)} places")
    print()
    
    enriched_count = 0
    wikipedia_count = 0
    fallback_count = 0
    
    for i, place in enumerate(places, 1):
        name = place["name"]
        
        if i % 100 == 0:
            print(f"Processing {i}/{len(places)} places...")
        
        # Try Wikipedia first
        wiki_desc, wiki_url = get_wikipedia_summary(name, lang="is")
        
        if wiki_desc:
            # Found on Wikipedia!
            place["descriptions"] = {
                "short": wiki_desc[:200] + "..." if len(wiki_desc) > 200 else wiki_desc,
                "saga_og_menning": wiki_desc,
                "nature": "Íslenskt landslag mótað af eldvirkni og jöklum.",
                "geology": "",
            }
            place["wikipedia_url"] = wiki_url
            place["sources"] = place.get("sources", []) + ["wikipedia"]
            wikipedia_count += 1
        else:
            # Generate fallback description
            place["descriptions"] = generate_fallback_description(place)
            place["sources"] = place.get("sources", []) + ["generated"]
            fallback_count += 1
        
        # Add services
        place["services"] = extract_services(place.get("tags", {}))
        
        # Add visit info
        place["visit_info"] = infer_visit_info(place["category"], place.get("tags", {}))
        
        # Add media placeholders
        place["media"] = {
            "images": [],
            "thumbnail": None,
            "hero_image": None,
        }
        
        place["enriched_at"] = datetime.now().isoformat()
        enriched_count += 1
        
        # Rate limiting for Wikipedia API
        if wiki_desc:
            time.sleep(0.3)
    
    # Save enriched data
    output_file = "data/iceland_places_enriched.json"
    print()
    print(f"💾 Saving to {output_file}")
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(places, f, indent=2, ensure_ascii=False)
    
    # Statistics
    print()
    print("=" * 60)
    print("📊 ENRICHMENT STATISTICS")
    print("=" * 60)
    print(f"Total places enriched: {enriched_count}")
    print(f"Wikipedia descriptions: {wikipedia_count}")
    print(f"Generated descriptions: {fallback_count}")
    print(f"Coverage: 100% (NO empty detail screens!)")
    print("=" * 60)
    print("✅ ALL PLACES ENRICHED!")
    print(f"📂 Saved to: {output_file}")
    print()
    print("🎉 Every place now has saga & culture description!")
    print()
    
    return places


if __name__ == "__main__":
    enrich_all_places()
