// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:hive/hive.dart';
// import 'package:login_setup/core/utils/connection_matcher.dart'; // आपण आधी बनवलेला क्लास
// import 'package:login_setup/core/services/sync_service.dart';

// import 'sync_service.dart' show fromMap;

// class SyncService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   static const String _queueBoxName = 'sync_queue_box';
//   StreamSubscription? _connectivitySubscription;

//   /// 🔄 रिअल-टाइम इंटरनेट आल्यावर ऑटो-सिंक सुरू करणे
//   void initializeSyncListener() {
//     _connectivitySubscription = ConnectionMatcher.connectionStream.listen((result) async {
//       final hasNet = await ConnectionMatcher.isConnected();
//       if (hasNet) {
//         print("🌐 इंटरनेट उपलब्ध आहे! सिंक सुरू होत आहे...");
//         await processSyncQueue();
//       }
//     });
//   }

//   /// 📥 ऑफलाइन डेटा रांगेत जमा करणे
//   Future<void> addToQueue({
//     required String id,
//     required String action,
//     required String collection,
//     required Map<String, dynamic> data,
//   }) async {
//     final box = await Hive.openBox(_queueBoxName);
//     final item = SyncQueueItem(
//       id: id,
//       action: action,
//       collectionPath: collection,
//       data: data,
//       timestamp: DateTime.now(),
//     );

//     await box.put(id, item.toMap());
    
//     // जर नेट चालू असेल तर लगेच सिंक करा, नसेल तर सेव्ह राहू द्या
//     if (await ConnectionMatcher.isConnected()) {
//       await processSyncQueue();
//     }
//   }

//   /// 📤 लोकल रांगेतील (Queue) डेटा फायरबेसवर अपलोड करणे
//   Future<void> processSyncQueue() async {
//     if (!await ConnectionMatcher.isConnected()) return;

//     final box = await Hive.openBox(_queueBoxName);
//     if (box.isEmpty) return;

//     final keys = List.from(box.keys);

//     for (var key in keys) {
//       final mapData = box.get(key);
//       if (mapData == null) continue;

//       final item = SyncQueueItem.fromMap(Map<String, dynamic>.from(mapData));

//       try {
//         final docRef = _firestore.collection(item.collectionPath).doc(item.id);

//         if (item.action == 'CREATE' || item.action == 'UPDATE') {
//           await docRef.set(item.data, SetOptions(merge: true));
//         } else if (item.action == 'DELETE') {
//           await docRef.delete();
//         }

//         // फायरबेसवर यशस्वीरित्या सेव्ह झाल्यावर लोकल रांगेतून काढून टाका
//         await box.delete(key);
//         print("✅ सिंक यशस्वी: ${item.collectionPath} -> ${item.id}");
//       } catch (e) {
//         print("❌ सिंक एरर: $e (पुढच्या वेळी पुन्हा प्रयत्न केला जाईल)");
//         // एरर आल्यास लूप थांबवा, नेट गेल्यावर किंवा नंतर पुन्हा ट्राय होईल
//         break;
//       }
//     }
//   }

//   void dispose() {
//     _connectivitySubscription?.cancel();
//   }
// }

// class fromMap {
// }

// mixin SyncQueueItem {
//   toMap() {}
// }