// Upload places with images to Firestore using Firebase Admin SDK
// Run: node upload_places.js

const admin = require('firebase-admin');
const fs = require('fs');

// You need to download your Firebase Admin SDK key from:
// Firebase Console > Project Settings > Service Accounts > Generate new private key
// Save it as 'serviceAccountKey.json' in this directory

try {
  const serviceAccount = require('./serviceAccountKey.json');
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  
  const db = admin.firestore();
  const places = JSON.parse(fs.readFileSync('places_with_images.json', 'utf8'));
  
  console.log(`🔥 Uploading ${places.length} places to Firestore...`);
  
  const batch = db.batch();
  
  places.forEach(place => {
    const docRef = db.collection('places').doc(place.id);
    batch.set(docRef, place, { merge: true });
  });
  
  batch.commit()
    .then(() => {
      console.log(`✅ Successfully uploaded ${places.length} places with images!`);
      
      // Verify
      return db.collection('places').limit(5).get();
    })
    .then(snapshot => {
      console.log('\n📋 Sample places in Firestore:');
      snapshot.forEach(doc => {
        const data = doc.data();
        const hasImage = data.image && data.image.length > 0;
        console.log(`   • ${data.name} - Image: ${hasImage ? '✅' : '❌'}`);
      });
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Error:', error);
      process.exit(1);
    });
    
} catch (error) {
  console.error('❌ Error loading serviceAccountKey.json');
  console.log('\n📝 To upload places to Firebase:');
  console.log('1. Go to Firebase Console > Project Settings > Service Accounts');
  console.log('2. Click "Generate new private key"');
  console.log('3. Save as serviceAccountKey.json in this directory');
  console.log('4. Run: node upload_places.js');
  console.log('\n💡 For now, you can manually import places_with_images.json in Firebase Console');
  process.exit(1);
}
