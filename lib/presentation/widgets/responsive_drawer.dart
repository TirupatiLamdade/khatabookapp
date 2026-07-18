import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResponsiveDrawer extends StatelessWidget {
  final String currentShopName;

  const ResponsiveDrawer({
    super.key,
    required this.currentShopName,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Drawer(
      // डेस्कटॉपवर असल्यास ड्रॉवरची कडा लपवा किंवा एलिव्हेशन कमी करा
      elevation: isDesktop ? 0 : 16,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            // Header
            UserAccountsDrawerHeader(
              accountName: Text(
                currentShopName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              accountEmail: const Text('Role: Business Owner'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.storefront_outlined, color: Colors.deepPurple, size: 36),
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.analytics_outlined, color: Colors.deepPurple),
                    title: const Text('Dashboard Summary', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      if (!isDesktop) Navigator.pop(context);
                      context.go('/home');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.people_outline, color: Colors.deepPurple),
                    title: const Text('Customer Ledgers', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      if (!isDesktop) Navigator.pop(context);
                      context.go('/customers/default_shop_001');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.business_center_outlined, color: Colors.deepPurple),
                    title: const Text('My Shops', style: TextStyle(fontWeight: FontWeight.w500)),
                    onTap: () {
                      if (!isDesktop) Navigator.pop(context);
                      context.go('/shops');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('App Settings'),
                    onTap: () {
                      if (!isDesktop) Navigator.pop(context);
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Secure Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () {
                if (!isDesktop) Navigator.pop(context);
                context.go('/login');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}