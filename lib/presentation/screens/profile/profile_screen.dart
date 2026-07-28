

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _shopNameController;
  late TextEditingController _ownerNameController;
  late TextEditingController _categoryController;
  late TextEditingController _gstinController;
  late TextEditingController _addressController;
  late TextEditingController _upiController;

  bool _isLoading = true;
  bool _isSaving = false;

  // ✏️ Inline Edit State
  final Map<String, bool> _enabledFields = {
    'shopName': false,
    'ownerName': false,
    'category': false,
    'gstin': false,
    'upi': false,
    'address': false,
  };

  final List<String> _businessCategories = [
    'Retail Shop / Kirana',
    'Wholesale / Distributor',
    'Electronics & Mobile Hardware',
    'Textile / Apparels Logistics',
    'Medical / Pharmaceuticals',
    'Restaurateur / Food Services',
    'Manufacturing Enterprise',
    'Freelance / Professional Services',
  ];

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _shopNameController = TextEditingController();
    _ownerNameController = TextEditingController();
    _categoryController = TextEditingController();
    _gstinController = TextEditingController();
    _addressController = TextEditingController();
    _upiController = TextEditingController();

    _loadShopProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _categoryController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _loadShopProfileData() async {
    if (currentUser == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _usernameController.text = data['username'] ?? 'User Operator';
          _emailController.text = data['email'] ?? currentUser?.email ?? 'Not Linked';
          _phoneController.text = data['phone'] ?? currentUser?.phoneNumber ?? 'Not Linked';
          _shopNameController.text = data['shopName'] ?? '';
          _ownerNameController.text = data['ownerName'] ?? data['fullName'] ?? '';
          _categoryController.text = data['businessCategory'] ?? '';
          _gstinController.text = data['gstin'] ?? '';
          _addressController.text = data['shopAddress'] ?? '';
          _upiController.text = data['upiId'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Error loading profile: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateShopProfile() async {
    if (!_formKey.currentState!.validate() || currentUser == null) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));

    try {
      await FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).set({
        'shopName': _shopNameController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'fullName': _ownerNameController.text.trim(),
        'businessCategory': _categoryController.text.trim(),
        'gstin': _gstinController.text.trim().toUpperCase(),
        'shopAddress': _addressController.text.trim(),
        'upiId': _upiController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        _showTopNotification('Updated your profile as requested.');
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification('Failed to update: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPadding + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isError 
                    ? [const Color(0xFF991B1B), const Color(0xFFDC2626)] 
                    : [const Color(0xFF065F46), const Color(0xFF10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isError ? const Color(0xFFFCA5A5) : const Color(0xFF6EE7B7),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isError ? Colors.red : Colors.green).withOpacity(0.35),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isError ? 'Action Required' : 'Success',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Colors (Synced with Global App Theme Mode)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final Color lockedBgColor = isDark ? const Color(0xFF0F172A).withOpacity(0.6) : const Color(0xFFF1F5F9);
    final Color editableBgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color borderColor = isDark ? Colors.white12 : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Shop Profile Management',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
          : LayoutBuilder(
              builder: (context, constraints) {
                final double screenWidth = constraints.maxWidth;
                final bool isDesktop = screenWidth > 1024;
                final bool isTablet = screenWidth > 640 && screenWidth <= 1024;
                final double layoutWidth = isDesktop ? 780.0 : (isTablet ? screenWidth * 0.90 : screenWidth);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  // 🟢 Padding includes 140px bottom padding for floating navigation bars/widgets
                  padding: EdgeInsets.only(
                    left: isDesktop ? 32 : (isTablet ? 24 : 16),
                    right: isDesktop ? 32 : (isTablet ? 24 : 16),
                    top: 24,
                    bottom: 140,
                  ),
                  child: Center(
                    child: Container(
                      width: layoutWidth,
                      padding: EdgeInsets.all(isDesktop ? 32 : (isTablet ? 24 : 16)),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 👤 PROFILE HEADER
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF38BDF8).withOpacity(0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                                    ),
                                    child: const Icon(Icons.storefront_rounded, size: 44, color: Color(0xFF38BDF8)),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _ownerNameController.text.isNotEmpty ? _ownerNameController.text : 'Owner Legal Name',
                                    style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w900),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _phoneController.text.isNotEmpty ? '+91 ${_phoneController.text}' : 'No Mobile Channel Linked',
                                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 14, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // 🔒 STRICTLY LOCKED FIELDS
                            const Text(
                              'PROTECTED OPERATOR CREDENTIALS (LOCKED)',
                              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                            ),
                            const SizedBox(height: 14),

                            _buildLockedField(
                              label: 'USERNAME',
                              controller: _usernameController,
                              icon: Icons.person_pin_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              lockedBgColor: lockedBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 14),
                            _buildLockedField(
                              label: 'MOBILE NUMBER',
                              controller: _phoneController,
                              icon: Icons.phone_android_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              lockedBgColor: lockedBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 14),
                            _buildLockedField(
                              label: 'EMAIL ADDRESS',
                              controller: _emailController,
                              icon: Icons.mail_outline_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              lockedBgColor: lockedBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 28),

                            // ✏️ EDITABLE FIELDS
                            const Text(
                              'EDITABLE SHOP INFORMATION',
                              style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1),
                            ),
                            const SizedBox(height: 14),

                            // 1. Shop Name
                            _buildInlineEditableField(
                              keyKey: 'shopName',
                              controller: _shopNameController,
                              label: 'Shop / Business Name *',
                              icon: Icons.storefront_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),

                            // 2. Owner Legal Name
                            _buildInlineEditableField(
                              keyKey: 'ownerName',
                              controller: _ownerNameController,
                              label: 'Owner Legal Name *',
                              icon: Icons.person_outline_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),

                            // 3. Business Category
                            _buildInlineEditableField(
                              keyKey: 'category',
                              controller: _categoryController,
                              label: 'Business Category *',
                              icon: Icons.category_outlined,
                              isCategoryDropdown: true,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),

                            // 4. GSTIN Number
                            _buildInlineEditableField(
                              keyKey: 'gstin',
                              controller: _gstinController,
                              label: 'Corporate GSTIN Number',
                              icon: Icons.receipt_long_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),

                            // 5. UPI ID
                            _buildInlineEditableField(
                              keyKey: 'upi',
                              controller: _upiController,
                              label: 'Business UPI Payment ID',
                              icon: Icons.qr_code_rounded,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 16),

                            // 6. Shop Address
                            _buildInlineEditableField(
                              keyKey: 'address',
                              controller: _addressController,
                              label: 'Physical Shop Address *',
                              icon: Icons.location_on_outlined,
                              maxLines: 2,
                              textColor: textColor,
                              subTextColor: subTextColor,
                              editableBgColor: editableBgColor,
                              borderColor: borderColor,
                            ),
                            const SizedBox(height: 32),

                            SizedBox(
                              height: 52,
                              child: ElevatedButton.icon(
                                onPressed: _isSaving ? null : _updateShopProfile,
                                icon: _isSaving
                                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.save_rounded, color: Colors.white),
                                label: Text(_isSaving ? 'Saving Changes...' : 'Save Profile Changes', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // 🔒 Locked Field
  Widget _buildLockedField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color textColor,
    required Color subTextColor,
    required Color lockedBgColor,
    required Color borderColor,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: textColor.withOpacity(0.6), fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        labelText: '$label (LOCKED)',
        labelStyle: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: const Color(0xFFEF4444), size: 20),
        suffixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFEF4444), size: 18),
        filled: true,
        fillColor: lockedBgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
      ),
    );
  }

  // ✏️ Inline Editable Field
  Widget _buildInlineEditableField({
    required String keyKey,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color textColor,
    required Color subTextColor,
    required Color editableBgColor,
    required Color borderColor,
    bool isCategoryDropdown = false,
    int maxLines = 1,
  }) {
    bool isEnabled = _enabledFields[keyKey] ?? false;

    return TextFormField(
      controller: controller,
      readOnly: !isEnabled,
      maxLines: maxLines,
      style: TextStyle(color: isEnabled ? textColor : textColor.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isEnabled ? const Color(0xFF38BDF8) : subTextColor, fontSize: 13, fontWeight: FontWeight.bold),
        prefixIcon: Icon(icon, color: const Color(0xFF38BDF8), size: 20),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCategoryDropdown && isEnabled)
              PopupMenuButton<String>(
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: textColor.withOpacity(0.7)),
                onSelected: (val) => setState(() => controller.text = val),
                itemBuilder: (context) => _businessCategories.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
              ),
            IconButton(
              icon: Icon(
                isEnabled ? Icons.check_circle_rounded : Icons.edit_outlined,
                color: isEnabled ? const Color(0xFF10B981) : const Color(0xFF38BDF8),
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _enabledFields[keyKey] = !isEnabled;
                });
              },
            ),
          ],
        ),
        filled: true,
        fillColor: editableBgColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isEnabled ? const Color(0xFF38BDF8) : borderColor, width: isEnabled ? 1.5 : 1)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: isEnabled ? const Color(0xFF38BDF8) : borderColor, width: isEnabled ? 1.5 : 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
      ),
      validator: (v) => (v == null || v.isEmpty) && label.contains('*') ? 'Field required' : null,
    );
  }
}