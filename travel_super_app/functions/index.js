const {onSchedule} = require("firebase-functions/v2/scheduler");
const {onRequest} = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

/**
 * Monthly POI Update Function
 * 
 * Runs: 1st day of each month at 03:00 Iceland time
 * Updates: All places from master JSON source
 * 
 * Deploy: firebase deploy --only functions:monthlyUpdatePlaces
 */
exports.monthlyUpdatePlaces = onSchedule({
  schedule: "0 3 1 * *", // Every 1st of month at 3 AM
  timeZone: "Atlantic/Reykjavik",
  region: "us-central1",
}, async (event) => {
  const db = admin.firestore();
    
    console.log("🌋 GO ICELAND - Monthly Update Started");
    console.log(`Time: ${new Date().toISOString()}`);

    try {
      // Fetch latest data from master source
      // TODO: Replace with your actual JSON URL after hosting it
      // Options:
      // 1. GitHub: https://raw.githubusercontent.com/USERNAME/iceland-poi-data/main/iceland_places_master.json
      // 2. Gist: https://gist.githubusercontent.com/USERNAME/GIST_ID/raw/iceland_places_master.json
      // 3. Firebase Storage: https://firebasestorage.googleapis.com/v0/b/go-iceland.appspot.com/o/public%2Ficeland_places_master.json?alt=media
      const dataUrl = "https://raw.githubusercontent.com/YOUR_USERNAME/iceland-poi-data/main/iceland_places_master.json";
      
      console.log(`Fetching data from: ${dataUrl}`);
      const response = await fetch(dataUrl);
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const data = await response.json();
      const places = data.places || [];
      
      console.log(`Fetched ${places.length} places`);

      // Update in batches (Firestore limit: 500 operations per batch)
      const batchSize = 500;
      let totalUpdated = 0;

      for (let i = 0; i < places.length; i += batchSize) {
        const batch = db.batch();
        const batchPlaces = places.slice(i, i + batchSize);
        
        batchPlaces.forEach((place) => {
          const ref = db.collection("places").doc(place.id);
          batch.set(ref, {
            ...place,
            lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
            autoUpdated: true,
          }, { merge: true });
        });

        await batch.commit();
        totalUpdated += batchPlaces.length;
        
        console.log(`Batch ${Math.floor(i / batchSize) + 1} committed (${totalUpdated}/${places.length})`);
      }

      // Log update to history
      await db.collection("system").doc("last_update").set({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        placesUpdated: totalUpdated,
        status: "success",
        dataSource: dataUrl,
      });

      console.log(`✅ MONTHLY UPDATE COMPLETE: ${totalUpdated} places updated`);
      
      return {
        success: true,
        placesUpdated: totalUpdated,
      };

    } catch (error) {
      console.error("❌ Monthly update failed:", error);
      
      // Log error
      await db.collection("system").doc("last_update").set({
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        status: "error",
        error: error.message,
      });

      throw error;
    }
});

/**
 * Manual Update Trigger (HTTP)
 * 
 * For testing or manual updates
 * Call: https://YOUR_REGION-YOUR_PROJECT.cloudfunctions.net/manualUpdatePlaces
 */
exports.manualUpdatePlaces = onRequest({region: "us-central1"}, async (req, res) => {
  const db = admin.firestore();
  
  console.log("🔧 Manual update triggered");

  try {
    // Reuse the same logic
    const dataUrl = "https://raw.githubusercontent.com/your-repo/iceland-poi/main/iceland_places.json";
    
    const response = await fetch(dataUrl);
    const data = await response.json();
    const places = data.places || [];

    const batchSize = 500;
    let totalUpdated = 0;

    for (let i = 0; i < places.length; i += batchSize) {
      const batch = db.batch();
      const batchPlaces = places.slice(i, i + batchSize);
      
      batchPlaces.forEach((place) => {
        const ref = db.collection("places").doc(place.id);
        batch.set(ref, {
          ...place,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          autoUpdated: false,
          manualUpdate: true,
        }, { merge: true });
      });

      await batch.commit();
      totalUpdated += batchPlaces.length;
    }

    await db.collection("system").doc("last_update").set({
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      placesUpdated: totalUpdated,
      status: "success",
      trigger: "manual",
    });

    res.status(200).json({
      success: true,
      message: `Updated ${totalUpdated} places`,
    });

  } catch (error) {
    console.error("Error:", error);
    res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

/**
 * Place Statistics Update
 * 
 * Runs daily to update place statistics
 */
exports.updatePlaceStats = onSchedule({
  schedule: "0 4 * * *", // Daily at 4 AM
  timeZone: "Atlantic/Reykjavik",
  region: "us-central1",
}, async (event) => {
    const db = admin.firestore();
    
    console.log("📊 Updating place statistics");

    try {
      const placesSnapshot = await db.collection("places").get();
      
      // Calculate stats
      const stats = {
        totalPlaces: placesSnapshot.size,
        byCategory: {},
        byRegion: {},
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      };

      placesSnapshot.forEach((doc) => {
        const data = doc.data();
        
        // Count by category
        const category = data.category || "other";
        stats.byCategory[category] = (stats.byCategory[category] || 0) + 1;
        
        // Count by region
        const region = data.region || "other";
        stats.byRegion[region] = (stats.byRegion[region] || 0) + 1;
      });

      // Save stats
      await db.collection("system").doc("stats").set(stats);

      console.log(`✅ Stats updated: ${stats.totalPlaces} places`);
      
      return stats;

    } catch (error) {
      console.error("❌ Stats update failed:", error);
      throw error;
    }
});

/**
 * Health Check Endpoint
 */
exports.healthCheck = onRequest({region: "us-central1"}, (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "GO ICELAND Cloud Functions",
    version: "1.0.0",
    timestamp: new Date().toISOString(),
  });
});
