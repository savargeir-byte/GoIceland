#!/usr/bin/env python3
"""
Script to add descriptions to all trails in trail_api.dart
This reads the current file and adds appropriate descriptions based on trail names and regions
"""

import re

# Mapping of trail names to descriptions (Icelandic)
trail_descriptions = {
    # Hálendi
    'Askja og Víti': {
        'description': 'Askja er stór innskotshringur í Dyngjufjöllum. Víti er fallegur gígur með bláum vatni inni í Öskjunni. Einstakt tungllandslag þar sem NASA þjálfaði Apollo geimfara.',
        'highlights': ['Víti gígur', 'Askja hringur', 'Tungllandslag', 'Útsýni yfir hálendið'],
        'season': 'Júní - September',
        'facilities': ['Bílastæði', 'Salerni']
    },
    'Landmannalaugar hringferð': {
        'description': 'Stuttur göngutúr í kringum Landmannalaugar svæðið með litríkum ríólítfjöllum, heitu lauginni og hraunvöllum. Fullkomið til að kynnast svæðinu áður en farið er í lengri göngu.',
        'highlights': ['Heit laug', 'Litríkir fjalltoppar', 'Laugahraun', 'Gufustrók'],
        'season': 'Júní - September',
        'facilities': ['Fjallaskáli', 'Heit laug', 'Tjaldsvæði']
    },
    
    # Suðurland
    'Reykjadalur': {
        'description': 'Vinsæl gönguleið sem endar við heita á þar sem hægt er að baða sig. Leiðin liggur upp eftir dal með gufustrókum og hraunmyndunum. Fullkomið fyrir byrjendur og fjölskyldur.',
        'highlights': ['Heit á til að baða sig í', 'Gufustrók og hverir', 'Fallegt dallandslag', 'Góð fyrir fjölskyldur'],
        'season': 'Allt árið',
        'facilities': ['Bílastæði', 'Salerni', 'Baðaðstaða']
    },
    'Skógafoss til Þórsmerkur': {
        'description': 'Löng og krefjandi ganga frá Skógafossi til Þórsmerkur með 26 fossum á leiðinni. Hluti af Fimmvörðuháls leiðinni. Ótrúlegt útsýni yfir jökla og fjöll.',
        'highlights': ['Skógafoss', '26 fossar', 'Þórsmörk', 'Jöklaútsýni'],
        'season': 'Júlí - Ágúst',
        'facilities': ['Merktar leiðir', 'Skálar']
    },
    'Sólheimasandur flugvélaflak': {
        'description': 'Ganga að hinu fræga DC-3 flugvélaflaki á svörtum sandi. Flugvélin lenti þarna árið 1973. Vinsæll ljósmyndastaður og kvikmyndatökustaður.',
        'highlights': ['DC-3 flugvél', 'Svartur sandur', 'Ljósmyndir', 'Einstakt landslag'],
        'season': 'Allt árið',
        'facilities': ['Bílastæði']
    },
    'Reynisfjara og Dyrhólaey': {
        'description': 'Fallegasti svörti sandur Íslands með Reynisdröngum, basaltsúlunum og fuglabjargi. Dyrhólaey er fuglabjargi með lundabyggðum og stórfenglegu útsýni.',
        'highlights': ['Reynisdrangar', 'Basaltsúlur', 'Lundabyggðir', 'Dyrhólaey'],
        'season': 'Allt árið (lundír Maí-Ágúst)',
        'facilities': ['Bílastæði', 'Salerni', 'Kaffihús']
    },
    'Fjaðrárgljúfur': {
        'description': '100 metra djúpur gljúfur með stórbrotinni náttúru. Leiðin liggur meðfram brún gljúfursins með mörgum útsýnisstöðum. Varð heimsfrægur eftir Justin Bieber tónlistarmyndband.',
        'highlights': ['Djúpur gljúfur', 'Útsýni', 'Fjaðrá', 'Útsýnispallar'],
        'season': 'Maí - September',
        'facilities': ['Bílastæði', 'Salerni', 'Útsýnispallar']
    },
    'Stakkholtsgjá': {
        'description': 'Fallegur gljúfur með foss í botni. Þröngt gil með háum veggjum. Þarf að stafra yfir stór grjót til að komast inn í gljúfrið.',
        'highlights': ['Þröngt gil', 'Fossur', 'Grjótstafur', 'Ævintýri'],
        'season': 'Júní - September',
        'facilities': ['Bílastæði']
    },
    
    # Vesturland
    'Glymur': {
        'description': 'Næsthæsti foss Íslands (198m) og fallegasta gönguleið höfuðborgarsvæðisins. Leiðin fer yfir læk, í gegnum helli og upp að fossinum. Ógleymanlegt útsýni yfir Hvalfjörð.',
        'highlights': ['198m hár foss', 'Þverun læks', 'Hellir', 'Hvalfjörður útsýni'],
        'season': 'Maí - September',
        'facilities': ['Bílastæði', 'Merktar leiðir']
    },
    'Kirkjufell': {
        'description': 'Eitt þekktasta fjall Íslands sem sást í Game of Thrones. Stutt en brött ganga upp í fjallið með frábæru útsýni yfir Grundarfjörð og Kirkjufellsfoss.',
        'highlights': ['Game of Thrones', 'Kirkjufellsfoss', 'Grundarfjörður', 'Norðurljós'],
        'season': 'Maí - September',
        'facilities': ['Bílastæði']
    },
    'Hraunfossar og Barnafoss': {
        'description': 'Hraunfossar eru röð af fossum sem síast upp úr hrauninu. Barnafoss er kraftmikill foss skammt í burtu. Stutt og auðveld ganga á milli fossanna.',
        'highlights': ['Hraunfossar', 'Barnafoss', 'Hvítá', 'Hallmundarhraun'],
        'season': 'Allt árið',
        'facilities': ['Bílastæði', 'Salerni', 'Kaffihús']
    },
    
    # More trails...
    'Jökulsárlón': {
        'description': 'Stærsta jökullón Íslands. Ísjakarnir fljóta hægt í lóninu og reka á Demantaströndina. Stuttur göngutúr með ótrúlegum ljósmyndatækifærum.',
        'highlights': ['Ísjakarnir', 'Demantaströnd', 'Selir', 'Breiðamerkurjökull'],
        'season': 'Allt árið',
        'facilities': ['Bílastæði', 'Salerni', 'Kaffihús', 'Bátaferðir']
    },
    'Esjan': {
        'description': 'Húsafjall Reykvíkinga og vinsælasta gönguleiðin á höfuðborgarsvæðinu. Vel merkt leið upp að Steini (780m). Frábært útsýni yfir borgina og Faxaflóa.',
        'highlights': ['Reykjavík útsýni', 'Steinn', 'Vel merktar leiðir', 'Fjölskylduvæn'],
        'season': 'Allt árið',
        'facilities': ['Bílastæði', 'Salerni', 'Merktar leiðir']
    },
}

# Default descriptions for trails without specific ones
default_descriptions = {
    'Easy': {
        'description': 'Auðveld og skemmtileg gönguleið sem hentar flestum. Vel merkt leið með fallegri náttúru.',
        'highlights': ['Fallegt útsýni', 'Auðgengt', 'Fjölskylduvænt'],
        'season': 'Maí - September',
        'facilities': ['Bílastæði', 'Merktar leiðir']
    },
    'Moderate': {
        'description': 'Miðlungs erfið gönguleið sem krefst almennlegs þols. Stórkostleg náttúra og útsýni.',
        'highlights': ['Fallegt útsýni', 'Fjölbreytt landslag', 'Vel merkt'],
        'season': 'Júní - September',
        'facilities': ['Bílastæði', 'Merktar leiðir']
    },
    'Hard': {
        'description': 'Krefjandi gönguleið sem krefst góðs þols og reynslu. Ótrúleg náttúruupplifun.',
        'highlights': ['Stórkostlegt útsýni', 'Villt náttúra', 'Ævintýri'],
        'season': 'Júní - Ágúst',
        'facilities': ['Merktar leiðir']
    },
    'Expert': {
        'description': 'Mjög krefjandi leið sem krefst mikillar reynslu og góðrar undirbúnings. Ógleymanlegt ævintýri.',
        'highlights': ['Villt víðerni', 'Ósnert náttúra', 'Kreppa reynslu'],
        'season': 'Júlí - Ágúst',
        'facilities': ['Takmarkaðar']
    }
}

def get_description_for_trail(name, difficulty):
    """Get description for a trail based on name or difficulty"""
    if name in trail_descriptions:
        return trail_descriptions[name]
    else:
        return default_descriptions.get(difficulty, default_descriptions['Moderate'])

# Example output format
def generate_trail_model_with_description(trail_id, name, difficulty):
    """Generate a TrailModel constructor with description fields"""
    desc = get_description_for_trail(name, difficulty)
    return f"""TrailModel(
          id: '{trail_id}',
          name: '{name}',
          difficulty: '{difficulty}',
          // ... other fields ...
          description: '{desc['description']}',
          highlights: {desc['highlights']},
          season: '{desc['season']}',
          facilities: {desc['facilities']},
        ),"""

if __name__ == '__main__':
    # Test
    print(generate_trail_model_with_description('test', 'Glymur', 'Moderate'))
