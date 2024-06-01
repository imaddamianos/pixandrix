const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
const firestore = admin.firestore();

exports.sendNotification = functions.firestore
  .document('orders/')
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

  exports.checkOrderTime = functions.firestore
  .document('orders/}')
  .onWrite(async (change, context) => {
    const newOrderData = change.after.data();
    const oldOrderData = change.before.data();

    if (!newOrderData || !oldOrderData) return;

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
  });

  async function sendNotification(userId, notification) {
    // Implement your logic to send notification to the user with userId
    // This could involve FCM messaging or other notification services
    console.log(`Sending notification to user ${userId}: ${JSON.stringify(notification)}`);
  }