import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hive/hive.dart';
import '../../../core/config/app_config.dart';
import '../../../data/models/shop_model.dart';

final shopProvider = StateNotifierProvider<ShopViewModel, List<ShopModel>>((ref) {
  return ShopViewModel();
});

class ShopViewModel extends StateNotifier<List<ShopModel>> {
  ShopViewModel() : super([]) {
    _loadShopsFromHive();
  }

  final _settingsBox = Hive.box(AppConfig.settingsBoxName);

  // १. स्थानिक हाइव्हमधून सर्व शॉप्स लोड करा
  void _loadShopsFromHive() {
    final rawShops = _settingsBox.get('registered_shops_list', defaultValue: []);
    if (rawShops is List) {
      state = rawShops
          .map((item) => ShopModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  // २. नवीन बिझनेस/शॉप तयार करा
  Future<void> createNewShop({
    required String id,
    required String ownerId,
    required String name,
    required String businessType,
    String? gstNumber,
    String? address,
  }) async {
    final newShop = ShopModel(
      id: id,
      ownerId: ownerId,
      name: name,
      businessType: businessType,
      gstNumber: gstNumber,
      address: address,
      collaborators: {ownerId: 'Owner'},
    );

    state = [...state, newShop];
    await _saveShopsToHive();
  }

  // ३. शॉपचे तपशील अपडेट करा
  Future<void> updateShopDetails(ShopModel updatedShop) async {
    state = [
      for (final shop in state)
        if (shop.id == updatedShop.id) updatedShop else shop
    ];
    await _saveShopsToHive();
  }

  // ४. हाइव्हमध्ये शॉप लिस्ट सेव्ह करा
  Future<void> _saveShopsToHive() async {
    final rawList = state.map((shop) => shop.toJson()).toList();
    await _settingsBox.put('registered_shops_list', rawList);
  }
}