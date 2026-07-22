
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../customer/ledger_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all'; 
  double? _customMinFilter;
  bool _showArchived = false;

  // 🔄 Particular Buttons Loading Tracking States
  final Map<String, bool> _buttonLoadingState = {};
  
  get textColor => null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setButtonLoading(String id, bool loading) {
    setState(() {
      _buttonLoadingState[id] = loading;
    });
  }

  bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

  void _launchWhatsApp(String phone, String name) async {
    final message = "Hello $name, your business ledger account update has been logged. Please review your balance sheets.";
    final url = "https://wa.me/91$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _performLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      context.go('/splash');
    }
  }

  // 🚨 1. SECURE DELETE DIALOG WITH PARTICULAR BUTTON LOADING
  void _openSecureDeleteDialog(BuildContext context, String customerId, String customerName) {
    final verifyController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isDeleting = _isButtonLoading('del_$customerId');

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
            ),
            title: Row(
              children: const [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 28),
                SizedBox(width: 10),
                Text('Confirm Deletion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'To permanently remove this customer account, type the required name below:',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            customerName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: verifyController,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      hintText: 'Type "$customerName" here',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF070A0F),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFEF4444))),
                    ),
                    validator: (val) => (val == null || val.trim() != customerName.trim()) ? 'Name does not match!' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isDeleting ? null : () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                onPressed: isDeleting ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => _setButtonLoading('del_$customerId', true));
                    await Future.delayed(const Duration(seconds: 2)); // ⌛ 2 Sec Loading
                    await FirebaseFirestore.instance.collection('customers').doc(customerId).delete();
                    _setButtonLoading('del_$customerId', false);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: isDeleting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Delete Node', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✏️ 2. EDIT CUSTOMER DIALOG WITH PARTICULAR BUTTON LOADING
  void _openEditCustomerModal(BuildContext context, String customerId, Map<String, dynamic> currentData) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: currentData['name'] ?? '');
    final phoneController = TextEditingController(text: currentData['phone'] ?? '');
    final addressController = TextEditingController(text: currentData['address'] ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          bool isUpdating = _isButtonLoading('edit_$customerId');

          return AlertDialog(
            backgroundColor: const Color(0xFF0F172A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
            ),
            title: const Text('Edit Customer Info', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 16)),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(labelText: 'Customer Full Name *', labelStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      validator: (v) => (v == null || v.isEmpty) ? 'Name required.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(labelText: 'Mobile Communication *', prefixText: '+91 ', counterText: '', labelStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      validator: (v) => (v == null || v.length != 10) ? 'Enter valid 10-digit number.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController, 
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(labelText: 'Address *', labelStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                      validator: (v) => (v == null || v.isEmpty) ? 'Address required.' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: isUpdating ? null : () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
                onPressed: isUpdating ? null : () async {
                  if (formKey.currentState!.validate()) {
                    setDialogState(() => _setButtonLoading('edit_$customerId', true));
                    await Future.delayed(const Duration(seconds: 2)); // ⌛ 2 Sec Loading
                    await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                    });
                    _setButtonLoading('edit_$customerId', false);
                    if (ctx.mounted) Navigator.pop(ctx);
                  }
                },
                child: isUpdating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : const Text('Update Ledger', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
              )
            ],
          );
        },
      ),
    );
  }

  // 🎯 3. CUSTOM RANGE FILTER DIALOG (कस्टमर फिल्टर सुधारण्यासाठी)
  void _openCustomFilterModal(BuildContext context) {
    final customValController = TextEditingController(text: _customMinFilter != null ? _customMinFilter!.toStringAsFixed(0) : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFF38BDF8))),
        title: const Text('Customize Credit Limit Filter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter minimum balance amount threshold (₹):', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: customValController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                hintText: 'e.g. 2500',
                filled: true,
                fillColor: const Color(0xFF070A0F),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'all';
                _customMinFilter = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('Reset All', style: TextStyle(color: Colors.redAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8)),
            onPressed: () {
              final parsed = double.tryParse(customValController.text.trim());
              if (parsed != null) {
                setState(() {
                  _selectedFilter = 'custom';
                  _customMinFilter = parsed;
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Apply Filter', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Unauthorized Session Request.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
      );
    }

    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark || (currentTheme == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    final bgColor = isDark ? Colors.black : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: cardBgColor,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 24),
            ),
            const SizedBox(width: 14),
            Text('Smart Ledger System', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor, letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_showArchived ? Icons.archive_rounded : Icons.archive_outlined, color: _showArchived ? const Color(0xFF38BDF8) : Colors.grey),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: 'View Archived Node Accounts',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.storefront_rounded, color: Color(0xFF38BDF8)),
              tooltip: 'Shop Profile Management',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            ),
          ),
        ],
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      body: isDesktop 
          ? Row(
              children: [
                _buildWebVerticalSlider(isDark, textColor, cardBgColor, borderColor),
                Expanded(child: _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor)),
              ],
            )
          : _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddNewCustomerModal(context, currentUser.uid, isDark, textColor, cardBgColor),
              backgroundColor: const Color(0xFF10B981),
              elevation: 4,
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: const Text('Add New Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
            )
          : null,
      bottomNavigationBar: isDesktop 
          ? null 
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: cardBgColor,
              selectedItemColor: const Color(0xFF38BDF8),
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Ledger Book'),
                BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off_rounded), label: 'History Flow'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Control Desk'),
              ],
            ),
    );
  }

  Widget _buildWebVerticalSlider(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return Container(
      width: 280,
      decoration: BoxDecoration(color: cardBgColor, border: Border(right: BorderSide(color: borderColor, width: 1.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text('WORKSPACE NAVIGATION', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
          ),
          const SizedBox(height: 16),
          _buildSliderButton(index: 0, label: 'Ledger Book', icon: Icons.menu_book_rounded, isDark: isDark),
          _buildSliderButton(index: 1, label: 'History Flow', icon: Icons.history_toggle_off_rounded, isDark: isDark),
          _buildSliderButton(index: 2, label: 'Control Desk', icon: Icons.settings_suggest_rounded, isDark: isDark),
          const Spacer(),
          if (_currentIndex == 0) ...[
            Divider(color: borderColor, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CUSTOMER FILTERS', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
                      InkWell(
                        onTap: () => _openCustomFilterModal(context),
                        child: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 18),
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildWebFilterTile('all', 'All Accounts', isDark, textColor),
                  _buildWebFilterTile('500', '₹500+ Credit Limit', isDark, textColor),
                  _buildWebFilterTile('1000', '₹1000+ Credit Limit', isDark, textColor),
                  if (_selectedFilter == 'custom')
                    _buildWebFilterTile('custom', 'Custom: ₹${_customMinFilter?.toStringAsFixed(0)}+', isDark, textColor),
                ],
              ),
            )
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildSliderButton({required int index, required String label, required IconData icon, required bool isDark}) {
    bool isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0066CC).withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))] : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), size: 22),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebFilterTile(String filterType, String label, bool isDark, Color textColor) {
    bool isSelected = _selectedFilter == filterType;
    return InkWell(
      onTap: () {
        if (filterType == 'custom' && _customMinFilter == null) {
          _openCustomFilterModal(context);
        } else {
          setState(() => _selectedFilter = filterType);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildMainContentPanel(String operatorUid, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildCustomerTab(operatorUid, isDesktop, isDark, textColor, cardBgColor, borderColor),
        _buildTransactionHistoryView(operatorUid, isDark, textColor, cardBgColor, borderColor),
        _buildSettingsControlPanel(isDark, textColor, cardBgColor, borderColor),
      ],
    );
  }

  Widget _buildCustomerTab(String operatorUid, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: cardBgColor,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or balance amount threshold...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
                  filled: true,
                  fillColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All Accounts', isDark, textColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('500', '₹500+ Credit', isDark, textColor),
                      const SizedBox(width: 8),
                      _buildFilterChip('1000', '₹1000+ Credit', isDark, textColor),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _openCustomFilterModal(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 20),
                        ),
                      )
                    ],
                  ),
                )
              ]
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('customers').where('operatorUid', isEqualTo: operatorUid).where('isArchived', isEqualTo: _showArchived).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No active merchant nodes deployed.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
              }

              var docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final phone = (data['phone'] ?? '').toString();
                final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;

                double? queriedAmountThreshold = double.tryParse(_searchQuery);
                bool matchesSearch = queriedAmountThreshold != null ? balance.abs() >= queriedAmountThreshold : (name.contains(_searchQuery) || phone.contains(_searchQuery));

                bool matchesFilter = true;
                if (_selectedFilter == '500') matchesFilter = balance >= 500;
                if (_selectedFilter == '1000') matchesFilter = balance >= 1000;
                if (_selectedFilter == 'custom' && _customMinFilter != null) matchesFilter = balance >= _customMinFilter!;

                return matchesSearch && matchesFilter;
              }).toList();

              if (docs.isEmpty) {
                return Center(child: Text('No matching accounts found for the current query framework.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) => _buildCustomerRowCard(docs[index], isDark, textColor, cardBgColor, borderColor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRowCard(QueryDocumentSnapshot doc, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    final data = doc.data() as Map<String, dynamic>;
    final double balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
    final String customerId = doc.id;
    final String customerName = data['name'] ?? 'Merchant';

    bool isArchiving = _isButtonLoading('arch_$customerId');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 1.5)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerLedgerScreen(
                customerId: customerId,
                customerName: customerName,
                customerPhone: data['phone'] ?? '',
                customerAddress: data['address'] ?? 'No Address Listed',
              ),
            ),
          );
        },
        title: Text(customerName, style: TextStyle(color: textColor, fontWeight: FontWeight.w900)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('+91 ${data['phone'] ?? ""}', style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.bold)),
            Text(data['address'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600)),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 2,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('+₹${balance.abs().toStringAsFixed(2)}', style: TextStyle(color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 15)),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 18),
              onPressed: () => _launchWhatsApp(data['phone'] ?? '', customerName),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 18),
              tooltip: 'Edit Customer Info',
              onPressed: () => _openEditCustomerModal(context, customerId, data),
            ),
            IconButton(
              icon: isArchiving 
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                  : Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.amber, size: 18),
              onPressed: () async {
                _setButtonLoading('arch_$customerId', true);
                await Future.delayed(const Duration(seconds: 2)); // ⌛ 2 Sec Loading
                await FirebaseFirestore.instance.collection('customers').doc(customerId).update({'isArchived': !_showArchived});
                _setButtonLoading('arch_$customerId', false);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
              onPressed: () => _openSecureDeleteDialog(context, customerId, customerName),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryView(String operatorUid, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').where('operatorUid', isEqualTo: operatorUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No verified transaction logs archived yet.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tx = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final amt = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
            return Card(
              color: cardBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: borderColor)),
              child: ListTile(
                title: Text(tx['productName'] ?? 'Item Record Entry', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)),
                subtitle: Text('Merchant: ${tx['customerName']} | Qty: ${tx['quantity']}\nCommitment Note: ${tx['commitMessage'] ?? 'None'}', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontSize: 12)),
                isThreeLine: true,
                trailing: Text('₹${amt.toStringAsFixed(2)}', style: TextStyle(color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 14)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsControlPanel(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    final currentTheme = ref.watch(themeModeProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text('SYSTEM THEME CONFIGURATION CANVAS', style: TextStyle(fontWeight: FontWeight.w900, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, letterSpacing: 1.0, fontSize: 11)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor, width: 1.5)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: currentTheme,
              dropdownColor: cardBgColor,
              icon: const Icon(Icons.palette_rounded, color: Color(0xFF38BDF8)),
              isExpanded: true,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 14),
              onChanged: (ThemeMode? val) {
                if (val != null) ref.read(themeModeProvider.notifier).state = val;
              },
              items: [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
                DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme', style: TextStyle(color: textColor, fontWeight: FontWeight.w900))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: cardBgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor, width: 1.5)),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Logout Session', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Terminates current session and redirects to initial splash.', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _performLogout(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                label: const Text('Logout', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterType, String label, bool isDark, Color textColor) {
    bool isSelected = _selectedFilter == filterType;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? Colors.white : textColor)),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedFilter = filterType),
      selectedColor: const Color(0xFF0066CC),
      backgroundColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3))),
    );
  }

  void _openAddNewCustomerModal(BuildContext context, String operatorUid, bool isDark, Color textColor, Color cardBgColor) {
    final formModalKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          bool isAdding = _isButtonLoading('add_customer');

          return AlertDialog(
            backgroundColor: cardBgColor,
            title: Text('Register Enterprise Node Account', style: TextStyle(fontWeight: FontWeight.w900, color: textColor, fontSize: 16)),
            content: Form(
              key: formModalKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController, 
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(labelText: 'Customer Legal Full Name *', labelStyle: TextStyle(fontSize: 12, color: textColor)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Corporate name parameter mandatory.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: phoneController, 
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: InputDecoration(labelText: 'Mobile Communication Gateway *', prefixText: '+91 ', counterText: '', labelStyle: TextStyle(fontSize: 12, color: textColor)),
                      validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Provide verified 10-digit primary channel.' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: addressController, 
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
                      decoration: InputDecoration(labelText: 'Physical Warehousing/Hub Address *', labelStyle: TextStyle(fontSize: 12, color: textColor)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Logistics physical location entry mandatory.' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: isAdding ? null : () => Navigator.pop(context), child: Text('Abort Session', style: TextStyle(fontWeight: FontWeight.w900, color: textColor))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: isAdding ? null : () async {
                  if (formModalKey.currentState!.validate()) {
                    setModalState(() => _setButtonLoading('add_customer', true));
                    await Future.delayed(const Duration(seconds: 2)); // ⌛ 2 Sec Loading
                    await FirebaseFirestore.instance.collection('customers').add({
                      'operatorUid': operatorUid,
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                      'address': addressController.text.trim(),
                      'balance': 0.0,
                      'isArchived': false,
                    });
                    _setButtonLoading('add_customer', false);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: isAdding
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Commit Entry', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              )
            ],
          );
        },
      ),
    );
  }
}