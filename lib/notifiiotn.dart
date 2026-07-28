// import 'package:flutter/foundation.dart'; // kIsWeb वापरण्यासाठी
// import 'package:firebase_messaging/firebase_messaging.dart';

// class NotificationService {
//   final FirebaseMessaging _messaging = FirebaseMessaging.instance;

//   Future<void> initNotifications() async {
//     // १. युझरकडून नोटिफिकेशन दाखवण्याची परवानगी मागा
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('नोटीफिकेशन परमिशन मिळाली!');

//       String? token;
      
//       // २. प्लॅटफॉर्म नुसार टोकन मिळवा
//       if (kIsWeb) {
//         // तुमची खरी Web VAPID Key:
//         token = await _messaging.getToken(
//           vapidKey: "BIKFaiUmX67QR6fnd_rj539XVUsF8exoevgREhWRkf2o6cIF6dtnDjX1NVUikuEfhAJCPL1HSLeSabCSDFuah2s",
//         ); // 🟢 इथे कंस पूर्ण केला आहे
//       } else {
//         // Android साठी साधं टोकन चालेल
//         token = await _messaging.getToken();
//       }

//       print("तुमचा FCM TOKEN: $token");
//       // हा टोकन कॉपी करून तुम्ही टेस्ट मेसेज पाठवण्यासाठी वापरू शकता.

//       // ३. ॲप स्क्रीनवर चालू असताना (Foreground) मेसेज आला तर:
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         if (message.notification != null) {
//           print('Title: ${message.notification!.title}');
//           print('Body: ${message.notification!.body}');
//         }
//       });
//     } else {
//       print('युझरने परमिशन नाकारली.');
//     }
//   }
// }