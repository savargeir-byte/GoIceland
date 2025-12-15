// Upload places and trails to Firebase using Node.js
const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./firebase/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadPlaces() {
  console.log('🔥 UPLOADING PLACES TO FIREBASE');
  console.log('='.repeat(60));
  
  // Load places
  const placesPath = path.join(__dirname, 'data', 'firestore_top_places.json');
  const placesData = JSON.parse(fs.readFileSync(placesPath, 'utf-8'));
  
  console.log(`📦 Loaded ${Object.keys(placesData).length} places`);
  
  const batch = db.batch();
  let count = 0;
  
  for (const [placeId, placeData] of Object.entries(placesData)) {
    const docRef = db.collection('places').doc(placeId);
    batch.set(docRef, placeData, { merge: true });
    count++;
  }
  
  await batch.commit();
  console.log(`✅ Uploaded ${count} places`);
  
  return count;
}

async function uploadTrails() {
  console.log('\n🥾 UPLOADING TRAILS TO FIREBASE');
  console.log('='.repeat(60));
  
  // Load trails
  const trailsPath = path.join(__dirname, 'data', 'firestore_trails_enriched.json');
  const trailsData = JSON.parse(fs.readFileSync(trailsPath, 'utf-8'));
  
  console.log(`📦 Loaded ${Object.keys(trailsData).length} trails`);
  
  const batch = db.batch();
  let count = 0;
  
  for (const [trailId, trailData] of Object.entries(trailsData)) {
    const docRef = db.collection('trails').doc(trailId);
    batch.set(docRef, trailData, { merge: true });
    count++;
  }
  
  await batch.commit();
  console.log(`✅ Uploaded ${count} trails`);
  
  return count;
}

async function main() {
  try {
    const placesCount = await uploadPlaces();
    const trailsCount = await uploadTrails();
    
    console.log('\n' + '='.repeat(60));
    console.log('✅ SUCCESS!');
    console.log(`📊 Total uploaded:`);
    console.log(`   Places: ${placesCount}`);
    console.log(`   Trails: ${trailsCount}`);
    console.log('\n🎉 Check Firebase Console to verify!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

main();
