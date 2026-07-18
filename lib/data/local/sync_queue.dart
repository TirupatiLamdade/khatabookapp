import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/app_config.dart';

class SyncQueueManager {
  final _queueBox = Hive.box(AppConfig.syncQueueBoxName);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // रांगेत नवीन ऑपरेशन जोडा (CREATE, UPDATE, DELETE)
  Future<void> addToQueue({
    required String collectionPath, // "shops/shop_123/customers"
    required String documentId,
    required String operationType,  // "SET", "UPDATE", "DELETE"
    required Map<String, dynamic> payload,
  }) async {
    final queueItem = {
      'id': 'sync_${DateTime.now().microsecondsSinceEpoch}',
      'collectionPath': collectionPath,
      'documentId': documentId,
      'operationType': operationType,
      'payload': payload,
      'retryCount': 0,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await _queueBox.put(queueItem['id'], queueItem);
  }

  // इंटरनेट आल्यावर प्रलंबित कतार क्लाउडवर ढकलून मोकळी करा
  Future<void> triggerProcessSync() async {
    if (_queueBox.isEmpty) return;

    final keys = List<String>.from(_queueBox.keys);
    for (var key in keys) {
      final item = Map<String, dynamic>.from(_queueBox.get(key));
      final int retry = item['retryCount'] ?? 0;

      if (retry >= AppConfig.maxSyncRetries) {
        // जास्त वेळा प्रयत्न अयशस्वी झाल्यास वगळा (Conflict resolution साठी)
        continue;
      }

      try {
        final docRef = _firestore.collection(item['collectionPath']).doc(item['documentId']);
        
        if (item['operationType'] == 'SET') {
          await docRef.set(Map<String, dynamic>.from(item['payload']));
        } else if (item['operationType'] == 'UPDATE') {
          await docRef.update(Map<String, dynamic>.from(item['payload']));
        } else if (item['operationType'] == 'DELETE') {
          await docRef.delete();
        }

        // सिंक यशस्वी झाल्यास स्थानिक कतारमधून काढा
        await _queueBox.delete(key);
      } catch (e) {
        // त्रुटी आल्यास रिट्राय काऊंट वाढवा
        item['retryCount'] = retry + 1;
        await _queueBox.put(key, item);
      }
    }
  }
}