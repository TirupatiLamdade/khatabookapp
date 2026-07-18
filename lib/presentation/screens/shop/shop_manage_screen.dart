import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/shop_viewmodel.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../../widgets/glass_card.dart';

class ShopManageScreen extends ConsumerStatefulWidget {
  final String currentUserId;

  const ShopManageScreen({
    super.key,
    required this.currentUserId,
  });

  @override
  ConsumerState<ShopManageScreen> createState() => _ShopManageScreenState();
}

class _ShopManageScreenState extends ConsumerState<ShopManageScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedBusinessType = 'Grocery';

  final List<String> _businessTypes = ['Grocery', 'Medical', 'Clothing', 'Electronics', 'Others'];

  void _createNewShopProfile() {
    if (_nameController.text.isEmpty) return;

    final String newShopId = 'shop_${DateTime.now().millisecondsSinceEpoch}';

    ref.read(shopProvider.notifier).createNewShop(
          id: newShopId,
          ownerId: widget.currentUserId,
          name: _nameController.text.trim(),
          businessType: _selectedBusinessType,
          address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        );

    // तयार झाल्यावर इनपुट बॉक्स रिकामे करा
    _nameController.clear();
    _addressController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('New business shop registered successfully!'), backgroundColor: Colors.green),
    );
  }

  void _showCreateShopDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Business Store'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Business / Shop Name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBusinessType,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _businessTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBusinessType = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Physical Address', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: _createNewShopProfile, child: const Text('Register')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shops = ref.watch(shopProvider);
    final activeShopId = ref.watch(activeShopIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Switch Business Workspace'),
      ),
      body: shops.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No shops registered yet. Build your first shop workspace!', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _showCreateShopDialog, child: const Text('Create Shop')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                final isCurrentActive = shop.id == activeShopId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentActive ? Colors.green.shade100 : Colors.deepPurple.shade50,
                        child: Icon(
                          Icons.storefront_outlined,
                          color: isCurrentActive ? Colors.green : Colors.deepPurple,
                        ),
                      ),
                      title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Category: ${shop.businessType}'),
                      trailing: isCurrentActive
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        // सध्याचे सक्रिय शॉप आयसोलेशन बदला
                        ref.read(activeShopIdProvider.notifier).state = shop.id;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Switched workspace context to: ${shop.name}')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateShopDialog,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}