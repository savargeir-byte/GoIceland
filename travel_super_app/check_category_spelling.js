const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('./android/app/google-services.json');
admin.initializeApp({
  credential: admin.credential.cert({
    projectId: serviceAccount.project_info.project_id,
    clientEmail: "firebase-adminsdk-xxxxx@go-iceland.iam.gserviceaccount.com",
    privateKey: "dummy"
  })
});

const db = admin.firestore();

async function checkCategories() {
  console.log('\n📊 Checking Category Spellings in Firestore...');
  console.log('='.repeat(70));
  
  const snapshot = await db.collection('places').limit(100).get();
  const categories = new Set();
  
  snapshot.forEach(doc => {
    const category = doc.data().category;
    if (category) categories.add(category);
  });
  
  console.log('\n✅ Categories found in first 100 places:\n');
  Array.from(categories).sort().forEach(cat => {
    console.log(`   ${cat}`);
  });
  
  console.log('\n' + '='.repeat(70));
}

checkCategories().catch(console.error);
