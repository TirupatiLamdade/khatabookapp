import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🟢 autoDispose + clear stream handling
final activeShopIdProvider = StreamProvider.autoDispose<String?>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('shops')
      .where('isActive', isEqualTo: true)
      .limit(1)
      .snapshots()
      .map((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Active Shop ID
    }
    return null;
  });
});