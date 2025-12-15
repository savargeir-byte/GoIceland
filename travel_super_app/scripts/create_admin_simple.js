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

const auth = admin.auth();
const db = admin.firestore();

async function createAdminUser() {
  console.log('\n🔐 GO ICELAND - Admin User Setup\n');
  
  // Get user input
  const email = 'admin@goiceland.is';
  const password = 'admin123456';
  const displayName = 'Admin User';
  const role = 'admin';

  console.log(`Creating user: ${email}`);
  console.log(`Display Name: ${displayName}`);
  console.log(`Role: ${role}\n`);

  try {
    // Create user in Firebase Auth
    console.log('⏳ Creating Firebase Auth user...');
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: true
    });

    console.log(`✅ Firebase Auth user created: ${userRecord.uid}`);

    // Create user document in Firestore
    console.log('⏳ Creating Firestore user document...');
    await db.collection('users').doc(userRecord.uid).set({
      email: email,
      displayName: displayName,
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`✅ Firestore user document created\n`);

    console.log('🎉 SUCCESS! Admin user created:\n');
    console.log(`   UID:   ${userRecord.uid}`);
    console.log(`   Email: ${email}`);
    console.log(`   Name:  ${displayName}`);
    console.log(`   Role:  ${role}`);
    console.log(`   Password: ${password}`);
    console.log('\n💡 You can now login to the admin panel with these credentials.\n');

  } catch (error) {
    console.error('\n❌ Error creating user:', error.message);
    
    if (error.code === 'auth/email-already-exists') {
      console.log('\n💡 User already exists. Getting user info...');
      try {
        const userRecord = await auth.getUserByEmail(email);
        console.log(`   UID: ${userRecord.uid}`);
        console.log('\n   To update role, go to Firestore:');
        console.log(`   users/${userRecord.uid} → Update "role" field to: ${role}\n`);
      } catch (e) {
        console.error('Could not fetch user:', e.message);
      }
    }
  } finally {
    process.exit(0);
  }
}

createAdminUser();
