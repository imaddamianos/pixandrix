const functions = require("firebase-functions");
const admin = require("firebase-admin");

// Load service account key from environment variable
const serviceAccount = require("/Users/imad/serviceAccountKey.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://pixandrix-a51e4-default-rtdb.firebaseio.com/",
});

// Firestore reference
const firestore = admin.firestore();

// Function to send notifications to drivers
async function sendNotificationToDrivers(notificationData) {
  try {
    const driversSnapshot = await firestore
      .collection("drivers")
      .where("isAvailable", "==", true)
      .get();

    const tokens = [];
    driversSnapshot.forEach((doc) => {
      const driverData = doc.data();
      if (driverData.fcmToken) {
        tokens.push(driverData.fcmToken);
      }
    });

    if (tokens.length > 0) {
      const payload = {
        notification: {
          title: notificationData.title,
          body: notificationData.body,
        },
      };

      await admin.messaging().sendToDevice(tokens, payload);
      console.log("Notifications sent successfully to drivers.");
    } else {
      console.log("No drivers available to receive notifications.");
    }
  } catch (error) {
    console.error("Error sending notifications:", error);
  }
}

// Cloud Function to trigger on new document creation in Realtime Database
exports.sendNotificationToDrivers = functions.database
  .ref("orders/{orderId}")
  .onCreate(async (snapshot, context) => {
    try {
      const notificationData = {
        title: "New Order",
        body: `Order ID: ${context.params.orderId} has been created.`,
      };

      await sendNotificationToDrivers(notificationData);
    } catch (error) {
      console.error("Error in onCreate function:", error);
    }
  });
