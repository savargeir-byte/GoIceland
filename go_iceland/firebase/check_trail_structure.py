#!/usr/bin/env python3
"""Check trail data structure in Firestore"""

from firebase_admin import credentials, firestore
import firebase_admin
import json

# Initialize Firebase
cred = credentials.Certificate('serviceAccountKey.json')
app = firebase_admin.initialize_app(cred, name='check_trail')
db = firestore.client(app)

# Get a sample trail
doc = db.collection('trails').limit(1).get()[0]
data = doc.to_dict()

print("Trail keys:", list(data.keys()))
print()

if 'polyline' in data:
    polyline = data['polyline']
    print(f"Has polyline: {len(polyline)} points")
    print(f"First point: {polyline[0] if polyline else 'None'}")
else:
    print("No polyline field")

if 'coordinates' in data:
    print(f"Has coordinates: {data['coordinates']}")

# Clean up
firebase_admin.delete_app(app)
