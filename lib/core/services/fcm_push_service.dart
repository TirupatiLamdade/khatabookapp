// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'notification_service.dart';

// class FcmPushService {
//   // १. सिंगलटन पॅटर्न (Singleton Instance)
//   static final FcmPushService _instance = FcmPushService._internal();
//   factory FcmPushService() => _instance;
//   FcmPushService._internal();

//   final FirebaseMessaging _fcm = FirebaseMessaging.instance;
//   //final NotificationService _localNotificationService = NotificationService();

//   // २. रीयल-टाइम क्लाउड मेसेजिंग बूटस्ट्रॅपिंग (Boot up FCM Listeners)
//   Future<void> initializeCloudMessaging() async {
//     try {
//       // नोटिफिकेशन्स पाठवण्यासाठी युझरची परवानगी घ्या (विशेषतः iOS आणि Android 13+)
//       NotificationSettings settings = await _fcm.requestPermission(
//         alert: true,
//         announcement: false,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );

//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         debugPrint('Firebase Cloud Messaging: Hardware Alert Permissions Granted.');
//       }

//       // ३. युनिक पुश टोकन मिळवा (FCM Device Token for targeting specific users)
//       String? token = await _fcm.getToken();
//       debugPrint("FCM Registration Device Token: $token");
//       // हे टोकन तुम्ही तुमच्या फायरस्टोरच्या युझर डॉक्युमेंटमध्ये जतन करू शकता

//       // 🔄 जेव्हा अॅप फॉरग्राउंड (चालू) असेल, तेव्हा येणारे क्लाउड मेसेजेस पकडा
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         debugPrint('FCM Payload Intercepted in Foreground: ${message.notification?.title}');
        
//         if (message.notification != null) {
//           // स्थानिक नोटिफिकेशन इंजिनद्वारे ते तात्काळ स्क्रीनवर दाखवा
//           _showLocalNotificationFromFcm(message);
//         }
//       });

//       // 📥 जेव्हा अॅप पूर्ण बंद असेल आणि नोटिफिकेशनवर क्लिक करून अॅप उघडेल
//       FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//         debugPrint('App launched directly from closed state via Cloud Messaging action payload.');
//       });

//     } catch (e) {
//       debugPrint("FCM Gateway Integration Skipped on this Hardware platform: $e");
//     }
//   }

//   // ४. एफसीएम मेसेजचे स्थानिक नोटिफिकेशनमध्ये रुपांतर (Bridge FCM to Local Notification)
//   void _showLocalNotificationFromFcm(RemoteMessage message) {
//     // नोटिफिकेशन्स शो करण्यासाठी लोकल सर्व्हिसचा वापर करा
//     final String title = message.notification?.title ?? "Khatabook Smart Update";
//     final String body = message.notification?.body ?? "New transaction activity detected.";

//     // सामान्य नोटिफिकेशन पाठवा
//     //_localNotificationService.showDueReminderNotification(
//      // id: message.hashCode,
//      // customerName: title,
//      // pendingAmount: 0.0, // सानुकूल गरजेनुसार बदला
//     //);
//   }
// }