const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const firestore = admin.firestore();

// Function to send a notification when a new document is added to the "orders" collection
exports.sendNotification = functions.firestore
  .document('orders/{orderId}')
  .onCreate((snapshot, context) => {
    const newData = snapshot.data();

    const payload = {
      notification: {
        title: 'New Document Added',
        body: 'A new document has been added to your collection.',
      },
    };

    return admin.messaging().sendToTopic('new_document_notifications', payload);
  });

// Helper function to send a notification to a specific user
async function sendNotification(userId, notification) {
  const userRef = firestore.collection('users').doc(userId);
  const userDoc = await userRef.get();

  if (userDoc.exists) {
    const userData = userDoc.data();
    const tokens = userData.fcmTokens || [];

    const payload = {
      notification: notification,
    };

    return admin.messaging().sendToDevice(tokens, payload);
  }
}

// Function to check the order time and send a notification when the time left crosses a threshold
exports.checkOrderTime = functions.firestore
  .document('orders/{orderId}')
  .onWrite(async (change, context) => {
    const newOrderData = change.after.data();
    const oldOrderData = change.before.data();

    if (!newOrderData || !oldOrderData) return null;

    const timeThreshold = 10 * 60 * 1000; // 10 minutes in milliseconds
    const currentTime = Date.now();

    if (oldOrderData.timeLeft < timeThreshold && newOrderData.timeLeft >= timeThreshold) {
      // Time left just crossed the threshold - send notification
      const notification = {
        title: 'Order Approaching Deadline!',
        body: `Check order ${newOrderData.orderId}`,
      };
      await sendNotification(newOrderData.userId, notification);
    }

    return null;
  });
