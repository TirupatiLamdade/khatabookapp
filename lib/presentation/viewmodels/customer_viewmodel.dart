import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../../../data/models/customer_model.dart';
import '../../../data/repositories/firestore_repository.dart';

// 🔄 activeShopId बदलताच हा प्रोव्हाइडर ऑटोमॅटिक री-रन होतो
final customersStreamProvider = StreamProvider<List<CustomerModel>>((ref) {
  final shopId = ref.watch(activeShopIdProvider);

  if (shopId == null) {
    return Stream.value([]);
  }

  // 💡 फिक्स: रिपॉझिटरी फाईलमधून प्रोव्हाइडर रीद करा
  final firestoreRepository = ref.read(FirestoreRepository() as ProviderListenable<dynamic>);
  return firestoreRepository.getCustomersByShop(shopId);
});