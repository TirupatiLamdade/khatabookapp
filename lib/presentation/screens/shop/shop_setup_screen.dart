
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopManageScreen extends StatefulWidget {
  // 🔐 FIELDS ADDED: आता कंपायलर एरर पूर्णपणे दूर झाली आहे
  final String prefilledEmail;
  final String prefilledPhone;

  const ShopManageScreen({
    Key? key, 
    required this.prefilledEmail, 
    required this.prefilledPhone,
  }) : super(key: key);

  @override
  State<ShopManageScreen> createState() => _ShopManageScreenState();
}

class _ShopManageScreenState extends State<ShopManageScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // High-Performance Controllers
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstinController = TextEditingController();
  final _addressController = TextEditingController();
  final _categoryController = TextEditingController();

  String _currentUsername = 'Loading Operational Node...';
  String _currentPasswordDisplay = '••••••••••••••••'; 
  bool _obscurePassword = true;
  bool _isProfileLoading = true;
  bool _isSaving = false;

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
    _fetchUserCredentialsAndShopDetails();
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    _addressController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserCredentialsAndShopDetails() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _emailController.text = user.email ?? widget.prefilledEmail;
          _phoneController.text = user.phoneNumber ?? widget.prefilledPhone;
        });

        final docSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          final data = docSnapshot.data()!;
          setState(() {
            _currentUsername = data['username'] ?? 'User Operator';
            if (data['password'] != null) {
              _currentPasswordDisplay = data['password'];
            }
            
            if (data['fullName'] != null && _ownerNameController.text.isEmpty) {
              _ownerNameController.text = data['fullName'];
            }
            if (data['shopName'] != null) _shopNameController.text = data['shopName'];
            if (data['ownerName'] != null && data['ownerName'].toString().isNotEmpty) {
              _ownerNameController.text = data['ownerName'];
            }
            if (data['phone'] != null && data['phone'].toString().isNotEmpty) {
              _phoneController.text = data['phone'];
            }
            if (data['email'] != null && data['email'].toString().isNotEmpty) {
              _emailController.text = data['email'];
            }
            if (data['gstin'] != null) _gstinController.text = data['gstin'];
            if (data['shopAddress'] != null) _addressController.text = data['shopAddress'];
            if (data['businessCategory'] != null) {
              _categoryController.text = data['businessCategory'];
            }
          });
        }
      } else {
        setState(() {
          _currentUsername = 'Demo Operator';
          if (widget.prefilledEmail.isNotEmpty) _emailController.text = widget.prefilledEmail;
          if (widget.prefilledPhone.isNotEmpty) _phoneController.text = widget.prefilledPhone;
        });
      }
    } catch (e) {
      _showTopNotification('Error retrieving sync credentials.', isError: true);
    } finally {
      setState(() => _isProfileLoading = false);
    }
  }

  // 🚀 प्रोफाइल सेव्ह झाल्यावर थेट /home (HomeScreen) वर रिडायरेक्ट करणे
  Future<void> _saveShopDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      User? user = FirebaseAuth.instance.currentUser;
      
      final Map<String, dynamic> updatePayload = {
        'username': _currentUsername,
        'shopName': _shopNameController.text.trim(),
        'ownerName': _ownerNameController.text.trim(),
        'fullName': _ownerNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'businessCategory': _categoryController.text.trim(),
        'gstin': _gstinController.text.trim().toUpperCase(),
        'shopAddress': _addressController.text.trim(),
        'isFirstTime': false, 
        'firstLogin': false,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(updatePayload, SetOptions(merge: true));
      }
      
      _showTopNotification('Business Profile Saved Successfully.');
      
      // ➡️ 🚀 Direct Redirect to HomeScreen (`/home`)
      if (mounted) {
        context.go('/home'); 
      }
    } catch (e) {
      _showTopNotification('Failed to synchronize cloud database ledger.', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showTopNotification(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 40,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
              ],
            ),
            child: Row(
              children: [
                Icon(isError ? Icons.report_gmailerrorred_rounded : Icons.verified_user_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    message, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)
                  )
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 640 && size.width <= 1024;
    final layoutWidth = isDesktop ? 850.0 : (isTablet ? size.width * 0.90 : size.width);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        appBar: AppBar(
          title: const Text(
            'Shop Profile Setup', 
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 0.5)
          ),
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          centerTitle: true,
        ),
        body: _isProfileLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)))
            : Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // 🔐 AUTOMATIC LOGIN OPERATOR CARD
                        Container(
                          width: layoutWidth,
                          padding: const EdgeInsets.all(24),
                          margin: const EdgeInsets.only(bottom: 32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.shield_outlined, color: Color(0xFF38BDF8), size: 22),
                                  SizedBox(width: 12),
                                  Text(
                                    'Active Operator Ledger Security Node', 
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Divider(color: Colors.white12),
                              ),
                              Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  _buildReadOnlyCredentialWidget('OPERATOR NODE USERNAME', _currentUsername, size.width, isDesktop, isTablet),
                                  _buildPasswordWidget(size.width, isDesktop, isTablet),
                                  _buildReadOnlyCredentialWidget('SYNCHRONIZED METADATA EMAIL', _emailController.text, size.width, isDesktop, isTablet),
                                  _buildReadOnlyCredentialWidget('VERIFIED COMMUNICATION MOBILE', _phoneController.text.isNotEmpty ? _phoneController.text : 'Not Linked', size.width, isDesktop, isTablet),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 🏢 CORE FORMS ARCHITECTURE GRID
                        Container(
                          width: layoutWidth,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white12, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Corporate Registry Profile Information', 
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.3), 
                                textAlign: TextAlign.start
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'Complete the profile setup to securely initialize business balance sheets.', 
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w500)
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Divider(color: Colors.white12),
                              ),
                              
                              isDesktop ? _buildWebDesktopLayout() : _buildMobileTabletLayout(),
                              
                              const SizedBox(height: 32),
                              
                              // SUBMIT TRANSACTION ACTION BUTTON
                              SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveShopDetails,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6366F1), 
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.white12,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 2,
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Text('Initialize Profile & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5)),
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
      ),
    );
  }

  // 🖥️ 1. WEB / DESKTOP LAYOUT
  Widget _buildWebDesktopLayout() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _shopNameController,
                enabled: !_isSaving,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: _buildFormInputDecoration('Shop / Business Name *', 'Enter your registered corporate shop name', Icons.storefront_rounded),
                validator: (v) => v!.isEmpty ? 'Enterprise Business name is mandatory.' : null,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                controller: _ownerNameController,
                enabled: !_isSaving,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: _buildFormInputDecoration('Owner Legal Identity Name *', 'Enter business owner legal full name', Icons.person_outline_rounded),
                validator: (v) => v!.isEmpty ? 'Owner Identity name is mandatory.' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _emailController,
                enabled: !_isSaving,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: _buildFormInputDecoration('Synchronized Email Address *', 'example@gmail.com', Icons.mail_outline_rounded),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email address is mandatory.';
                  if (!v.contains('@') || !v.endsWith('.com')) return 'Must be a valid email ending with .com (e.g. user@gmail.com)';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                enabled: !_isSaving,
                maxLength: 10,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.phone,
                decoration: _buildFormInputDecoration('Mobile Communication Channel *', 'Enter 10-digit primary mobile terminal', Icons.phone_android_rounded, prefixText: '+91 '),
                validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Provide verified 10-digit communication gateway.' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextFormField(
                controller: _categoryController,
                enabled: !_isSaving,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: _buildFormInputDecoration(
                  'Operational Business Category *', 
                  'Select or type sector...', 
                  Icons.category_outlined,
                  suffixIcon: PopupMenuButton<String>(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 24),
                    onSelected: (String value) {
                      setState(() {
                        _categoryController.text = value;
                      });
                    },
                    itemBuilder: (context) => _businessCategories.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Please map an active business operational standard.' : null,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: TextFormField(
                controller: _gstinController,
                enabled: !_isSaving,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                textCapitalization: TextCapitalization.characters,
                decoration: _buildFormInputDecoration('Corporate GSTIN Number (Optional)', 'Enter verified company 15-digit GSTIN details', Icons.receipt_long_rounded),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _addressController,
          enabled: !_isSaving,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration('Physical Headquarters Address *', 'Enter permanent warehouse/physical hub localization data', Icons.location_on_outlined),
          validator: (v) => v!.isEmpty ? 'Physical logistics hub terminal data is required.' : null,
        ),
      ],
    );
  }

  // 📱 2. MOBILE / TABLET LAYOUT
  Widget _buildMobileTabletLayout() {
    return Column(
      children: [
        TextFormField(
          controller: _shopNameController,
          enabled: !_isSaving,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration('Shop / Business Name *', 'Enter your registered corporate shop name', Icons.storefront_rounded),
          validator: (v) => v!.isEmpty ? 'Enterprise Business name is mandatory.' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _ownerNameController,
          enabled: !_isSaving,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration('Owner Legal Identity Name *', 'Enter business owner legal full name', Icons.person_outline_rounded),
          validator: (v) => v!.isEmpty ? 'Owner Identity name is mandatory.' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _emailController,
          enabled: !_isSaving,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration('Synchronized Email Address *', 'example@gmail.com', Icons.mail_outline_rounded),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email address is mandatory.';
            if (!v.contains('@') || !v.endsWith('.com')) return 'Must be a valid email ending with .com (e.g. user@gmail.com)';
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _phoneController,
          enabled: !_isSaving,
          maxLength: 10,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          keyboardType: TextInputType.phone,
          decoration: _buildFormInputDecoration('Mobile Communication Channel *', 'Enter 10-digit primary mobile terminal', Icons.phone_android_rounded, prefixText: '+91 '),
          validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Provide verified 10-digit communication gateway.' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _categoryController,
          enabled: !_isSaving,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration(
            'Operational Business Category *', 
            'Select or type sector...', 
            Icons.category_outlined,
            suffixIcon: PopupMenuButton<String>(
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 24),
              onSelected: (String value) {
                setState(() {
                  _categoryController.text = value;
                });
              },
              itemBuilder: (context) => _businessCategories.map((c) => PopupMenuItem(value: c, child: Text(c))).toList(),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Please map an active business operational standard.' : null,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _gstinController,
          enabled: !_isSaving,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          textCapitalization: TextCapitalization.characters,
          decoration: _buildFormInputDecoration('Corporate GSTIN Number (Optional)', 'Enter verified company 15-digit GSTIN details', Icons.receipt_long_rounded),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _addressController,
          enabled: !_isSaving,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          decoration: _buildFormInputDecoration('Physical Headquarters Address *', 'Enter permanent warehouse/physical hub localization data', Icons.location_on_outlined),
          validator: (v) => v!.isEmpty ? 'Physical logistics hub terminal data is required.' : null,
        ),
      ],
    );
  }

  Widget _buildReadOnlyCredentialWidget(String label, String value, double totalWidth, bool isDesktop, bool isTablet) {
    double targetedWidth;
    if (isDesktop) {
      targetedWidth = (850.0 - 56 - 48) / 2; 
    } else if (isTablet) {
      targetedWidth = (totalWidth * 0.90 - 48 - 16) / 2;
    } else {
      targetedWidth = totalWidth; 
    }

    return Container(
      width: targetedWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.white12, width: 1)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildPasswordWidget(double totalWidth, bool isDesktop, bool isTablet) {
    double targetedWidth;
    if (isDesktop) {
      targetedWidth = (850.0 - 56 - 48) / 2; 
    } else if (isTablet) {
      targetedWidth = (totalWidth * 0.90 - 48 - 16) / 2;
    } else {
      targetedWidth = totalWidth; 
    }

    return Container(
      width: targetedWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A), 
        borderRadius: BorderRadius.circular(10), 
        border: Border.all(color: Colors.white12, width: 1)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SECURITY TOKEN DISPLAY', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(
                  _obscurePassword ? '••••••••••••••••' : _currentPasswordDisplay, 
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 20),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildFormInputDecoration(String labelText, String hintText, IconData prefixIcon, {String? prefixText, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF38BDF8), size: 18),
      prefixText: prefixText,
      prefixStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      suffixIcon: suffixIcon,
      counterText: "",
      filled: true,
      fillColor: const Color(0xFF0F172A),
      errorStyle: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.bold, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12, width: 1)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
    );
  }
}