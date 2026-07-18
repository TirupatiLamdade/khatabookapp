import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/local/sync_queue.dart';

final customerProvider = StateNotifierProvider<CustomerViewModel, List<CustomerModel>>((ref) {
  return CustomerViewModel();
});

class CustomerViewModel extends StateNotifier<List<CustomerModel>> {
  CustomerViewModel() : super([]) {
    _loadCustomersFromHive();
  }

  final _customerBox = Hive.box(AppConfig.customerBoxName);
  final _syncQueue = SyncQueueManager();

  // १. स्थानिक हाइव्हमधून सर्व ग्राहक लोड करा
  void _loadCustomersFromHive() {
    if (_customerBox.isNotEmpty) {
      state = _customerBox.values
          .map((item) => CustomerModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  // २. नवीन ग्राहक जोडा (ऑफलाइन हाइव्ह + सिंक रांग)
  Future<void> addCustomer({
    required String id,
    required String shopId,
    required String ownerId,
    required String name,
    required String phone,
    String? email,
    String? address,
    double creditLimit = 50000.0,
  }) async {
    final newCustomer = CustomerModel(
      id: id,
      shopId: shopId,
      ownerId: ownerId,
      name: name,
      phone: phone,
      email: email,
      address: address,
      creditLimit: creditLimit,
    );

    // स्थानिक स्तरावर तात्काळ जतन करा (UI Instant updates)
    await _customerBox.put(id, newCustomer.toJson());
    state = [...state, newCustomer];

    // पार्श्वभूमीत (Background) क्लाउड सिंकिंगसाठी रांगेत जोडा
    await _syncQueue.addToQueue(
      collectionPath: 'shops/$shopId/customers',
      documentId: id,
      operationType: 'SET',
      payload: newCustomer.toJson(),
    );
  }

  // ३. ग्राहकाची माहिती ब्लॉक/अनब्लॉक किंवा फेव्हरेट सेट करणे
  Future<void> toggleFavouriteState(String id) async {
    state = [
      for (final cust in state)
        if (cust.id == id)
          CustomerModel(
            id: cust.id,
            shopId: cust.shopId,
            ownerId: cust.ownerId,
            name: cust.name,
            phone: cust.phone,
            email: cust.email,
            address: cust.address,
            creditLimit: cust.creditLimit,
            isFavourite: !cust.isFavourite,
            isBlocked: cust.isBlocked,
          )
        else
          cust
    ];

    final updated = state.firstWhere((c) => c.id == id);
    await _customerBox.put(id, updated.toJson());
    
    await _syncQueue.addToQueue(
      collectionPath: 'shops/${updated.shopId}/customers',
      documentId: id,
      operationType: 'SET',
      payload: updated.toJson(),
    );
  }
}