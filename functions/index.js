const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document('orders/')
  .onCreate((snapshot, context) => {
    const newData = snapshot.data();

    // Constructing the notification payload
    const payload = {
      notification: {
        title: 'New Document Added',
        body: 'A new document has been added to your collection.',
      },
    };

    // Sending the notification to a specific topic or device token
    // For example, sending to a specific topic:
    return admin.messaging().sendToTopic('new_document_notifications', payload);
  });
