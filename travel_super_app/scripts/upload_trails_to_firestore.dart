import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:travel_super_app/firebase_options.dart';

/// Script to upload all trails to Firestore
/// Run with: dart run scripts/upload_trails_to_firestore.dart

final trails = [
  // ========== HÁLENDI ÍSLANDS ==========
  {
    'id': 'laugavegur',
    'name': 'Laugavegurinn',
    'difficulty': 'Hard',
    'lengthKm': 55,
    'durationMin': 240,
    'elevationGain': 1200,
    'startLat': 63.9903,
    'startLng': -19.0612,
    'region': 'Hálendi Íslands',
    'description':
        'Laugavegurinn er ein vinsælasta gönguleið Íslands og liggur frá Landmannalaugum til Þórsmerkur. Leiðin býður upp á ótrúlega fjölbreytta náttúru með litríkum fjöllum, hraunvöllum, jöklum og grænum dölum. Gangan tekur venjulega 3-4 daga og krefst góðrar undirbyrðar.',
    'highlights': [
      'Landmannalaugar hverasvæði',
      'Hrafntinnusker',
      'Álftavatn',
      'Emstrur',
      'Þórsmörk'
    ],
    'season': 'Júní - September',
    'facilities': ['Fjallaskálar á leiðinni', 'Merktar leiðir', 'Tjaldsvæði'],
    'images': [
      'https://images.unsplash.com/photo-1504829857797-ddff29c27927',
      'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'
    ],
    'polyline': [
      {'lat': 63.9903, 'lng': -19.0612},
      {'lat': 63.9950, 'lng': -19.0500},
      {'lat': 64.0100, 'lng': -19.0300}
    ]
  },
  {
    'id': 'fimmvorduhals',
    'name': 'Fimmvörðuháls',
    'difficulty': 'Expert',
    'lengthKm': 25,
    'durationMin': 720,
    'elevationGain': 1000,
    'startLat': 63.6325,
    'startLng': -19.4672,
    'region': 'Suðurland',
    'description':
        'Fimmvorduhals er krefjandi dagsganga milli joklanna Eyjafjallajokuls og Myrdalsjokuls. Leidin byrjar vid Skoga og endar i Thorsmork. Thu gengur framhja 26 fossum og serd nytt hraun fra 2010 gosinu. Ogleymanlegt aevintýri fyrir reynda gongufólk.',
    'highlights': [
      'Skógafoss',
      'Magni og Móði gígar',
      '26 fossar',
      'Útsýni yfir jökla',
      'Nýtt hraun'
    ],
    'season': 'Júlí - Ágúst',
    'facilities': ['Skáli á Fimmvörðuskála', 'Merktar leiðir'],
    'images': [
      'https://images.unsplash.com/photo-1483347756197-71ef80e95f73',
      'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'
    ],
    'polyline': [
      {'lat': 63.6325, 'lng': -19.4672},
      {'lat': 63.6500, 'lng': -19.4500}
    ]
  },
  {
    'id': 'askja',
    'name': 'Askja og Víti',
    'difficulty': 'Moderate',
    'lengthKm': 6,
    'durationMin': 150,
    'elevationGain': 150,
    'startLat': 65.0544,
    'startLng': -16.7519,
    'region': 'Hálendi Íslands',
    'description':
        'Askja er stór innskotshringur í Dyngjufjöllum. Víti er fallegur gígur með bláum vatni inni í Öskjunni. Þetta er einstakt landslag sem minnir á tunglið - NASA þjálfaði Apollo geimfara hér. Aðeins aðgengilegt á sumrin með hálendisbíl.',
    'highlights': [
      'Víti gígur',
      'Askja stóri hringurinn',
      'Tungllandslag',
      'Útsýni yfir hálendið'
    ],
    'season': 'Júní - September',
    'facilities': ['Bílastæði', 'Salerni'],
    'images': ['https://images.unsplash.com/photo-1531366936337-7c912a4589a7'],
    'polyline': [
      {'lat': 65.0544, 'lng': -16.7519},
      {'lat': 65.0600, 'lng': -16.7400}
    ]
  },

  // ========== SUÐURLAND ==========
  {
    'id': 'reykjadalur',
    'name': 'Reykjadalur',
    'difficulty': 'Easy',
    'lengthKm': 6.8,
    'durationMin': 120,
    'elevationGain': 280,
    'startLat': 64.0389,
    'startLng': -21.1858,
    'region': 'Suðurland',
    'description':
        'Reykjadalur er vinsæl gönguleið sem endar við heitan á þar sem hægt er að baða sig í náttúrulegri heitri á. Leiðin liggur upp eftir dal með gufustrókum og hraunmyndunum. Fullkomið fyrir byrjendur og fjölskyldur. Endilega taktu með sundföt!',
    'highlights': [
      'Heit á til að baða sig í',
      'Gufustrók og hverir',
      'Fallegt dallandslag',
      'Góð fyrir fjölskyldur'
    ],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Baðaðstaða'],
    'images': ['https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'],
    'polyline': [
      {'lat': 64.0389, 'lng': -21.1858},
      {'lat': 64.0450, 'lng': -21.1800}
    ]
  },
  {
    'id': 'skaftafell_svartifoss',
    'name': 'Skaftafell - Svartifoss',
    'difficulty': 'Easy',
    'lengthKm': 5.5,
    'durationMin': 90,
    'elevationGain': 200,
    'startLat': 64.0178,
    'startLng': -16.9750,
    'region': 'Suðurland',
    'description':
        'Svartifoss, "Svarti fossinn", er einn fegursti foss Íslands, umlukinn af svörtum basaltsúlum. Gönguleiðin byrjar við Skaftafell þjóðgarðsmiðstöð og er mjög vel merkt. Fossinn var innblástur fyrir hönnun Hallgrímskirkju.',
    'highlights': [
      'Svartifoss',
      'Basaltsúlur',
      'Útsýni yfir Skaftafellsheiði',
      'Vel merkt leið'
    ],
    'season': 'Maí - September',
    'facilities': ['Þjóðgarðsmiðstöð', 'Salerni', 'Kaffihús', 'Bílastæði'],
    'images': ['https://images.unsplash.com/photo-1483347756197-71ef80e95f73'],
    'polyline': [
      {'lat': 64.0178, 'lng': -16.9750},
      {'lat': 64.0250, 'lng': -16.9700}
    ]
  },
  {
    'id': 'jokulsarlon',
    'name': 'Jökulsárlón',
    'difficulty': 'Easy',
    'lengthKm': 2,
    'durationMin': 40,
    'elevationGain': 10,
    'startLat': 64.0484,
    'startLng': -16.1806,
    'region': 'Suðurland',
    'description':
        'Jökulsárlón er stærsta jökullón Íslands og einn vinsælasti áfangastaður landsins. Ísjakarnir fljóta hægt í lóninu og reka á Demantaströndina. Stuttur göngutúr umhverfis lónið með ótrúlegum ljósmyndatækifærum. Möguleiki á bátaferðum á lóninu.',
    'highlights': [
      'Ísjakarnir',
      'Demantaströnd',
      'Selir í lóninu',
      'Breiðamerkurjökull'
    ],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Kaffihús', 'Bátaferðir'],
    'images': [
      'https://images.unsplash.com/photo-1531366936337-7c912a4589a7',
      'https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'
    ],
    'polyline': [
      {'lat': 64.0484, 'lng': -16.1806},
      {'lat': 64.0500, 'lng': -16.1800}
    ]
  },
  {
    'id': 'fjadrargljufur',
    'name': 'Fjaðrárgljúfur',
    'difficulty': 'Easy',
    'lengthKm': 4,
    'durationMin': 60,
    'elevationGain': 100,
    'startLat': 63.7728,
    'startLng': -18.1789,
    'region': 'Suðurland',
    'description':
        'Fjaðrárgljúfur er 100 metra djúpur og 2 km langur gljúfur með stórbrotinni náttúru. Leiðin liggur meðfram brún gljúfursins með mörgum útsýnisstöðum. Gljúfurinn varð heimsfrægur eftir tónlistarmyndband með Justin Bieber.',
    'highlights': [
      'Djúpur gljúfur',
      'Stórkostlegt útsýni',
      'Fjaðrá í botninum',
      'Útsýnispallur'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði', 'Salerni', 'Útsýnispallar'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 63.7728, 'lng': -18.1789},
      {'lat': 63.7750, 'lng': -18.1750}
    ]
  },

  // ========== VESTURLAND ==========
  {
    'id': 'glymur',
    'name': 'Glymur',
    'difficulty': 'Moderate',
    'lengthKm': 7,
    'durationMin': 180,
    'elevationGain': 350,
    'startLat': 64.3908,
    'startLng': -21.2667,
    'region': 'Vesturland',
    'description':
        'Glymur er næsthæsti foss Íslands (198m) og fallegasta gönguleið höfuðborgarsvæðisins. Leiðin fer yfir læk, í gegnum helli og upp að fossinum. Ógleymanlegt útsýni yfir Hvalfjörð. Krefjandi en gefandi ganga.',
    'highlights': [
      '198m hár foss',
      'Þverun læks',
      'Hellir',
      'Útsýni yfir Hvalfjörð'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði', 'Merktar leiðir'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 64.3908, 'lng': -21.2667},
      {'lat': 64.3950, 'lng': -21.2600}
    ]
  },
  {
    'id': 'kirkjufell',
    'name': 'Kirkjufell',
    'difficulty': 'Moderate',
    'lengthKm': 3.5,
    'durationMin': 90,
    'elevationGain': 350,
    'startLat': 64.9244,
    'startLng': -23.3122,
    'region': 'Vesturland',
    'description':
        'Kirkjufell er eitt af þekktustu fjalli Íslands og fannst í Game of Thrones. Stutt en brött ganga upp í fjallið með frábæru útsýni yfir Grundarfjörð og Kirkjufellsfoss. Ljósmyndaratoppur Snæfellsness.',
    'highlights': [
      'Game of Thrones fjall',
      'Kirkjufellsfoss',
      'Útsýni yfir Grundarfjörð',
      'Norðurljósastaður'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði', 'Kirkjufellsfoss'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 64.9244, 'lng': -23.3122},
      {'lat': 64.9280, 'lng': -23.3100}
    ]
  },
  {
    'id': 'hraunfossar',
    'name': 'Hraunfossar og Barnafoss',
    'difficulty': 'Easy',
    'lengthKm': 2.5,
    'durationMin': 45,
    'elevationGain': 30,
    'startLat': 64.7025,
    'startLng': -20.9792,
    'region': 'Vesturland',
    'description':
        'Hraunfossar eru röð af fossum sem síast upp úr hrauninu Hallmundarhrauni og renna í Hvítá. Barnafoss er kraftmikill foss skammt í burtu. Stutt og auðveld ganga á milli fossanna með stórfenglegri náttúru.',
    'highlights': ['Hraunfossar', 'Barnafoss', 'Hvítá', 'Hallmundarhraun'],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Kaffihús'],
    'images': ['https://images.unsplash.com/photo-1483347756197-71ef80e95f73'],
    'polyline': [
      {'lat': 64.7025, 'lng': -20.9792},
      {'lat': 64.7050, 'lng': -20.9750}
    ]
  },

  // ========== VESTFIRÐIR ==========
  {
    'id': 'hornstrandir',
    'name': 'Hornstrandir',
    'difficulty': 'Expert',
    'lengthKm': 45,
    'durationMin': 1440,
    'elevationGain': 1500,
    'startLat': 66.4461,
    'startLng': -22.4486,
    'region': 'Vestfirðir',
    'description':
        'Hornstrandir er óbyggt náttúrverndarsvæði á yst­a jaðri Vestfjarða. Þetta er eitt villtasta svæði Íslands með tófufjöllum, fuglabjargi og melabakkam. Aðeins aðgengilegt með bát. Heimkynni hinna snjöllu tófa. Krefjandi fjöldaga ganga.',
    'highlights': [
      'Ósnert víðerni',
      'Tófur',
      'Hornbjarg fuglabjargi',
      'Hornvík',
      'Hesteyri'
    ],
    'season': 'Júní - Ágúst',
    'facilities': ['Engar - fullt villilíf', 'Bátaferðir frá Ísafirði'],
    'images': ['https://images.unsplash.com/photo-1504280390367-361c6d9f38f4'],
    'polyline': [
      {'lat': 66.4461, 'lng': -22.4486},
      {'lat': 66.4600, 'lng': -22.4300}
    ]
  },
  {
    'id': 'dynjandi',
    'name': 'Dynjandi',
    'difficulty': 'Easy',
    'lengthKm': 1.5,
    'durationMin': 40,
    'elevationGain': 100,
    'startLat': 65.7314,
    'startLng': -23.1992,
    'region': 'Vestfirðir',
    'description':
        'Dynjandi, einnig kallaður Fjallfoss, er stórkostlegasti foss Vestfjarða. 100 metra hár breiðskipttur foss sem líkist brúðarslæðu. Sex minni fossar eru neðan við. Stutt og auðveld ganga upp að fossinum.',
    'highlights': [
      '100m hár foss',
      'Breiðskipttur',
      'Sex minni fossar',
      'Stórbrotið útsýni'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði', 'Salerni'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 65.7314, 'lng': -23.1992},
      {'lat': 65.7330, 'lng': -23.1980}
    ]
  },
  {
    'id': 'latrabjarg',
    'name': 'Látrabjarg',
    'difficulty': 'Easy',
    'lengthKm': 8,
    'durationMin': 150,
    'elevationGain': 50,
    'startLat': 65.5031,
    'startLng': -24.5253,
    'region': 'Vestfirðir',
    'description':
        'Látrabjarg er vestasta punktur Íslands og Evrópu. 14 km langt og allt að 440m hátt fuglabjargi. Þúsundir lunda, álka og langvíu koma hingað á varptímann. Ótrúleg upplifun að sjá lundana í nánd. Farðu varlega við bjargbrúnina!',
    'highlights': [
      'Vestasti punktur Evrópu',
      'Þúsundir lunda',
      '440m hátt bjargi',
      'Fuglaskoðun'
    ],
    'season': 'Maí - Ágúst (lundir)',
    'facilities': ['Bílastæði', 'Viti'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 65.5031, 'lng': -24.5253},
      {'lat': 65.5050, 'lng': -24.5200}
    ]
  },

  // ========== NORÐURLAND ==========
  {
    'id': 'dettifoss',
    'name': 'Dettifoss',
    'difficulty': 'Easy',
    'lengthKm': 4,
    'durationMin': 75,
    'elevationGain': 50,
    'startLat': 65.8147,
    'startLng': -16.3850,
    'region': 'Norðurland',
    'description':
        'Dettifoss er öflugasti foss Evrópu með 44 metra háum og 100 metra breiðum fossarli. Ótrúlegur kraftur vatnssins. Stutt ganga frá bílastæði að fossinum. Hægt að skoða báðar hliðar fossins.',
    'highlights': [
      'Öflugasti foss Evrópu',
      '44m hár, 100m breiður',
      'Jökulsá á Fjöllum',
      'Selfoss nálægt'
    ],
    'season': 'Júní - September',
    'facilities': ['Bílastæði', 'Salerni', 'Útsýnispallar'],
    'images': ['https://images.unsplash.com/photo-1483347756197-71ef80e95f73'],
    'polyline': [
      {'lat': 65.8147, 'lng': -16.3850},
      {'lat': 65.8160, 'lng': -16.3820}
    ]
  },
  {
    'id': 'hverfjall',
    'name': 'Hverfjall',
    'difficulty': 'Moderate',
    'lengthKm': 5.5,
    'durationMin': 105,
    'elevationGain': 150,
    'startLat': 65.6067,
    'startLng': -16.8722,
    'region': 'Norðurland',
    'description':
        'Hverfjall er 2500 ára gamall gígur við Mývatn. Fullkominn hringur með 1 km þvermál. Hægt að ganga í kringum brúnina eða niður í gíginn. Stórkostlegt útsýni yfir Mývatn og nágrenni.',
    'highlights': [
      'Fullkominn gígur',
      'Útsýni yfir Mývatn',
      'Dimmuborgir nálægt',
      'Krafla í fjarska'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði'],
    'images': ['https://images.unsplash.com/photo-1531366936337-7c912a4589a7'],
    'polyline': [
      {'lat': 65.6067, 'lng': -16.8722},
      {'lat': 65.6100, 'lng': -16.8700}
    ]
  },
  {
    'id': 'asbyrgi',
    'name': 'Ásbyrgi',
    'difficulty': 'Easy',
    'lengthKm': 6,
    'durationMin': 120,
    'elevationGain': 100,
    'startLat': 66.0214,
    'startLng': -16.5031,
    'region': 'Norðurland',
    'description':
        'Ásbyrgi er hestskófaformað gljúfur sem myndaðist í jökulhlaupum. Þéttur birkiskógur vex í gljúfrinu. Þjóðsagan segir að Sleipnir, áttfættur hestur Óðins, hafi myndað gljúfrið. Fallegur göngutúr upp að Eyjan.',
    'highlights': [
      'Hestskófaformi',
      'Þéttur skógur',
      'Eyjan útsýnisstaður',
      'Þjóðsaga'
    ],
    'season': 'Maí - September',
    'facilities': ['Tjaldsvæði', 'Salerni', 'Kaffihús'],
    'images': ['https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'],
    'polyline': [
      {'lat': 66.0214, 'lng': -16.5031},
      {'lat': 66.0250, 'lng': -16.5000}
    ]
  },

  // ========== AUSTURLAND ==========
  {
    'id': 'hengifoss',
    'name': 'Hengifoss',
    'difficulty': 'Moderate',
    'lengthKm': 5,
    'durationMin': 90,
    'elevationGain': 250,
    'startLat': 65.0861,
    'startLng': -14.8669,
    'region': 'Austurland',
    'description':
        'Hengifoss er þriðji hæsti foss Íslands (128m) með einkennandi rauðum leirlagum í klettunum. Litlanesfoss með basaltsúlur er á leiðinni upp. Falleg ganga með útsýni yfir Lagarfljót.',
    'highlights': [
      '128m hár foss',
      'Rauð leirlög',
      'Litlanesfoss',
      'Útsýni yfir Lagarfljót'
    ],
    'season': 'Maí - September',
    'facilities': ['Bílastæði', 'Salerni'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 65.0861, 'lng': -14.8669},
      {'lat': 65.0900, 'lng': -14.8650}
    ]
  },
  {
    'id': 'storurd',
    'name': 'Stórurð',
    'difficulty': 'Moderate',
    'lengthKm': 13,
    'durationMin': 300,
    'elevationGain': 400,
    'startLat': 65.5431,
    'startLng': -14.7386,
    'region': 'Austurland',
    'description':
        'Stórurð er fallegur dalur með risastórum grjótkambi og tær­blár­blúgrænum tjörnum. "Tröllað­alurinn" er eitt af falleg­ustu stö­ðum Ís­lands. Krefjandi ganga en ótrúlega gefandi.',
    'highlights': [
      'Risastór grjót',
      'Túrkísblá tjarnir',
      'Fjallaskógur',
      'Villta náttúra'
    ],
    'season': 'Júní - September',
    'facilities': ['Bílastæði'],
    'images': ['https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'],
    'polyline': [
      {'lat': 65.5431, 'lng': -14.7386},
      {'lat': 65.5500, 'lng': -14.7300}
    ]
  },
  {
    'id': 'vestrahorn',
    'name': 'Vestrahorn',
    'difficulty': 'Moderate',
    'lengthKm': 4,
    'durationMin': 90,
    'elevationGain': 200,
    'startLat': 64.2494,
    'startLng': -14.9506,
    'region': 'Austurland',
    'description':
        'Vestrahorn er glæsilegt fjall við Stokksnes með svörtum sandi og stórbrotinni ljósmyndatækifærum. "Batman fjallið" er vinsæll kvikmyndatökustaður. Stuttur göngutúr upp í fjallshlíðina.',
    'highlights': [
      'Batman fjallið',
      'Svartur sandur',
      'Útsýni yfir Stokksnes',
      'Ljósmyndatoppur'
    ],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Gjald til heimaeiganda'],
    'images': ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4'],
    'polyline': [
      {'lat': 64.2494, 'lng': -14.9506},
      {'lat': 64.2520, 'lng': -14.9480}
    ]
  },

  // ========== HÖFUÐBORGARSVÆÐIÐ ==========
  {
    'id': 'esja',
    'name': 'Esjan',
    'difficulty': 'Moderate',
    'lengthKm': 7,
    'durationMin': 180,
    'elevationGain': 780,
    'startLat': 64.2669,
    'startLng': -21.6208,
    'region': 'Höfuðborgarsvæðið',
    'description':
        'Esjan er húsafjall Reykvíkinga og vinsælasta gönguleiðin á höfuðborgarsvæðinu. Vel merkt leið upp að Steini (780m). Frábært útsýni yfir borgina og Faxaflóa. Hægt að klífa í toppin Þverfellshorn (914m) ef veður leyfir.',
    'highlights': [
      'Útsýni yfir Reykjavík',
      'Steinn útsýnisstaður',
      'Vel merktar leiðir',
      'Fjölskylduvæn'
    ],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Merktar leiðir'],
    'images': ['https://images.unsplash.com/photo-1483347756197-71ef80e95f73'],
    'polyline': [
      {'lat': 64.2669, 'lng': -21.6208},
      {'lat': 64.2750, 'lng': -21.6150}
    ]
  },
  {
    'id': 'heidmork',
    'name': 'Heiðmörk',
    'difficulty': 'Easy',
    'lengthKm': 12,
    'durationMin': 180,
    'elevationGain': 100,
    'startLat': 64.0833,
    'startLng': -21.7833,
    'region': 'Höfuðborgarsvæðið',
    'description':
        'Heiðmörk er stærsta útivistarsvæði höfuðborgarsvæðisins með víðáttumiklum skógi, tjörnum og hraunmyndunum. Fjölmargar merktar gönguleiðir í boði. Fullkomið fyrir fjölskyldur, hlaup og hjólareiðar.',
    'highlights': [
      'Rjúpnahæð',
      'Elliðavatn',
      'Skógargöngu­leiðir',
      'Tjaldsvæði'
    ],
    'season': 'Allt árið',
    'facilities': ['Bílastæði', 'Salerni', 'Grillpláss', 'Tjaldsvæði'],
    'images': ['https://images.unsplash.com/photo-1469854523086-cc02fe5d8800'],
    'polyline': [
      {'lat': 64.0833, 'lng': -21.7833},
      {'lat': 64.0900, 'lng': -21.7800}
    ]
  }
];

Future<void> main() async {
  print('🚀 Byrja að uploada gönguleiðum í Firestore...\n');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized\n');

    final firestore = FirebaseFirestore.instance;
    final collection = firestore.collection('trails');

    int uploaded = 0;
    int failed = 0;

    for (final trail in trails) {
      try {
        await collection.doc(trail['id'] as String).set(trail);
        print('✅ ${trail['name']} - uploaded');
        uploaded++;
      } catch (e) {
        print('❌ ${trail['name']} - failed: $e');
        failed++;
      }
    }

    print('\n📊 NIÐURSTÖÐUR:');
    print('✅ $uploaded gönguleiðir hlaðnar upp');
    print('❌ $failed gönguleiðir mistókust');
    print('\n✨ Lokið!');
  } catch (e) {
    print('❌ Villa: $e');
  }
}
