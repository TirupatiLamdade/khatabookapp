import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:login_setup/presentation/screens/setting/setting_screen.dart';
import '../customer/customer_list_screen.dart';
//import '../settings/settings_screen.dart';
import '../shop/shop_manage_screen.dart';
import '../../widgets/responsive_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentNavigationIndex = 0;

  // बॉटम नेविगेशन बार के माध्यम से रेंडर होने वाली सभी कोर स्क्रीन की सूची
  final List<Widget> _appSubScreens = [
    const MainDashboardView(), // इंडेक्स 0: एनालिटिक्स होम व्यू
    const CustomerListScreen(shopId: 'default_shop_001', currentUserId: 'active_auth_uid'), // इंडेक्स 1: खाता बही लिस्ट व्यू
    const ShopManageScreen(currentUserId: 'active_auth_uid'), // इंडेक्स 2: शॉप मैनेजमेंट व्यू
    const SettingsScreen(), // इंडेक्स 3: ऐप सेटिंग्स व्यू
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Khatabook Smart Engine'),
      ),
      drawer: const ResponsiveDrawer(currentShopName: 'Active Premium Store'),
      
      // बॉटम नेविगेशन इंडेक्स के अनुसार चुनी गई स्क्रीन लोड होगी
      body: IndexedStack(
        index: _currentNavigationIndex,
        children: _appSubScreens,
      ),

      // 📱 BOTTOM NAVIGATION SYSTEM: स्क्रीन बदलने के लिए नीचे लगा नेविगेशन बार
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentNavigationIndex,
        onDestinationSelected: (int newIdx) {
          setState(() => _currentNavigationIndex = newIdx);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Ledger'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Shops'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// होम इंडेक्स के अंदर मुख्य समरी एनालिटिक्स कार्ड्स दिखाने वाला विजेट
class MainDashboardView extends StatelessWidget {
  const MainDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome Back, Business Owner!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            color: Colors.green.shade50,
            child: const ListTile(
              leading: Icon(Icons.arrow_downward, color: Colors.green),
              title: Text('Total Cash In (Credit)', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ),
          Card(
            color: Colors.red.shade50,
            child: const ListTile(
              leading: Icon(Icons.arrow_upward, color: Colors.red),
              title: Text('Total Cash Out (Debit)', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: Text('₹0.00', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }
}