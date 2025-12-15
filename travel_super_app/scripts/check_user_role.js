/**
 * Check and fix user role in Firestore
 */

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
const serviceAccount = require(path.join(__dirname, '../../go_iceland/firebase/serviceAccountKey.json'));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://go-iceland-default-rtdb.firebaseio.com'
});

const db = admin.firestore();
const auth = admin.auth();

async function checkAndFixUserRole() {
  try {
    // List all users
    const listUsers = await auth.listUsers();
    console.log('\n📋 All Firebase Auth Users:');
    console.log('═'.repeat(80));
    
    for (const user of listUsers.users) {
      console.log(`\nUser: ${user.email}`);
      console.log(`  UID: ${user.uid}`);
      
      // Check Firestore user document
      const userDoc = await db.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        const userData = userDoc.data();
        console.log(`  Role: ${userData.role || 'NOT SET'}`);
        console.log(`  Created: ${userData.createdAt || 'unknown'}`);
        
        // Fix if role is missing or wrong
        if (!userData.role || userData.role !== 'admin') {
          console.log(`  ⚠️  Fixing role to 'admin'...`);
          await db.collection('users').doc(user.uid).set({
            email: user.email,
            role: 'admin',
            displayName: user.displayName || user.email?.split('@')[0],
            createdAt: userData.createdAt || admin.firestore.FieldValue.serverTimestamp(),
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
          console.log(`  ✅ Role updated to 'admin'`);
        }
      } else {
        console.log(`  ⚠️  No Firestore document found! Creating...`);
        await db.collection('users').doc(user.uid).set({
          email: user.email,
          role: 'admin',
          displayName: user.displayName || user.email?.split('@')[0],
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log(`  ✅ User document created with 'admin' role`);
      }
    }
    
    console.log('\n' + '═'.repeat(80));
    console.log('✅ User role check complete!\n');
    
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
  
  process.exit(0);
}

checkAndFixUserRole();
