// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   // १. सिंगलटन पॅटर्न इन्स्टन्स (Singleton Class Instance)
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

//   // २. चॅनेल आणि युटिलिटी इनिशियलायझेशन (Initialize Notification Engine)
//   Future<void> initNotificationChannel() async {
//     // अँड्रॉइडसाठी डीफॉल्ट लाँचर आयकॉन सेटअप
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

//     // आयओएस (iOS) साठी परमिशन सेटअप
//     const DarwinInitializationSettings iOSSettings = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: iOSSettings,
//     );

//     // 🛡️ v22+ चॅनेल क्रिएशन नियमांनुसार:
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'khatabook_ledger_reminders', // Channel ID (Positional allowed in channel config object)
//       'Ledger Due Reminders',       // Channel Name
//       description: 'Triggers alerts for outstanding balances and due credits.',
//       importance: Importance.max,
//       playSound: true,
//       enableVibration: true,
//     );

//     // प्लगइन इनिशियलाइज करा
//     await _localNotifications.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         debugPrint("Notification Intercepted: Payload content -> ${response.payload}");
//       },
//     );

//     // अँड्रॉइड प्लॅटफॉर्म स्पेसिफिक चॅनेल क्रिएट रेझोल्यूशन
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   // ३. उधारी भरण्याच्या स्मरणपत्रासाठी डायनेमिक अलर्ट (Show Secure Ledger Alert)
//   Future<void> showDueReminderNotification({
//     required int id,
//     required String customerName,
//     required double pendingAmount,
//   }) async {
    
//     // 🛠️ ULTIMATE FIX FOR v22+: 
//     // नवीन आवृत्तीत फक्त 'channelId' हा एकच named parameter लागतो! 
//     // इतर कोणतेही जादा positional किंवा named 'id'/'name' पॅरामीटर्स द्यायचे नाहीत.
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       channelId: 'khatabook_ledger_reminders', // 👈 Only required named parameter for AndroidDetails
//       channelDescription: 'Triggers alerts for outstanding balances and due credits.',
//       importance: Importance.max,
//       priority: Priority.high,
//       playSound: true,
//       enableVibration: true,
//     );

//     const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     const NotificationDetails platformDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iOSDetails,
//     );

//     await _localNotifications.show(
//       id,
//       'Payment Pending Alert! 📢',
//       'Mr./Ms. $customerName has an outstanding due of ₹$pendingAmount. Send friendly reminder WhatsApp/SMS.',
//       platformDetails,
//       payload: 'due_reminder_cust_$id',
//     );
//   }
// }