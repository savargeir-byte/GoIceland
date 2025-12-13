#!/usr/bin/env python3
"""
Script til að bæta við lýsingum á ferðamannastaði
Notar OpenAI API til að búa til íslenskar lýsingar
"""

import json
import os
from typing import Dict, List

# Forgangsröðun - Helstu ferðamannastaðir sem þurfa lýsingar
PRIORITY_PLACES = {
    'waterfalls': [
        'Gullfoss', 'Skógafoss', 'Seljalandsfoss', 'Dettifoss', 'Goðafoss',
        'Svartifoss', 'Dynjandi', 'Hraunfossar', 'Barnafoss', 'Aldeyjarfoss',
        'Hengifoss', 'Glymur', 'Litlanesfoss', 'Gljúfrabúi', 'Kvernufoss',
        'Hjálparfoss', 'Bruarfoss', 'Háifoss', 'Ófærufoss', 'Systrafoss'
    ],
    'glaciers': [
        'Jökulsárlón', 'Vatnajökull', 'Langjökull', 'Hofsjökull', 'Mýrdalsjökull',
        'Eyjafjallajökull', 'Snæfellsjökull', 'Breiðamerkurjökull', 'Sólheimajökull',
        'Fjallsárlón', 'Breiðárlón', 'Kvíárjökull', 'Skaftafellsjökull'
    ],
    'geothermal': [
        'Geysir', 'Strokkur', 'Blue Lagoon', 'Mývatn Nature Baths', 'Landmannalaugar',
        'Hverir', 'Hveravellir', 'Kerlingarfjöll', 'Reykjadalur', 'Secret Lagoon',
        'Krossneslaug', 'Grettislaug', 'Seljavallalaug', 'Nauthólsvík', 'Fontana',
        'Askja', 'Víti', 'Seltún', 'Gunnuhver', 'Krýsuvík'
    ],
    'beaches': [
        'Reynisfjara', 'Diamond Beach', 'Rauðisandur', 'Djúpalónssandur',
        'Stokksnes', 'Nauthólsvík', 'Breiðavík', 'Hvítárhólmi', 'Ytri Tunga'
    ],
    'viewpoints': [
        'Kirkjufell', 'Dyrhólaey', 'Reynisdrangar', 'Vestrahorn', 'Hvítserkur',
        'Látrabjarg', 'Dimmuborgir', 'Ásbyrgi', 'Stuðlagil', 'Fjallsárlón'
    ],
    'caves': [
        'Vatnshellir', 'Lofthellir', 'Víðgelmir', 'Raufarhólshellir', 'Þríhnúkagígur',
        'Gjábakkahellir'
    ],
    'towns': [
        'Reykjavík', 'Akureyri', 'Húsavík', 'Vík', 'Höfn', 'Ísafjörður',
        'Selfoss', 'Egilsstaðir', 'Stykkishólmur', 'Seydisfjördur', 'Borgarnes'
    ]
}

# Íslensku lýsingar fyrir helstu staði
DESCRIPTIONS_IS = {
    # Fossar
    'Gullfoss': 'Gullfoss, "Gullna fossinn", er einn frægusti og stórkostlegusti foss Íslands. Fossinn fellur í tveimur þrepum samtals 32 metra niður í Hvítárgljúfur. Mikill kraftur og máttur náttúrunnar sýnir sig hér á dramatískan hátt.',
    
    'Skógafoss': 'Skógafoss er einn fallegasti foss Íslands, 60 metra hár og 25 metra breiður. Fossinn er oft með fallegum regnboga í sólskini. Hægt er að ganga upp að toppi fossins og sjá útsýni yfir suðurströndina.',
    
    'Seljalandsfoss': 'Seljalandsfoss er einstakur 60 metra hár foss sem hægt er að ganga fyrir aftan. Þessi upplifun að ganga á bak við fossinn er ógleymanlegt ævintýri. Fallegur foss sem er mjög vinsæll hjá ferðamönnum.',
    
    'Dettifoss': 'Dettifoss er öflugasti foss Evrópu með 100 metra breiddina og 44 metra hæð. Fossinn er á Jökulsá á Fjöllum og ótrúlegur kraftur vatnssins má finna hér. Stórfengleg náttúruupplifun.',
    
    'Goðafoss': 'Goðafoss, "Goðafossinn", er einn fallegasti foss norðurlands. Fossinn er 12 metra hár og 30 metra breiður. Nafn fossins kemur frá því að heiðingóðin voru köstuð í fossinn þegar Íslendingar tóku upp kristni árið 1000.',
    
    'Svartifoss': 'Svartifoss, "Svarti fossinn", er frægt fyrir svarta basaltsúlurnar sem umlykja hann. Fossinn er í Skaftafellsþjóðgarði og var innblástur fyrir hönnun Hallgrímskirkju. 20 metra hár og mjög sérstakur.',
    
    'Dynjandi': 'Dynjandi (Fjallfoss) er stórkostlegasti foss Vestfjarða. 100 metra hár breiðskipttur foss sem líkist brúðarslæðu. Sex minni fossar eru neðan við. Ótrúlega fallegur og máttugur.',
    
    'Hraunfossar': 'Hraunfossar eru röð af fossum sem síast upp úr hrauninu Hallmundarhrauni og renna í Hvítá. Fallegt og einstakt fyrirbæri þar sem vatnið kemur úr hrauninu. Mjög myndarlegur staður.',
    
    # Jöklar og jökullón
    'Jökulsárlón': 'Jökulsárlón er stærsta og frægasta jökullón Íslands. Ísjakarnir sem fljóta í lóninu og stranda á Demantaströnd eru ótrúleg sjón. Selir sjást oft í lóninu. Einn vinsælasti ferðamannastadur landsins.',
    
    'Vatnajökull': 'Vatnajökull er stærsti jökull Evrópu utan heimskautasvæða. Jökullinn þekur um 8% af Íslandi. Undir jöklinum eru nokkrir virkir eldfjöll þar á meðal Grímsvötn og Bárðarbunga.',
    
    'Snæfellsjökull': 'Snæfellsjökull er 700.000 ára gamall stapi á Snæfellsnesi. Jules Verne notaði jökulinn sem innganginn í "Ferðina til miðja jarðar". Einstök orkusvæði og töfraður staður.',
    
    # Jarðhiti og laugar
    'Geysir': 'Geysir er frægasti goshverinn í heimi og gaf nafn öllum öðrum goshverum. Þó Geysir sjálfur sé óvirkur, gýs Strokkur á 5-10 mínútna fresti upp í 20-40 metra hæð. Ótrúleg náttúruupplifun.',
    
    'Blue Lagoon': 'Bláa lónið er heimsfrægasta heilsulaug Íslands með 37-39°C heitu sjávarvatni. Kísilríkt vatn sem gott er fyrir húðina. Lúxus spa upplifun í hraunlandslagi.',
    
    'Landmannalaugar': 'Landmannalaugar eru í hjarta hálendisins með litríkum ríólítfjöllum, heitu lauginni og hraunvöllum. Upphafspunktur Laugavegarins. Einstakt og fallegt landslag.',
    
    'Hverir': 'Hverir við Mývatn (Námaskarð) er virkt jarðhitasvæði með leirbollum, gufustrókum og litríkum jarðvegum. Sterkur brennisteinslykt. Ógleymanlegt og dramatískt landslag.',
    
    'Kerlingarfjöll': 'Kerlingarfjöll eru fjallgarður í miðhálendinu með litríku Hveradölum. Rauðir og gulir litir frá jarðhita, gufustrók og heitir lækir. Vinsæl gönguleið og ótrúleg náttúra.',
    
    'Reykjadalur': 'Reykjadalur í Ölfusi er vinsælasta útivistar- og baðstaður nálægt Reykjavík. Heitur á rennur í gegnum dalinn þar sem hægt er að baða sig. Gufustrók og fallegt landslag.',
    
    # Strendur
    'Reynisfjara': 'Reynisfjara er fallegasti svarti sandströndin á Íslandi með Reynisdröngum, basaltsúlum og Dyrhólaey fuglabjargi. Öflugar öldubreytingar - vertu varkár! Einstök náttúra.',
    
    'Diamond Beach': 'Demantaströnd (Diamond Beach) er þar sem ísjöklar frá Jökulsárlóni stranda. Ísjakarnir líta út eins og demantir á svörtum sandi. Ótrúleg ljósmyndastaður.',
    
    'Rauðisandur': 'Rauðisandur í Vestfjörðum er rauðgulur sandströnd í einstöku umhverfi. Friðsæl og afskekkt. Fallegt útsýni og sjófuglar. Einn sérstakasti staður Íslands.',
    
    'Djúpalónssandur': 'Djúpalónssandur er svartur svartur hraunströnd á Snæfellsnesi. Hér eru "aflraunasteinar" sem voru notaðir til að prófa styrk sjómanna. Dramatískt landslag með klettum.',
    
    'Stokksnes': 'Stokksnes og Vestrahorn eru vinsælasti ljósmyndastaður Íslands. "Batman fjallið" með svörtum sandi og ótrúlegu útsýni. Ógleymanlegt landslag.',
    
    # Fjallatoppar og útsýnisstaðir
    'Kirkjufell': 'Kirkjufell á Snæfellsnesi er eitt þekktasta fjall Íslands. Sást í Game of Thrones. Fullkomið form og fallegur foss við fótinn (Kirkjufellsfoss). Vinsælasti ljósmyndastaður fyrir norðurljós.',
    
    'Dyrhólaey': 'Dyrhólaey er fuglabjargi og útsýnisstaður með stórfenglegri sjón yfir Reynisfjara og suðurströndina. Lundabyggðir á sumrin. 120 metra hátt klettahöfuð með náttúrulegum steingátt.',
    
    'Reynisdrangar': 'Reynisdrangar eru þrír basaltklettar í sjónum við Vík. Þjóðsagan segir að þeir séu tröll sem steinnuðust í dögun. Stórbrotin sjón og vinsæll ljósmyndastaður.',
    
    'Vestrahorn': 'Vestrahorn við Stokksnes er glæsilegt 454m hátt fjall. "Batman fjallið" með dramatísku formi. Svartur sandur og ótrúleg ljósmyndatækifæri.',
    
    'Hvítserkur': 'Hvítserkur er 15 metra hár basaltklettur í Húnaflóa. Líkist drekafíli eða trölli að drekka úr sjónum. Þjóðsögur segja af tröllakonum. Einstakur og fallegu.',
    
    'Látrabjarg': 'Látrabjarg eru vestasta punktur Íslands og Evrópu. 14km langt og allt að 440m hátt fuglabjargi. Þúsundir lunda, álka og langvíu. Ótrúleg fuglaskoðun.',
    
    'Dimmuborgir': 'Dimmuborgir við Mývatn eru einkennileg hraunmyndanir. "Dimmuborgir" eða "Dökka virkið" með hellum, höllum og gígurum. Fallegt göngtusvæði og óvenjulegt landslag.',
    
    'Ásbyrgi': 'Ásbyrgi er hestskófaformað gljúfur sem myndaðist í jökulhlaupum. Þéttur birkiskógur. Þjóðsagan segir að Sleipnir, hestur Óðins, hafi myndað það. Fallegur göngutúrsstaður.',
    
    'Stuðlagil': 'Stuðlagil er gljúfur í Jökulsá á Brú með ótrúlegum basaltsúlum. Túrkísblá á rennur í gegnum gljúfrið. Einn fallegasti staður Íslands sem varð frægur 2016.',
    
    # Hellar
    'Vatnshellir': 'Vatnshellir er 8000 ára gamall hraunhellir á Snæfellsnesi. 200 metra langur og fer niður í 35 metra dýpi. Guided túrar fara í hellinn. Litríkt og dramatískt.',
    
    'Víðgelmir': 'Víðgelmir er einn stærsti hraunhellir Íslands. 1585m langur og allt að 15.8m breiður. Fallegir ísdraupar og hraunmyndanir. Guided túrar í boði.',
    
    'Raufarhólshellir': 'Raufarhólshellir er einn lengsti hraunhellir Íslands (1360m). Myndaðist í gosbeltinu fyrir um 5200 árum. Aðgengilegur og spennandi hellir nálægt Reykjavík.',
    
    'Þríhnúkagígur': 'Þríhnúkagígur er eini staðurinn í heimi þar sem hægt er að fara niður í magmabúr eldfjalls. Litríkt og ótrúlegt. Einstök upplifun sem er bara á Íslandi.',
    
    # Bæir og borgir
    'Reykjavík': 'Reykjavík er höfuðborg Íslands og norðursta höfuðborg heims. Um 130.000 íbúar. Lífleg menningarstarfsemi, góðir veitingastaðir og frábær næturlíf. Hallgrímskirkja er merkilegasta bygging borgarinnar.',
    
    'Akureyri': 'Akureyri er stærsta bær norðurlands með um 20.000 íbúa. "Höfuðborg norðursins" með fallegri byggð, góðum veitingastöðum og skíðasvæði. Gott að koma við og njóta bæjarins.',
    
    'Húsavík': 'Húsavík er "hvalaskoðunarhöfuðborg Evrópu". 90% líkur á að sjá hvali. Fallegu bær með góðri hvalasafni og einstakri kirkju. Frábær staður fyrir náttúruunnendur.',
    
    'Vík': 'Vík í Mýrdal er syðsta þorp Íslands með um 300 íbúa. Nálægt Reynisfjara og Dyrhólaey. Góður staður til að koma við á suðurströndinni. Falleg kirkja á hæðinni.',
    
    'Höfn': 'Höfn í Hornafirði er höfuðbær austurlands með um 2500 íbúa. Þekktur fyrir humarhátíð. Nálægt Jökulsárlóni og Vatnajökli. Fallegu útsýni yfir Vestrahorn.',
    
    'Ísafjörður': 'Ísafjörður er stærsti bær Vestfjarða með um 2600 íbúa. Fallegur bær í djúpum firði umkringt fjöllum. Gott útgangspunktur til að skoða Vestfirði og Hornstrandir.',
}


def load_places_master():
    """Load the master places JSON file"""
    with open('iceland_places_master.json', 'r', encoding='utf-8') as f:
        return json.load(f)


def find_place_by_name(places: List[Dict], name: str) -> Dict:
    """Find a place by name (case insensitive, partial match)"""
    name_lower = name.lower()
    for place in places:
        if name_lower in place['name'].lower() or place['name'].lower() in name_lower:
            return place
    return None


def add_descriptions_to_places():
    """Add Icelandic descriptions to major tourist attractions"""
    print('🏔️ Hleð inn iceland_places_master.json...')
    data = load_places_master()
    places = data['places']
    
    print(f'📍 Heildarstaðir: {len(places)}')
    
    updated_count = 0
    not_found = []
    
    print('\n✏️ Bæti við lýsingum...\n')
    
    for place_name, description in DESCRIPTIONS_IS.items():
        place = find_place_by_name(places, place_name)
        if place:
            place['description'] = description
            place['description_is'] = description  # Icelandic version
            
            # Add some metadata if not exists
            if not place.get('metadata'):
                place['metadata'] = {}
            
            place['metadata']['has_description'] = True
            place['metadata']['description_lang'] = 'is'
            
            updated_count += 1
            print(f'✅ {place_name} - lýsing bætt við')
        else:
            not_found.append(place_name)
            print(f'⚠️ {place_name} - fannst ekki í gagnagrunni')
    
    print(f'\n📊 NIÐURSTÖÐUR:')
    print(f'✅ {updated_count} staðir uppfærðir')
    print(f'❌ {len(not_found)} staðir fundust ekki')
    
    if not_found:
        print(f'\n⚠️ Staðir sem fundust ekki:')
        for place in not_found[:10]:
            print(f'   - {place}')
    
    # Save updated data
    print('\n💾 Vista uppfærð gögn...')
    data['updated'] = '2024-12-13'
    data['version'] = data.get('version', '1.0') + '.1'
    
    with open('iceland_places_master_with_descriptions.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print('✅ Vistað í: iceland_places_master_with_descriptions.json')
    print('\n🎉 Lokið!')
    
    return updated_count


if __name__ == '__main__':
    add_descriptions_to_places()
