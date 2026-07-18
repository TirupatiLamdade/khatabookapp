import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../presentation/viewmodels/customer_viewmodel.dart';
import '../../presentation/viewmodels/transaction_viewmodel.dart';
import '../../data/models/customer_model.dart';

// डिफ़ॉल्ट रूप से पहली शॉप आईडी सेट करें
final activeShopIdProvider = StateProvider<String>((ref) => 'default_shop_001');

// सिलेक्टेड शॉप के आधार पर फ़िल्टर किए गए ग्राहकों की सूची
final filteredCustomerProvider = Provider<List<CustomerModel>>((ref) {
  final activeShopId = ref.watch(activeShopIdProvider);
  final allCustomers = ref.watch(customerProvider);
  
  return allCustomers.where((customer) => customer.shopId == activeShopId).toList();
});