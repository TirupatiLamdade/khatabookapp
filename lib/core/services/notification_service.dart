import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔔 सर्व स्क्रीनवरून नोटिफिकेशन सेव्ह करण्यासाठी ग्लोबल फंक्शन
  static Future<void> sendNotification({
    required String title,
    required String body,
    required String type, // 'add', 'edit', 'delete', 'transaction', 'shop'
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore.collection('notifications').add({
        'operatorUid': user.uid,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Notification Error: $e");
    }
  }
}