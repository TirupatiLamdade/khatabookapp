import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:login_setup/core/providers/global_provider_hub.dart';


class ShopProfileManagementScreen extends ConsumerWidget {
  const ShopProfileManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🟢 सक्रीय दुकानाचा ID वाचणे
    final activeShopAsync = ref.watch(activeShopIdProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          "Shop Profile Management",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: activeShopAsync.when(
        data: (activeShopId) {
          if (activeShopId == null || activeShopId.isEmpty) {
            return const Center(
              child: Text("No Active Shop Selected", style: TextStyle(color: Colors.white)),
            );
          }

          // 🗝️ KEY: activeShopId बदलताच नवीन Form Widget तयार होईल आणि जुना डाटा पूर्ण नष्ट होईल
          return _ShopProfileForm(key: ValueKey(activeShopId), shopId: activeShopId);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
        error: (err, stack) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _ShopProfileForm extends ConsumerStatefulWidget {
  final String shopId;
  const _ShopProfileForm({Key? key, required this.shopId}) : super(key: key);

  @override
  ConsumerState<_ShopProfileForm> createState() => _ShopProfileFormState();
}

class _ShopProfileFormState extends ConsumerState<_ShopProfileForm> {
  // Lock Fields (User Level)
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Editable Fields (Shop Level)
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _gstinController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopDetails();
  }

  // 📡 थेट डेटाबेस मधून फक्त सध्याच्या shopId चाच फ्रेश डेटा आणणे
  Future<void> _fetchShopDetails() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('shops') // जर तुमचे सब-कलेक्शन असेल तर त्यानुसार path ठेवा
          .doc(widget.shopId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _usernameController.text = data['username'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _emailController.text = data['email'] ?? '';
          
          _shopNameController.text = data['shopName'] ?? '';
          _ownerNameController.text = data['ownerName'] ?? '';
          _categoryController.text = data['category'] ?? '';
          _gstinController.text = data['gstin'] ?? '';
          _upiController.text = data['upiId'] ?? '';
          _addressController.text = data['address'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _categoryController.dispose();
    _gstinController.dispose();
    _upiController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOCKED FIELDS
          _buildLockedField("USERNAME (LOCKED)", _usernameController, Icons.person),
          const SizedBox(height: 12),
          _buildLockedField("MOBILE NUMBER (LOCKED)", _phoneController, Icons.phone_android),
          const SizedBox(height: 12),
          _buildLockedField("EMAIL ADDRESS (LOCKED)", _emailController, Icons.email),
          
          const SizedBox(height: 24),
          const Text(
            "EDITABLE SHOP INFORMATION",
            style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),

          // EDITABLE FIELDS
          _buildEditableField("Shop / Business Name *", _shopNameController, Icons.store),
          const SizedBox(height: 12),
          _buildEditableField("Owner Legal Name *", _ownerNameController, Icons.person_outline),
          const SizedBox(height: 12),
          _buildEditableField("Business Category *", _categoryController, Icons.category),
          const SizedBox(height: 12),
          _buildEditableField("Corporate GSTIN Number", _gstinController, Icons.receipt_long),
          const SizedBox(height: 12),
          _buildEditableField("Business UPI Payment ID", _upiController, Icons.qr_code),
          const SizedBox(height: 12),
          _buildEditableField("Physical Shop Address *", _addressController, Icons.location_on),
        ],
      ),
    );
  }

  Widget _buildLockedField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.redAccent),
        suffixIcon: const Icon(Icons.lock, color: Colors.redAccent, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        suffixIcon: const Icon(Icons.edit, color: Colors.blueAccent, size: 18),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}