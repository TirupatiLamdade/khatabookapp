// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:go_router/go_router.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ShopManageScreen extends StatefulWidget {
//   const ShopManageScreen({Key? key}) : super(key: key);

//   @override
//   State<ShopManageScreen> createState() => _ShopManageScreenState();
// }

// class _ShopManageScreenState extends State<ShopManageScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   // English Fields Controllers
//   final _shopNameController = TextEditingController();
//   final _ownerNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _gstinController = TextEditingController();
//   final _addressController = TextEditingController();

//   String? _selectedCategory;
//   String _currentUsername = 'Loading...';
//   String _currentPasswordDisplay = '••••••••••••••••'; 
//   bool _isProfileLoading = true;
//   bool _isSaving = false;

//   final List<String> _businessCategories = [
//     'Retail Shop / Kirana',
//     'Wholesale / Distributor',
//     'Electronics & Mobile Hardware',
//     'Textile / Apparels Logistics',
//     'Medical / Pharmaceuticals',
//     'Restaurateur / Food Services',
//     'Manufacturing Enterprise',
//     'Freelance / Professional Services',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserCredentialsAndShopDetails();
//   }

//   @override
//   void dispose() {
//     _shopNameController.dispose();
//     _ownerNameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _gstinController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchUserCredentialsAndShopDetails() async {
//     try {
//       final User? user = FirebaseAuth.instance.currentUser;
//       if (user != null) {
//         setState(() {
//           _emailController.text = user.email ?? 'lamdadetirupati89@gmail.com';
//           _phoneController.text = user.phoneNumber ?? '';
//         });

//         final docSnapshot = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();

//         if (docSnapshot.exists && docSnapshot.data() != null) {
//           final data = docSnapshot.data()!;
//           setState(() {
//             _currentUsername = data['username'] ?? 'User Operator';
            
//             if (data['shopName'] != null) _shopNameController.text = data['shopName'];
//             if (data['ownerName'] != null) _ownerNameController.text = data['ownerName'];
//             if (data['phone'] != null && _phoneController.text.isEmpty) _phoneController.text = data['phone'];
//             if (data['email'] != null && _emailController.text.isEmpty) _emailController.text = data['email'];
//             if (data['gstin'] != null) _gstinController.text = data['gstin'];
//             if (data['shopAddress'] != null) _addressController.text = data['shopAddress'];
            
//             if (data['businessCategory'] != null && _businessCategories.contains(data['businessCategory'])) {
//               _selectedCategory = data['businessCategory'];
//             }
//           });
//         }
//       } else {
//         setState(() {
//           _emailController.text = 'lamdadetirupati89@gmail.com';
//           _currentUsername = 'Demo Operator';
//         });
//       }
//     } catch (e) {
//       _showTopNotification('Error retrieving sync credentials.', isError: true);
//     } finally {
//       setState(() => _isProfileLoading = false);
//     }
//   }

//   Future<void> _saveShopDetails() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isSaving = true);
//     try {
//       final User? user = FirebaseAuth.instance.currentUser;
//       final Map<String, dynamic> updatePayload = {
//         'shopName': _shopNameController.text.trim(),
//         'ownerName': _ownerNameController.text.trim(),
//         'email': _emailController.text.trim(),
//         'phone': _phoneController.text.trim(),
//         'businessCategory': _selectedCategory,
//         'gstin': _gstinController.text.trim().toUpperCase(),
//         'shopAddress': _addressController.text.trim(),
//         'lastUpdated': FieldValue.serverTimestamp(),
//       };

//       if (user != null) {
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatePayload);
//       }
      
//       _showTopNotification('Business Profile Saved Successfully.');
      
//       Future.delayed(const Duration(milliseconds: 1500), () {
//         context.go('/dashboard');
//       });
//     } catch (e) {
//       _showTopNotification('Failed to synchronize data.', isError: true);
//     } finally {
//       setState(() => _isSaving = false);
//     }
//   }

//   void _showTopNotification(String message, {bool isError = false}) {
//     final overlay = Overlay.of(context);
//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: 30,
//         left: 24,
//         right: 24,
//         child: Material(
//           color: Colors.transparent,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             decoration: BoxDecoration(
//               color: isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
//               borderRadius: BorderRadius.circular(8),
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
//             ),
//             child: Row(
//               children: [
//                 Icon(isError ? Icons.report_problem_rounded : Icons.check_circle_rounded, color: Colors.white, size: 22),
//                 const SizedBox(width: 16),
//                 Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14))),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//     overlay.insert(overlayEntry);
//     Future.delayed(const Duration(seconds: 4), () => overlayEntry.remove());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isDesktop = size.width > 1024;
//     final isTablet = size.width > 640 && size.width <= 1024;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       appBar: AppBar(
//         title: const Text('Shop Profile Setup', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
//         backgroundColor: const Color(0xFF1E293B),
//         elevation: 0,
//         centerTitle: true,
//       ),
//       body: _isProfileLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
//           : Center(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       // 🔐 AUTOMATIC LOGIN OPERATOR CARD
//                       Center(
//                         child: Container(
//                           width: isDesktop ? 800 : (isTablet ? size.width * 0.85 : size.width),
//                           padding: const EdgeInsets.all(20),
//                           margin: const EdgeInsets.only(bottom: 28),
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF1E293B),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.white, width: 1),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Row(
//                                 children: [
//                                   Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF38BDF8), size: 22),
//                                   SizedBox(width: 10),
//                                   Text('Active Login Operator Profile', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
//                                 ],
//                               ),
//                               const Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 10),
//                                 child: Divider(color: Colors.white12),
//                               ),
//                               Wrap(
//                                 spacing: 16,
//                                 runSpacing: 14,
//                                 children: [
//                                   _buildReadOnlyCredentialWidget('Username', _currentUsername, size.width, isDesktop, isTablet),
//                                   _buildReadOnlyCredentialWidget('Password Code', _currentPasswordDisplay, size.width, isDesktop, isTablet),
//                                   _buildReadOnlyCredentialWidget('Registered Email', _emailController.text, size.width, isDesktop, isTablet),
//                                   _buildReadOnlyCredentialWidget('Verified Mobile', _phoneController.text.isNotEmpty ? _phoneController.text : 'Not Linked', size.width, isDesktop, isTablet),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // 🏢 VIEW CONDITIONAL ROUTER (Desktop vs Mobile layout)
//                       Center(
//                         child: SizedBox(
//                           width: isDesktop ? 800 : (isTablet ? size.width * 0.85 : size.width),
//                           child: Column(
//                             children: [
//                               Text(
//                                 'Enter Business Profile Information', 
//                                 style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), 
//                                 textAlign: TextAlign.center
//                               ),
//                               const SizedBox(height: 24),
                              
//                               // यहाँ चेक हो रहा है कि डेस्कटॉप लेआउट दिखाना है या मोबाइल लेआउट
//                               isDesktop ? _buildWebDesktopLayout() : _buildMobileTabletLayout(),
                              
//                               const SizedBox(height: 32),
                              
//                               // SUBMIT ACTION BUTTON
//                               SizedBox(
//                                 height: 50,
//                                 width: double.infinity,
//                                 child: ElevatedButton(
//                                   onPressed: _isSaving ? null : _saveShopDetails,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFF6366F1), 
//                                     foregroundColor: Colors.white,
//                                     disabledBackgroundColor: Colors.white12,
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                     elevation: 2,
//                                   ),
//                                   child: _isSaving
//                                       ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
//                                       : const Text('Save Details & Continue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.2)),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   // 🖥️ 1. WEB / DESKTOP LAYOUT (2 Column Side-by-Side Grid)
//   Widget _buildWebDesktopLayout() {
//     return Column(
//       children: [
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _shopNameController,
//                 enabled: !_isSaving,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: _buildFormInputDecoration('Shop / Business Name *', 'Enter your registered shop name', Icons.storefront_rounded),
//                 validator: (v) => v!.isEmpty ? 'Shop name is required.' : null,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: TextFormField(
//                 controller: _ownerNameController,
//                 enabled: !_isSaving,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: _buildFormInputDecoration('Owner Name *', 'Enter business owner legal name', Icons.person_outline_rounded),
//                 validator: (v) => v!.isEmpty ? 'Owner name is required.' : null,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: TextFormField(
//                 controller: _emailController,
//                 readOnly: true,
//                 style: const TextStyle(color: Color(0xFF94A3B8)),
//                 decoration: _buildFormInputDecoration('Sync Email Address', 'Linked account email address', Icons.mail_outline_rounded).copyWith(
//                   fillColor: const Color(0xFF1E293B), 
//                 ),
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: TextFormField(
//                 controller: _phoneController,
//                 enabled: !_isSaving,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: _buildFormInputDecoration('Mobile Number *', 'Enter 10-digit mobile number', Icons.phone_android_rounded, prefixText: '+91 '),
//                 validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Enter a valid 10-digit mobile number.' : null,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Expanded(
//               child: DropdownButtonFormField<String>(
//                 value: _selectedCategory,
//                 dropdownColor: const Color(0xFF0F172A),
//                 style: const TextStyle(color: Colors.white),
//                 icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8), size: 28),
//                 decoration: _buildFormInputDecoration('Business Category *', 'Select your operational sector', Icons.category_outlined),
//                 items: _businessCategories.map((String category) {
//                   return DropdownMenuItem<String>(
//                     value: category,
//                     child: Text(category, style: const TextStyle(fontSize: 14)),
//                   );
//                 }).toList(),
//                 onChanged: _isSaving ? null : (value) {
//                   setState(() {
//                     _selectedCategory = value;
//                   });
//                 },
//                 validator: (v) => v == null ? 'Please select a business category.' : null,
//               ),
//             ),
//             const SizedBox(width: 20),
//             Expanded(
//               child: TextFormField(
//                 controller: _gstinController,
//                 enabled: !_isSaving,
//                 style: const TextStyle(color: Colors.white),
//                 decoration: _buildFormInputDecoration('GST Number (Optional)', 'Enter valid company GSTIN number', Icons.receipt_long_rounded),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _addressController,
//           enabled: !_isSaving,
//           maxLines: 3,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('Shop Address *', 'Enter physical location complete address details', Icons.location_on_outlined),
//           validator: (v) => v!.isEmpty ? 'Shop address is required.' : null,
//         ),
//       ],
//     );
//   }

//   // 📱 2. MOBILE / TABLET LAYOUT (Single Column Stacked Form)
//   Widget _buildMobileTabletLayout() {
//     return Column(
//       children: [
//         TextFormField(
//           controller: _shopNameController,
//           enabled: !_isSaving,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('Shop / Business Name *', 'Enter your registered shop name', Icons.storefront_rounded),
//           validator: (v) => v!.isEmpty ? 'Shop name is required.' : null,
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _ownerNameController,
//           enabled: !_isSaving,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('Owner Name *', 'Enter business owner legal name', Icons.person_outline_rounded),
//           validator: (v) => v!.isEmpty ? 'Owner name is required.' : null,
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _emailController,
//           readOnly: true,
//           style: const TextStyle(color: Color(0xFF94A3B8)),
//           decoration: _buildFormInputDecoration('Sync Email Address', 'Linked account email address', Icons.mail_outline_rounded).copyWith(
//             fillColor: const Color(0xFF1E293B), 
//           ),
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _phoneController,
//           enabled: !_isSaving,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('Mobile Number *', 'Enter 10-digit mobile number', Icons.phone_android_rounded, prefixText: '+91 '),
//           validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Enter a valid 10-digit mobile number.' : null,
//         ),
//         const SizedBox(height: 20),
//         DropdownButtonFormField<String>(
//           value: _selectedCategory,
//           dropdownColor: const Color(0xFF0F172A),
//           style: const TextStyle(color: Colors.white),
//           icon: const Icon(Icons.arrow_drop_down_rounded, color: Color(0xFF94A3B8), size: 28),
//           decoration: _buildFormInputDecoration('Business Category *', 'Select your operational sector', Icons.category_outlined),
//           items: _businessCategories.map((String category) {
//             return DropdownMenuItem<String>(
//               value: category,
//               child: Text(category, style: const TextStyle(fontSize: 14)),
//             );
//           }).toList(),
//           onChanged: _isSaving ? null : (value) {
//             setState(() {
//               _selectedCategory = value;
//             });
//           },
//           validator: (v) => v == null ? 'Please select a business category.' : null,
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _gstinController,
//           enabled: !_isSaving,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('GST Number (Optional)', 'Enter valid company GSTIN number', Icons.receipt_long_rounded),
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           controller: _addressController,
//           enabled: !_isSaving,
//           maxLines: 3,
//           style: const TextStyle(color: Colors.white),
//           decoration: _buildFormInputDecoration('Shop Address *', 'Enter physical location complete address details', Icons.location_on_outlined),
//           validator: (v) => v!.isEmpty ? 'Shop address is required.' : null,
//         ),
//       ],
//     );
//   }

//   Widget _buildReadOnlyCredentialWidget(String label, String value, double totalWidth, bool isDesktop, bool isTablet) {
//     double targetedWidth;
//     if (isDesktop) {
//       targetedWidth = (800 - 40 - 24) / 2; 
//     } else if (isTablet) {
//       targetedWidth = (totalWidth * 0.85 - 40 - 16) / 2;
//     } else {
//       targetedWidth = totalWidth; 
//     }

//     return Container(
//       width: targetedWidth,
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white, width: 1)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w600)),
//           const SizedBox(height: 4),
//           Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.3), overflow: TextOverflow.ellipsis),
//         ],
//       ),
//     );
//   }

//   InputDecoration _buildFormInputDecoration(String labelText, String hintText, IconData prefixIcon, {String? prefixText}) {
//     return InputDecoration(
//       labelText: labelText,
//       labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
//       hintText: hintText,
//       hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
//       prefixIcon: Icon(prefixIcon, color: const Color(0xFF64748B), size: 20),
//       prefixText: prefixText,
//       prefixStyle: const TextStyle(color: Colors.white, fontSize: 14),
//       filled: true,
//       fillColor: const Color(0xFF0F172A),
//       errorStyle: const TextStyle(color: Color(0xFFF87171), fontWeight: FontWeight.w500),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
//       enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.white12, width: 1)),
//       focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
//       errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1)),
//       focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5)),
//     );
//   }
// }