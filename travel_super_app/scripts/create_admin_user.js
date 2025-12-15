const admin = require('firebase-admin');
const readline = require('readline');

// Initialize Firebase Admin
const serviceAccount = require('../../go_iceland/firebase/serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`
  });
}

const auth = admin.auth();
const db = admin.firestore();

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(prompt) {
  return new Promise((resolve) => {
    rl.question(prompt, resolve);
  });
}

async function createAdminUser() {
  console.log('\n🔐 GO ICELAND - Admin User Setup\n');
  console.log('This script will create a new admin user with Firebase Auth + Firestore.\n');

  try {
    // Get user details
    const email = await question('📧 Admin email: ');
    const password = await question('🔑 Password (min 6 chars): ');
    const displayName = await question('👤 Display name: ');
    
    const roleChoice = await question('\n🎭 Role:\n  1. Admin (full access)\n  2. Editor (content management)\n  3. Viewer (read-only)\n\nSelect (1-3): ');
    
    const roles = ['admin', 'editor', 'viewer'];
    const roleIndex = parseInt(roleChoice) - 1;
    const role = roles[roleIndex] || 'viewer';

    console.log('\n⏳ Creating user...\n');

    // Create user in Firebase Auth
    const userRecord = await auth.createUser({
      email: email,
      password: password,
      displayName: displayName,
      emailVerified: true
    });

    console.log(`✅ Firebase Auth user created: ${userRecord.uid}`);

    // Create user document in Firestore
    await db.collection('users').doc(userRecord.uid).set({
      email: email,
      displayName: displayName,
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log(`✅ Firestore user document created with role: ${role}`);

    console.log('\n🎉 SUCCESS! Admin user created:\n');
    console.log(`   UID:   ${userRecord.uid}`);
    console.log(`   Email: ${email}`);
    console.log(`   Name:  ${displayName}`);
    console.log(`   Role:  ${role}`);
    console.log('\n💡 You can now login to the admin panel with these credentials.\n');

  } catch (error) {
    console.error('\n❌ Error creating user:', error.message);
    
    if (error.code === 'auth/email-already-exists') {
      console.log('\n💡 TIP: User already exists. To update role:');
      console.log('   1. Get UID from Firebase Console → Authentication');
      console.log('   2. Go to Firestore → users/{uid}');
      console.log('   3. Update "role" field to: admin, editor, or viewer\n');
    }
  } finally {
    rl.close();
    process.exit(0);
  }
}

createAdminUser();
