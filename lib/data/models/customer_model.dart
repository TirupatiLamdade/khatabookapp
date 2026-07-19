import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String shopId;
  final double balance; // 👈 UI आणि उधारीच्या कॅल्क्युलेशनसाठी
  final bool isFavorite; // 👈 फिल्टरसाठी
  final bool isBlocked; // 👈 फिल्टरसाठी

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.shopId,
    required this.balance,
    required this.isFavorite,
    required this.isBlocked,
  });

  factory CustomerModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CustomerModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      shopId: data['shopId'] ?? '',
      // जुन्या डेटाबेसमध्ये 'dueAmount' असेल तर तो 'balance' म्हणून मॅप होईल
      balance: (data['balance'] ?? data['dueAmount'] ?? 0).toDouble(),
      isFavorite: data['isFavorite'] ?? false,
      isBlocked: data['isBlocked'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'shopId': shopId,
      'balance': balance,
      'isFavorite': isFavorite,
      'isBlocked': isBlocked,
    };
  }
}