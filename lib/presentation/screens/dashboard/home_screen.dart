import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_setup/presentation/screens/shop/shop_setup_screen.dart' show ShopManageScreen;
import '../../../core/providers/global_provider_hub.dart';
import '../customer/customer_list_screen.dart';

import '../../widgets/responsive_drawer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  // 💡 फिक्स: आता क्लीन कन्स्ट्रक्टर कॉल झाल्यामुळे इथे कोणतीही पॅरामीटर एरर येणार नाही
  final List<Widget> _screens = [
    const CustomerListScreen(),  
    const ShopManageScreen(prefilledEmail: '', prefilledPhone: '',),    
    const Center(child: Text('⚙️ सेटिंग्स स्क्रीन', style: TextStyle(fontSize: 18))),
  ];

  @override
  Widget build(BuildContext context) {
    final activeShopId = ref.watch(activeShopIdProvider) ?? "Default Shop";
    final size = MediaQuery.of(context).size;
    final isLargeScreen = size.width > 900;

    return Scaffold(
      appBar: isLargeScreen 
          ? null 
          : AppBar(
              title: Text('दुकान: $activeShopId', style: const TextStyle(fontSize: 16)),
              backgroundColor: Colors.deepPurple.shade700,
              foregroundColor: Colors.white,
            ),
      body: Row(
        children: [
          if (isLargeScreen)
            ResponsiveDrawer(
              selectedIndex: _selectedIndex,
              activeShopId: activeShopId,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
            ),
          Expanded(
            child: Container(
              color: Colors.grey.shade50,
              child: _screens[_selectedIndex],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isLargeScreen
          ? null
          : BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              selectedItemColor: Colors.deepPurple.shade700,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'लेजर बुक'),
                BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'दुकानदार'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'सेटिंग्ज'),
              ],
            ),
    );
  }
}