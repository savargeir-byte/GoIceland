const admin = require('firebase-admin');

// Load service account
const serviceAccount = require('../../go_iceland/firebase/serviceAccountKey.json');

// Initialize Firebase Admin SDK
try {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
  });
  console.log('✅ Firebase Admin initialized successfully');
} catch (error) {
  console.error('❌ Error initializing Firebase:', error.message);
  process.exit(1);
}

const db = admin.firestore();

async function createAdminInFirestore() {
  console.log('\n🔐 GO ICELAND - Admin Setup (Firestore Only)\n');
  console.log('⚠️  Firebase Authentication seems disabled.');
  console.log('    Creating admin role in Firestore for manual user setup.\n');
  
  // Admin user details
  const userId = 'MANUAL_SETUP_REQUIRED';
  const email = 'admin@goiceland.is';
  const displayName = 'Admin User';
  const role = 'admin';

  try {
    // Create placeholder document
    console.log('⏳ Creating admin role document in Firestore...');
    await db.collection('users').doc(userId).set({
      email: email,
      displayName: displayName,
      role: role,
      setupInstructions: 'Replace this document ID with your Firebase Auth UID',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`✅ Admin role document created in Firestore\n`);

    console.log('📋 MANUAL SETUP REQUIRED:\n');
    console.log('1. Go to Firebase Console: https://console.firebase.google.com/');
    console.log('2. Select "go-iceland" project');
    console.log('3. Go to Authentication → Users → Add user');
    console.log(`   Email: ${email}`);
    console.log('   Password: (choose secure password, e.g., admin123456)');
    console.log('4. Copy the UID of the created user');
    console.log('5. Go to Firestore Database → users collection');
    console.log(`6. Delete document: "${userId}"`);
    console.log('7. Create NEW document with the UID as document ID:');
    console.log('   {');
    console.log(`     "email": "${email}",`);
    console.log(`     "displayName": "${displayName}",`);
    console.log(`     "role": "${role}"`);
    console.log('   }');
    console.log('\n8. Return to admin panel and login!\n');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
  } finally {
    process.exit(0);
  }
}

createAdminInFirestore();
