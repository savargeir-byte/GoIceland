const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./firebase/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function clearAndUpload() {
  console.log('🧹 CLEARING OLD DATA FROM FIREBASE...\n');
  
  // Delete all places
  const placesSnapshot = await db.collection('places').get();
  console.log(`Found ${placesSnapshot.size} places to delete`);
  
  const deletePromises = [];
  placesSnapshot.docs.forEach(doc => {
    deletePromises.push(doc.ref.delete());
  });
  
  await Promise.all(deletePromises);
  console.log('✅ Deleted all old places\n');
  
  // Upload enriched places
  console.log('📦 UPLOADING ENRICHED PLACES...\n');
  const placesPath = path.join(__dirname, 'data', 'firestore_top_places.json');
  const placesData = JSON.parse(fs.readFileSync(placesPath, 'utf8'));
  
  const batch = db.batch();
  let count = 0;
  
  for (const [id, place] of Object.entries(placesData)) {
    const docRef = db.collection('places').doc(id);
    batch.set(docRef, place);
    count++;
    
    // Commit every 500 documents
    if (count % 500 === 0) {
      await batch.commit();
      console.log(`   ✓ Uploaded ${count} places...`);
    }
  }
  
  // Commit remaining
  if (count % 500 !== 0) {
    await batch.commit();
  }
  
  console.log(`✅ Uploaded ${count} enriched places with images\n`);
  
  // Upload trails
  console.log('🥾 UPLOADING TRAILS...\n');
  const trailsPath = path.join(__dirname, 'data', 'firestore_trails_enriched.json');
  const trailsData = JSON.parse(fs.readFileSync(trailsPath, 'utf8'));
  
  const trailsBatch = db.batch();
  let trailCount = 0;
  
  for (const trail of trailsData) {
    const docRef = db.collection('trails').doc(trail.id);
    trailsBatch.set(docRef, trail);
    trailCount++;
    
    if (trailCount % 500 === 0) {
      await trailsBatch.commit();
      console.log(`   ✓ Uploaded ${trailCount} trails...`);
    }
  }
  
  if (trailCount % 500 !== 0) {
    await trailsBatch.commit();
  }
  
  console.log(`✅ Uploaded ${trailCount} trails\n`);
  
  console.log('✅ SUCCESS!');
  console.log('📊 Summary:');
  console.log(`   Places: ${count} (all with images & descriptions)`);
  console.log(`   Trails: ${trailCount}`);
}

clearAndUpload()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('❌ Error:', error);
    process.exit(1);
  });
