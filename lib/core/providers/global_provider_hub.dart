import 'package:flutter_riverpod/flutter_riverpod.dart';

// सध्या लॉगिन असलेल्या दुकानदाराचा युनिक शॉप आयडी साठवण्यासाठी
// हा आयडी बदलला की पूर्ण ॲपचा डेटा ऑटोमॅटिकली त्या दुकानाचा लोड होईल
final activeShopIdProvider = StateProvider<String?>((ref) => null);

// युझर लॉगिन आहे की नाही हे तपासण्यासाठी
final isAuthenticatedProvider = Provider<bool>((ref) {
  final shopId = ref.watch(activeShopIdProvider);
  return shopId != null;
});