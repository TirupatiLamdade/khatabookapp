import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/local/sync_queue.dart';

final transactionProvider = StateNotifierProvider<TransactionViewModel, List<TransactionModel>>((ref) {
  return TransactionViewModel();
});

class TransactionViewModel extends StateNotifier<List<TransactionModel>> {
  TransactionViewModel() : super([]) {
    _loadTransactionsFromHive();
  }

  final _txBox = Hive.box(AppConfig.transactionBoxName);
  final _syncQueue = SyncQueueManager();

  void _loadTransactionsFromHive() {
    if (_txBox.isNotEmpty) {
      state = _txBox.values
          .map((item) => TransactionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  // नवीन क्रेडिट/डेबिट व्यवहार पोस्ट करा
  Future<void> postTransaction({
    required String id,
    required String customerId,
    required String shopId,
    required String ownerId,
    required String productName,
    required double credit,
    required double debit,
    int quantity = 1,
    double price = 0.0,
    String? notes,
  }) async {
    // ग्राहकाचे आधीचे व्यवहार शोधून नवीन रर्निंग टोटल मोजा
    final customerTxs = state.where((tx) => tx.customerId == customerId).toList();
    double previousTotal = customerTxs.isEmpty ? 0.0 : customerTxs.last.runningTotal;
    
    // Running Total Formula: Previous + Debit (User has to pay) - Credit (User paid cash)
    double newRunningTotal = previousTotal + debit - credit;

    final newTx = TransactionModel(
      id: id,
      customerId: customerId,
      shopId: shopId,
      ownerId: ownerId,
      productName: productName,
      quantity: quantity,
      price: price,
      credit: credit,
      debit: debit,
      runningTotal: newRunningTotal,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      notes: notes,
    );

    await _txBox.put(id, newTx.toJson());
    state = [...state, newTx];

    // सिंक क्युरेटर
    await _syncQueue.addToQueue(
      collectionPath: 'shops/$shopId/customers/$customerId/ledgers',
      documentId: id,
      operationType: 'SET',
      payload: newTx.toJson(),
    );
  }
}