const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

exports.sendPushNotificationToFCMToken = functions.firestore.document('messages/anonymous/collection/{uid}').onWrite(async (event) => {
    const senderDisplayName = event.after.get('senderDisplayName');
    const text = event.after.get('text');

    // var message2 = {
    //     notification: {
    //         title: senderDisplayName,
    //         body: text
    //     },
    //     token: "e-jQIkBwOULQrrym19C6TT:APA91bH-OWT2bJYs4kayK5q57Xo2_vAvCQt6RUGlZXSmROokwznWgv7jgxmayhMsZXPXgrN9D0lxKENvRGkd4pEwfvIV4Kx9j-z_MErrwfN-_0uT6YIaIHPsokuw_0nLEd0YS0TFmCl8"
    // };

    // let response1 = await admin.messaging().send(message2);

    const snapshot = await admin.firestore().collection('users').get();
    const tokens = [];
    snapshot.forEach(doc => {
        const fcmToken = doc.get('fcmToken');
        tokens.push(fcmToken);
    });
    const message = {
        notification: {
            title: senderDisplayName,
            body: text
        },
        tokens: tokens
    };

    let response = await admin.messaging().sendMulticast(message);
});