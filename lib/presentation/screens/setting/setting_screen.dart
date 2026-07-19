import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/global_provider_hub.dart';
import 'developer_settings_view.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeShopId = ref.watch(activeShopIdProvider) ?? "निवडलेले नाही";
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            // 🖥️ डेस्कटॉपवर लुक प्रोफेशनल ठेवण्यासाठी विड्थ पॅक केली आहे
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 700 : double.infinity,
            ),
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                const Text(
                  'ॲप सेटिंग्ज (Settings)',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 🏪 सध्याचे दुकान कार्ड
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepPurple.shade50,
                      child: Icon(Icons.storefront, color: Colors.deepPurple.shade800),
                    ),
                    title: const Text('सक्रिय दुकान आयडी', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    subtitle: Text(activeShopId, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                    trailing: TextButton(
                      onPressed: () {
                        // मुख्य डॅशबोर्डवरील शॉप इंडेक्स (१) वर न्यावे
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('दुकान बदलण्यासाठी मुख्य मेनूमधील "माझी दुकाने" वर जा.')),
                        );
                      },
                      child: const Text('बदला'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 🛠️ जनरल सेटिंग्स ग्रुप
                const Text('सामान्य पर्याय', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Divider(),
                
                ListTile(
                  leading: const Icon(Icons.notifications_none),
                  title: const Text('पुश नोटिफिकेशन (FCM)'),
                  subtitle: const Text('व्यवहारांचे मेसेज आणि अलर्ट कॉन्फिगर करा'),
                  trailing: Switch(value: true, onChanged: (val) {}),
                ),
                
                ListTile(
                  leading: const Icon(Icons.language),
                  title: const Text('ॲपची भाषा (Language)'),
                  subtitle: const Text('मराठी / English / हिंदी'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {},
                ),

                const SizedBox(height: 24),

                // 👨‍💻 डेव्हलपर पर्याय ग्रुप
                const Text('प्रगत पर्याय (Advanced)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.developer_mode, color: Colors.blue),
                  title: const Text('डेव्हलपर सेटिंग्स (Developer Options)'),
                  subtitle: const Text('लोकल डेटाबेस कॅश आणि लॉग्स तपासण्यासाठी'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    // डेव्हलपर व्ह्यू स्क्रीन उघडा
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DeveloperSettingsView()),
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 🚪 लॉगआउट बटन
                ElevatedButton.icon(
                  onPressed: () {
                    // ग्लोबल शॉप आयडी साफ करा आणि लॉगिन स्क्रीनवर परत जा
                    ref.read(activeShopIdProvider.notifier).state = null;
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('ॲपमधून लॉगआउट करा', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}