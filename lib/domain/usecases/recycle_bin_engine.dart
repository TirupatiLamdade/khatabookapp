import 'package:hive/hive.dart';
import '../../core/config/app_config.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/transaction_model.dart';

class RecycleBinEngine {
  final _recycleBox = Hive.box(AppConfig.recycleBinBoxName);
  final _customerBox = Hive.box(AppConfig.customerBoxName);
  final _transactionBox = Hive.box(AppConfig.transactionBoxName);

  // १. ग्राहकाला मऊ-डिलिट (Soft-Delete) करून कचरापेटीत पाठवणे
  Future<void> softDeleteCustomer(CustomerModel customer) async {
    final binId = 'bin_cust_${customer.id}';
    final binItem = {
      'binId': binId,
      'type': 'CUSTOMER',
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
      'data': customer.toJson(),
    };
    await _recycleBox.put(binId, binItem);
    await _customerBox.delete(customer.id);
  }

  // २. लेजर ट्रान्झॅक्शन मऊ-डिलिट करणे
  Future<void> softDeleteTransaction(TransactionModel tx) async {
    final binId = 'bin_tx_${tx.id}';
    final binItem = {
      'binId': binId,
      'type': 'TRANSACTION',
      'deletedAt': DateTime.now().millisecondsSinceEpoch,
      'data': tx.toJson(),
    };
    await _recycleBox.put(binId, binItem);
    await _transactionBox.delete(tx.id);
  }

  // ३. कचरापेटीमधून मूळ डेटा रिस्टोर (पुनर्संचयित) करणे
  Future<void> restoreItem(String binId) async {
    final item = _recycleBox.get(binId);
    if (item == null) return;

    final Map<String, dynamic> mappedItem = Map<String, dynamic>.from(item);
    final String type = mappedItem['type'] as String;
    final Map<String, dynamic> rawData = Map<String, dynamic>.from(mappedItem['data']);

    if (type == 'CUSTOMER') {
      final customer = CustomerModel.fromJson(rawData);
      await _customerBox.put(customer.id, customer.toJson());
    } else if (type == 'TRANSACTION') {
      final tx = TransactionModel.fromJson(rawData);
      await _transactionBox.put(tx.id, tx.toJson());
    }

    await _recycleBox.delete(binId);
  }

  // ४. ३० दिवसांपेक्षा जुना डेटा स्वयंचलित साफ करणे (Auto Clean-up)
  Future<void> purgeExpiredItems() async {
    if (_recycleBox.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final thirtyDaysInMs = 30 * 24 * 60 * 60 * 1000;
    final keys = List<String>.from(_recycleBox.keys);

    for (var key in keys) {
      final item = Map<String, dynamic>.from(_recycleBox.get(key));
      final int deletedAt = item['deletedAt'] ?? 0;

      if ((now - deletedAt) > thirtyDaysInMs) {
        await _recycleBox.delete(key); // कायमचे नष्ट करा
      }
    }
  }
}