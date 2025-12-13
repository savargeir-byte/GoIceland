#!/usr/bin/env python3
"""
Alternative upload script using pyrebase (Firebase Web API)
Install with: pip install pyrebase4
"""

import json

# For now, let's use the Flutter app to upload via a Dart script
# This is more straightforward since we already have Firebase configured there

print("""
╔══════════════════════════════════════════════════════════╗
║  Firebase Upload fyrir Gönguleiðir                       ║
╚══════════════════════════════════════════════════════════╝

Til að uploada gönguleiðunum í Firebase, notaðu Flutter:

1. Opna travel_super_app í terminal
2. Keyra: dart run scripts/upload_trails_to_firestore.dart

EÐA nota Firebase Console:
1. Fara á https://console.firebase.google.com
2. Velja þinn verkefni
3. Fara í Firestore Database
4. Import JSON data beint

Fyrir núna höfum við 6 leiðir með fullkomnum lýsingum:
✅ Laugavegurinn
✅ Fimmvörðuháls  
✅ Askja og Víti
✅ Jökulsárlón
✅ Glymur
✅ Esjan

Þessar leiðir eru already í trail_api.dart fallback data,
svo appið virkar strax án Firebase!
""")
