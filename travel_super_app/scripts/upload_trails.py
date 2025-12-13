#!/usr/bin/env python3
"""
Script to upload hiking trails to Firebase Firestore
Run with: python upload_trails.py
"""

import firebase_admin
from firebase_admin import credentials, firestore
import json

# Initialize Firebase
cred = credentials.Certificate('../android/app/google-services.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

# Trail data
trails = [
    {
        'id': 'laugavegur',
        'name': 'Laugavegurinn',
        'difficulty': 'Hard',
        'lengthKm': 55,
        'durationMin': 240,
        'elevationGain': 1200,
        'startLat': 63.9903,
        'startLng': -19.0612,
        'region': 'Halendi Islands',
        'description': 'Laugavegurinn er ein vinsaelasta gonguleid Islands og liggur fra Landmannalaugum til Thorsmerkur. Leidin bydur upp a otrulega fjolbreytta natturu med litriku fjollum, hraunvollum, joklum og graenu dolum. Gangan tekur venjulega 3-4 daga og krefst godrar undirbyrdur.',
        'highlights': [
            'Landmannalaugar hverasvædi',
            'Hrafntinnusker',
            'Alftavatn',
            'Emstrur',
            'Thorsmork'
        ],
        'season': 'Juni - September',
        'facilities': ['Fjallaskalar a leidinni', 'Merktar leidir', 'Tjaldsvædi'],
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
        'name': 'Fimmvorduhals',
        'difficulty': 'Expert',
        'lengthKm': 25,
        'durationMin': 720,
        'elevationGain': 1000,
        'startLat': 63.6325,
        'startLng': -19.4672,
        'region': 'Sudurland',
        'description': 'Fimmvorduhals er krefjandi dagsganga milli joklanna Eyjafjallajokuls og Myrdalsjokuls. Leidin byrjar vid Skoga og endar i Thorsmork. Thu gengur framhja 26 fossum og serd nytt hraun fra 2010 gosinu.',
        'highlights': [
            'Skogafoss',
            'Magni og Modi gigar',
            '26 fossar',
            'Utsýni yfir jokla',
            'Nytt hraun'
        ],
        'season': 'Juli - Agust',
        'facilities': ['Skali a Fimmvorduskala', 'Merktar leidir'],
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
        'name': 'Askja og Viti',
        'difficulty': 'Moderate',
        'lengthKm': 6,
        'durationMin': 150,
        'elevationGain': 150,
        'startLat': 65.0544,
        'startLng': -16.7519,
        'region': 'Halendi Islands',
        'description': 'Askja er stor innskotshringur i Dyngjufjollum. Viti er fallegur gigur med blaum vatni inni i Oskjunni. Thetta er einstakt landslag sem minnir a tunglid - NASA thjálfadi Apollo geimfara her.',
        'highlights': [
            'Viti gigur',
            'Askja stori hringurinn',
            'Tungllandslag',
            'Utsýni yfir halendid'
        ],
        'season': 'Juni - September',
        'facilities': ['Bilastaedi', 'Salerni'],
        'images': [
            'https://images.unsplash.com/photo-1531366936337-7c912a4589a7'
        ],
        'polyline': [
            {'lat': 65.0544, 'lng': -16.7519},
            {'lat': 65.0600, 'lng': -16.7400}
        ]
    },
    {
        'id': 'jokulsarlon',
        'name': 'Jokulsarlon',
        'difficulty': 'Easy',
        'lengthKm': 2,
        'durationMin': 40,
        'elevationGain': 10,
        'startLat': 64.0484,
        'startLng': -16.1806,
        'region': 'Sudurland',
        'description': 'Jokulsarlon er staersta jokullón Islands og einn vinsaelasti afangastadur landsins. Isjakarnir fljota haegt i loninu og reka a Demantastrondina. Stuttur gongutúr umhverfis lonid med otrulegu ljósmyndataekifaerum.',
        'highlights': [
            'Isjakarnir',
            'Demantastrond',
            'Selir i loninu',
            'Breidamerkurjokull'
        ],
        'season': 'Allt arid',
        'facilities': ['Bilastaedi', 'Salerni', 'Kaffihús', 'Bataferdir'],
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
        'id': 'glymur',
        'name': 'Glymur',
        'difficulty': 'Moderate',
        'lengthKm': 7,
        'durationMin': 180,
        'elevationGain': 350,
        'startLat': 64.3908,
        'startLng': -21.2667,
        'region': 'Vesturland',
        'description': 'Glymur er naesthæsti foss Islands (198m) og fallegasta gonguleid hofudborgarsvaedsins. Leidin fer yfir laek, i gegnum helli og upp ad fossinum. Ogleymanlegt utsýni yfir Hvalfjord.',
        'highlights': [
            '198m har foss',
            'Thverun laeks',
            'Hellir',
            'Utsýni yfir Hvalfjord'
        ],
        'season': 'Mai - September',
        'facilities': ['Bilastaedi', 'Merktar leidir'],
        'images': [
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4'
        ],
        'polyline': [
            {'lat': 64.3908, 'lng': -21.2667},
            {'lat': 64.3950, 'lng': -21.2600}
        ]
    },
    {
        'id': 'esja',
        'name': 'Esjan',
        'difficulty': 'Moderate',
        'lengthKm': 7,
        'durationMin': 180,
        'elevationGain': 780,
        'startLat': 64.2669,
        'startLng': -21.6208,
        'region': 'Hofudborgarsvædi',
        'description': 'Esjan er husafjall Reykvikinga og vinsaelasta gonguleidin a hofudborgarsvædinu. Vel merkt leid upp ad Steini (780m). Frabaert utsýni yfir borgina og Faxafloa.',
        'highlights': [
            'Utsýni yfir Reykjavik',
            'Steinn utsýnisstadar',
            'Vel merktar leidir',
            'Fjolskylduvæn'
        ],
        'season': 'Allt arid',
        'facilities': ['Bilastaedi', 'Salerni', 'Merktar leidir'],
        'images': [
            'https://images.unsplash.com/photo-1483347756197-71ef80e95f73'
        ],
        'polyline': [
            {'lat': 64.2669, 'lng': -21.6208},
            {'lat': 64.2750, 'lng': -21.6150}
        ]
    }
]

def upload_trails():
    """Upload trails to Firestore"""
    print('🚀 Byrja ad uploada gonguleidum i Firestore...\n')
    
    collection = db.collection('trails')
    uploaded = 0
    failed = 0
    
    for trail in trails:
        try:
            collection.document(trail['id']).set(trail)
            print(f"✅ {trail['name']} - uploaded")
            uploaded += 1
        except Exception as e:
            print(f"❌ {trail['name']} - failed: {e}")
            failed += 1
    
    print(f'\n📊 NIDURSTODUR:')
    print(f'✅ {uploaded} gonguleidir hladnar upp')
    print(f'❌ {failed} gonguleidir mistokust')
    print('\n✨ Lokid!')

if __name__ == '__main__':
    upload_trails()
