// seed-firestore.js
// Firebase Admin SDK script to populate Firestore with Icelandic POIs and trails
// Usage: node seed-firestore.js

const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// Initialize Firebase Admin with service account
// Download serviceAccountKey.json from Firebase Console > Project Settings > Service Accounts
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  // Optional: specify database URL if needed
  // databaseURL: "https://your-project-id.firebaseio.com"
});

const db = admin.firestore();

// Load seed data
const placesPath = path.join(__dirname, '../assets/seed/places_seed.json');
const trailsPath = path.join(__dirname, '../assets/seed/trails_seed.json');

const places = JSON.parse(fs.readFileSync(placesPath, 'utf8'));
const trails = JSON.parse(fs.readFileSync(trailsPath, 'utf8'));

async function seedPlaces() {
  console.log(`🌍 Seeding ${places.length} places...`);
  const batch = db.batch();
  
  places.forEach(place => {
    const ref = db.collection('places').doc(place.id);
    batch.set(ref, place);
  });
  
  await batch.commit();
  console.log('✅ Places seeded successfully');
}

async function seedTrails() {
  console.log(`🥾 Seeding ${trails.length} trails...`);
  const batch = db.batch();
  
  trails.forEach(trail => {
    const ref = db.collection('trails').doc(trail.id);
    batch.set(ref, trail);
  });
  
  await batch.commit();
  console.log('✅ Trails seeded successfully');
}

async function seedCollections() {
  console.log('📚 Creating curated collections...');
  
  // Today's Picks - mix of popular places
  const todaysPicks = {
    id: 'todays_picks',
    name: 'Today\'s Picks',
    description: 'Handpicked destinations for today',
    placeIds: [
      'jokulsarlon',
      'blue_lagoon',
      'gullfoss',
      'reynisfjara',
      'seljalandsfoss',
      'thingvellir'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  // Nearby Wonders - South Coast favorites
  const nearbyWonders = {
    id: 'nearby_wonders',
    name: 'Nearby Wonders',
    description: 'Popular destinations near you',
    placeIds: [
      'skogafoss',
      'seljalandsfoss',
      'reynisfjara',
      'vik',
      'diamond_beach'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  // Trending - Most popular right now
  const trending = {
    id: 'trending',
    name: 'Trending in Iceland',
    description: 'What travelers are visiting now',
    placeIds: [
      'jokulsarlon',
      'blue_lagoon',
      'godafoss',
      'dettifoss',
      'akureyri'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  // Hidden Gems - Lesser-known spots
  const hiddenGems = {
    id: 'hidden_gems',
    name: 'Hidden Gems',
    description: 'Off-the-beaten-path treasures',
    placeIds: [
      'hvitserkur',
      'fjadrargljufur',
      'stokksnes',
      'grjotagja',
      'seydisfjordur'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  // Food Highlights
  const foodHighlights = {
    id: 'food_highlights',
    name: 'Food Highlights',
    description: 'Best dining experiences',
    placeIds: [
      'hofn', // Famous for lobster
      'akureyri',
      'husavik',
      'vik'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  // Hiking Trails
  const hikingTrails = {
    id: 'hiking_trails',
    name: 'Hiking Trails Near You',
    description: 'Best trails for all skill levels',
    trailIds: [
      'reykjadalur_trail',
      'glymur',
      'svartifoss_trail',
      'esjan',
      'laugavegur'
    ],
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  };
  
  const collections = [
    todaysPicks,
    nearbyWonders,
    trending,
    hiddenGems,
    foodHighlights,
    hikingTrails
  ];
  
  const batch = db.batch();
  collections.forEach(collection => {
    const ref = db.collection('collections').doc(collection.id);
    batch.set(ref, collection);
  });
  
  await batch.commit();
  console.log('✅ Collections created successfully');
}

async function seedAll() {
  try {
    console.log('🚀 Starting Firestore seed...\n');
    
    await seedPlaces();
    await seedTrails();
    await seedCollections();
    
    console.log('\n🎉 All data seeded successfully!');
    console.log('\n📊 Summary:');
    console.log(`   Places: ${places.length}`);
    console.log(`   Trails: ${trails.length}`);
    console.log(`   Collections: 6`);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding Firestore:', error);
    process.exit(1);
  }
}

// Run seed
seedAll();
