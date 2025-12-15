const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require('./firebase/serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function uploadAllPlaces() {
  console.log('🔥 UPLOADING ALL 4,972 PLACES TO FIREBASE\n');
  
  // Load all places from local database
  const placesPath = path.join(__dirname, 'data', 'iceland_clean.json');
  const allPlaces = JSON.parse(fs.readFileSync(placesPath, 'utf8'));
  
  console.log(`📦 Loaded ${allPlaces.length} places from local database\n`);
  
  let uploadedCount = 0;
  const batchSize = 500;
  
  // Process in batches
  for (let i = 0; i < allPlaces.length; i += batchSize) {
    const batch = db.batch();
    const chunk = allPlaces.slice(i, i + batchSize);
    
    for (const place of chunk) {
      // Create proper place structure
      const placeData = {
        id: place.id || `${place.lat}${place.lng || place.lon}`.replace(/\./g, '').replace(/-/g, ''),
        name: place.name,
        category: place.category,
        type: place.category,
        lat: place.lat,
        lon: place.lng || place.lon,
        lng: place.lng || place.lon,
        latitude: place.lat,
        longitude: place.lng || place.lon,
        country: 'IS'
      };
      
      // Add optional fields if they exist
      if (place.description) placeData.description = { short: place.description };
      if (place.rating) placeData.rating = place.rating;
      if (place.region) placeData.region = place.region;
      if (place.thumbnail) {
        placeData.media = {
          images: [place.thumbnail],
          hero_image: place.thumbnail,
          thumbnail: place.thumbnail
        };
        placeData.images = [place.thumbnail];
        placeData.image = place.thumbnail;
      }
      if (place.website) placeData.meta = { ...placeData.meta, website: place.website };
      if (place.phone) placeData.meta = { ...placeData.meta, phone: place.phone };
      if (place.opening_hours) placeData.meta = { ...placeData.meta, opening_hours: place.opening_hours };
      if (place.cuisine) placeData.meta = { ...placeData.meta, cuisine: place.cuisine };
      
      const docRef = db.collection('places').doc(placeData.id);
      batch.set(docRef, placeData);
    }
    
    await batch.commit();
    uploadedCount += chunk.length;
    console.log(`   ✓ Uploaded ${uploadedCount}/${allPlaces.length} places...`);
  }
  
  console.log(`\n✅ SUCCESS! Uploaded all ${uploadedCount} places to Firebase`);
  console.log('\n📊 Now your app will show ALL places from Iceland!');
}

uploadAllPlaces()
  .then(() => process.exit(0))
  .catch(error => {
    console.error('❌ Error:', error);
    process.exit(1);
  });
