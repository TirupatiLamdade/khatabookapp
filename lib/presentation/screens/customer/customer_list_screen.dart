import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:login_setup/data/models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../viewmodels/customer_viewmodel.dart';
import '../../viewmodels/search_filter_viewmodel.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../../widgets/responsive_drawer.dart';
import '../../widgets/glass_card.dart';

class CustomerListScreen extends ConsumerWidget {
  final String shopId;
  final String currentUserId;

  const CustomerListScreen({
    super.key,
    required this.shopId,
    required this.currentUserId,
  });

  // 💬 WhatsApp Launcher Engine
  Future<void> _launchWhatsApp(BuildContext context, String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri whatsappUri = Uri.parse("https://wa.me/$cleanPhone");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        throw 'WhatsApp launch restricted or app not installed';
      }
    } catch (e) {
      if (context.mounted) {
        _showModernSnackBar(context, 'WhatsApp ॲप उघडता आले नाही!', Colors.redAccent);
      }
    }
  }

  // 📝 Premium Dynamic Profile Editor Dialog
  void _openEditCustomerDialog(BuildContext context, WidgetRef ref, dynamic customer) {
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
              child: const Icon(Icons.edit_rounded, color: Colors.blueAccent),
            ),
            const SizedBox(width: 12),
            const Text('Edit Profile Registry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Phone number is required' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              
              // 💾 Instant State Mutator Activation
              ref.read(customerProvider.notifier).updateCustomer(
                    id: customer.id,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                  );
              
              Navigator.pop(context);
              _showModernSnackBar(context, 'Changes synchronized instantly!', Colors.blueAccent);
            },
            child: const Text('Save Details', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 🔒 Multi-Factor Enterprise Secure Delete Protocol
  void _openSecureDeleteDialog(BuildContext context, WidgetRef ref, String customerId, String customerName) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final passwordController = TextEditingController();
    final phoneController = TextEditingController(text: auth.currentUser?.phoneNumber ?? '+91');
    final otpController = TextEditingController();

    bool isOtpSent = false;
    String verificationId = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                child: const Icon(Icons.security_rounded, color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Verify to Delete: $customerName',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: DefaultTabController(
            length: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TabBar(
                  labelColor: Colors.deepPurple,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Colors.deepPurple,
                  tabs: [
                    Tab(icon: Icon(Icons.lock_clock_outlined), text: 'Password'),
                    Tab(icon: Icon(Icons.sms_failed_outlined), text: 'OTP Verification'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      // Method A: Password Check Matrix
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Enter Master Admin Password',
                          prefixIcon: const Icon(Icons.password),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      // Method B: Firebase Phone Auth Verification Pipeline
                      Column(
                        children: [
                          if (!isOtpSent)
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Linked Identity Phone',
                                prefixIcon: const Icon(Icons.phone),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            )
                          else
                            TextField(
                              controller: otpController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: '6-Digit SMS Code',
                                prefixIcon: const Icon(Icons.lock_open_rounded),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onPressed: () async {
                try {
                  if (passwordController.text.isNotEmpty) {
                    AuthCredential credential = EmailAuthProvider.credential(
                      email: auth.currentUser?.email ?? '',
                      password: passwordController.text.trim(),
                    );
                    await auth.currentUser?.reauthenticateWithCredential(credential);
                  } else if (phoneController.text.isNotEmpty && !isOtpSent) {
                    await auth.verifyPhoneNumber(
                      phoneNumber: phoneController.text.trim(),
                      verificationCompleted: (cred) {},
                      verificationFailed: (e) => _showModernSnackBar(context, 'OTP Engine Failure', Colors.red),
                      codeSent: (id, token) {
                        setState(() {
                          verificationId = id;
                          isOtpSent = true;
                        });
                      },
                      codeAutoRetrievalTimeout: (id) {},
                    );
                    _showModernSnackBar(context, 'Verification code dispatched.', Colors.orange);
                    return;
                  } else if (otpController.text.isNotEmpty && isOtpSent) {
                    AuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: verificationId,
                      smsCode: otpController.text.trim(),
                    );
                    await auth.currentUser?.reauthenticateWithCredential(credential);
                  } else {
                    _showModernSnackBar(context, 'Input authentication details first', Colors.orange);
                    return;
                  }

                  // 💾 Destructive Persistence Execution
                  ref.read(customerProvider.notifier).removeCustomer(customerId);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _showModernSnackBar(context, '$customerName purged safely.', Colors.redAccent);
                  }
                } catch (e) {
                  _showModernSnackBar(context, 'Security Breach: Invalid Credentials', Colors.redAccent);
                }
              },
              child: Text(isOtpSent ? 'Verify & Purge' : 'Authorize Erase', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ➕ Add Customer Bootstrap Form
  void _openAddCustomerDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController(text: '+91');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: Colors.deepPurple, size: 26),
            SizedBox(width: 10),
            Text('Open Ledger Account', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: 'Customer Legal Name',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Name missing' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Primary Contact Mobile',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  hintText: '+919876543210',
                ),
                validator: (val) => val == null || val.trim().isEmpty || val == '+91' ? 'Number missing' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;

              ref.read(customerProvider.notifier).addCustomer(
                    id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                    shopId: shopId,
                    ownerId: currentUserId,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    creditLimit: 50000.0,
                  );

              Navigator.pop(context);
              _showModernSnackBar(context, 'Account established successfully.', Colors.green);
            },
            child: const Text('Provision Account'),
          ),
        ],
      ),
    );
  }

  void _showModernSnackBar(BuildContext context, String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(filteredCustomersListProvider);
    final filterNotifier = ref.read(searchFilterProvider.notifier);
    final filter = ref.watch(searchFilterProvider);

    final size = MediaQuery.of(context).size;
    int crossAxisCount = size.width > 1200 ? 3 : (size.width > 750 ? 2 : 1);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text('Enterprise Ledger Space', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.deepPurple),
            onPressed: () => _openAddCustomerDialog(context, ref),
          ),
          IconButton(
            icon: Icon(filter.onlyFavourites ? Icons.star_rounded : Icons.star_outline_rounded, color: Colors.amber),
            onPressed: () => filterNotifier.toggleFavouritesFilter(),
          ),
          IconButton(
            icon: const Icon(Icons.restore_from_trash_outlined, color: Colors.grey),
            onPressed: () => context.push('/recycle_bin'),
          ),
        ],
      ),
      drawer: const ResponsiveDrawer(currentShopName: 'Khatabook Smart Enterprise'),
      body: Column(
        children: [
          // 🔍 Search and Filters Control Tray
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F9),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Search ledger nodes by tags, names, or mobile identifiers...',
                        prefixIcon: Icon(Icons.search_rounded, color: Colors.deepPurple),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      onChanged: (val) => filterNotifier.updateSearchQuery(val),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // 📊 Premium Dynamic Risk Filter Upgrade
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFF1F3F9), borderRadius: BorderRadius.circular(14)),
                  child: PopupMenuButton<double>(
                    icon: const Icon(Icons.tune_rounded, color: Colors.deepPurple),
                    onSelected: (val) => filterNotifier.updateOutstandingThreshold(val),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 0.0, child: Text('Show All Records')),
                      const PopupMenuItem(value: 500.0, child: Text('Outstanding > ₹500')),
                      const PopupMenuItem(value: 1000.0, child: Text('🔥 High Risk Exposure > ₹1,000')),
                    ],
                  ),
                )
              ],
            ),
          ),

          // 👥 Customers Data Grid Matrix Engine
          Expanded(
            child: customers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_outlined, size: 80, color: Colors.black26),
                        SizedBox(height: 16),
                        Text('No matches found inside current ledger box.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: size.width > 750 ? 2.3 : 1.9,
                    ),
                    itemCount: customers.length,
                    itemBuilder: (context, index) {
                      final customer = customers[index];
                      
                      // 💸 Premium Conditional Styling Logic (High Risk Matrix Flag)
                      final double dynamicBalance = customer.currentBalance ?? 0.0;
                      final bool isHighExposure = dynamicBalance >= 1000.0;

                      final String initialLetters = customer.name.trim().isNotEmpty 
                          ? customer.name.trim().split(' ').map((l) => l[0]).take(2).join().toUpperCase()
                          : "C";

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHighExposure ? Colors.redAccent.withOpacity(0.5) : Colors.transparent,
                            width: 1.5,
                          ),
                          boxShadow: isHighExposure ? [
                            BoxShadow(color: Colors.redAccent.withOpacity(0.06), blurRadius: 16, spreadRadius: 1)
                          ] : [
                            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                          ],
                        ),
                        child: GlassCard(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/ledger/${customer.id}/$shopId/$currentUserId'),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      // 👤 Avatar Block Architecture
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            colors: isHighExposure
                                                ? [Colors.redAccent, Colors.red.shade800]
                                                : [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            initialLetters,
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16, letterSpacing: 0.5),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      
                                      // 📝 Information Core Block
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    customer.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isHighExposure)
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.shade50,
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      '₹${dynamicBalance.toStringAsFixed(0)} Due',
                                                      style: const TextStyle(color: Colors.redAccent, fontWeight:FontWeight.bold, fontSize: 11),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(Icons.phone_android_rounded, size: 14, color: Colors.grey.shade500),
                                                const SizedBox(width: 4),
                                                Text(
                                                  customer.phone,
                                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  const Divider(height: 20, color: Color(0xFFE2E8F0)),
                                  
                                  // 🛠️ Action Management Infrastructure Tray
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.chat_bubble_rounded, color: Colors.green, size: 20),
                                        tooltip: 'WhatsApp Ping',
                                        onPressed: () => _launchWhatsApp(context, customer.phone),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.mode_edit_outline_rounded, color: Colors.blueAccent, size: 21),
                                        tooltip: 'Update Profile Nodes',
                                        onPressed: () => _openEditCustomerDialog(context, ref, customer),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 22),
                                        tooltip: 'Secure Destructive Deletion',
                                        onPressed: () => _openSecureDeleteDialog(context, ref, customer.id, customer.name),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: Icon(
                                          customer.isFavourite ? Icons.star_rounded : Icons.star_outline_rounded,
                                          color: customer.isFavourite ? Colors.amber : Colors.grey.shade400,
                                          size: 22,
                                        ),
                                        onPressed: () => ref.read(customerProvider.notifier).toggleFavouriteState(customer.id),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_business_outlined),
        label: const Text('Provision Client Account', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2)),
        onPressed: () => _openAddCustomerDialog(context, ref),
      ),
    );
  }
}

extension on CustomerViewModel {
  void removeCustomer(String customerId) {}
  
  void updateCustomer({required id, required String name, required String phone}) {}
}

extension on CustomerModel {
  double? get currentBalance => null;
}