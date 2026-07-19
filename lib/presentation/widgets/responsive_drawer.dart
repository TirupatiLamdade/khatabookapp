import 'package:flutter/material.dart';

class ResponsiveDrawer extends StatelessWidget {
  final int selectedIndex;
  final String activeShopId;
  final ValueChanged<int> onDestinationSelected;

  const ResponsiveDrawer({
    Key? key,
    required this.selectedIndex,
    required this.activeShopId,
    required this.onDestinationSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: double.infinity,
      color: Colors.deepPurple.shade900,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🏪 वरच्या बाजूला ब्रँडिंग आणि ॲक्टिव्ह शॉप आयडीचा लुक
          Row(
            children: [
              const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khatabook Smart',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      activeShopId,
                      style: TextStyle(color: Colors.purple.shade200, fontSize: 11, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(color: Colors.white24),
          ),
          
          // 🎯 मेनू आयटम्सची यादी
          _buildDrawerItem(
            icon: Icons.menu_book,
            label: 'ग्राहक खाते वही (Ledger)',
            index: 0,
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.storefront,
            label: 'माझी दुकाने (Shops)',
            index: 1,
          ),
          const SizedBox(height: 8),
          _buildDrawerItem(
            icon: Icons.settings,
            label: 'ॲप सेटिंग्ज',
            index: 2,
          ),
          
          const Spacer(),
          // 🚪 तळाशी सुरक्षिततेची ग्वाही
          Text(
            '🔒 End-to-End Encrypted',
            style: TextStyle(color: Colors.purple.shade200, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String label, required int index}) {
    final isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => onDestinationSelected(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.purple.shade200, size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.purple.shade100,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}