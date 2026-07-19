import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../customer/ledger_screen.dart';

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
  bool _showArchived = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _launchWhatsApp(String phone, String name) async {
    final message = "Hello $name, your business ledger account update has been logged. Please review your balance sheets.";
    final url = "https://wa.me/91$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0F19),
        body: Center(child: Text('Unauthorized Session Request.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      );
    }

    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark || 
                   (currentTheme == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF4F46E5), size: 24),
            const SizedBox(width: 12),
            Text(
              'Smart Ledger System', 
              style: TextStyle(
                fontWeight:FontWeight.bold, 
                fontSize: 18, 
                color: isDark ? Colors.white : const Color(0xFF0F172A),
                letterSpacing: 0.5
              )
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showArchived ? Icons.archive_rounded : Icons.archive_outlined, 
              color: _showArchived ? const Color(0xFF4F46E5) : Colors.grey
            ),
            onPressed: () => setState(() => _showArchived = !_showArchived),
            tooltip: 'View Archived Node Accounts',
          ),
        ],
        shape: Border(bottom: BorderSide(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0), width: 1)),
      ),
      body: isDesktop 
          ? Row(
              children: [
                _buildWebVerticalSlider(isDark),
                Expanded(
                  child: _buildMainContentPanel(currentUser.uid, isDesktop, isDark),
                ),
              ],
            )
          : _buildMainContentPanel(currentUser.uid, isDesktop, isDark),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _openAddNewCustomerModal(context, currentUser.uid, isDark),
              backgroundColor: const Color(0xFF4F46E5),
              icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
              label: const Text('Add New Customer', style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: isDesktop 
          ? null 
          : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
              selectedItemColor: const Color(0xFF4F46E5),
              unselectedItemColor: isDark ? const Color(0xFF4B5563) : const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight:FontWeight.bold),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Ledger Book'),
                BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off_rounded), label: 'History Flow'),
                BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Control Desk'),
              ],
            ),
    );
  }

  Widget _buildWebVerticalSlider(bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        border: Border(right: BorderSide(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0), width: 1.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'WORKSPACE NAVIGATION', 
              style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontWeight:FontWeight.bold, fontSize: 11, letterSpacing: 0.8)
            ),
          ),
          const SizedBox(height: 16),
          _buildSliderButton(index: 0, label: 'Ledger Book', icon: Icons.menu_book_rounded),
          _buildSliderButton(index: 1, label: 'History Flow', icon: Icons.history_toggle_off_rounded),
          _buildSliderButton(index: 2, label: 'Control Desk', icon: Icons.settings_suggest_rounded),
          const Spacer(),
          if (_currentIndex == 0) ...[
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'CUSTOMER FILTERS', 
                    style: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade600, fontWeight:FontWeight.bold, fontSize: 11, letterSpacing: 0.8)
                  ),
                  const SizedBox(height: 12),
                  _buildWebFilterTile('all', 'All Accounts', isDark),
                  _buildWebFilterTile('500', '₹500+ Credit Limit', isDark),
                  _buildWebFilterTile('1000', '₹1000+ Credit Limit', isDark),
                ],
              ),
            )
          ]
        ],
      ),
    );
  }

  // 🌟 ULTRA-BOLD PILL SHAPED DYNAMIC ACTION TRACKER
  Widget _buildSliderButton({required int index, required String label, required IconData icon}) {
    bool isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: () => setState(() => _currentIndex = index),
        dense: false,
        selected: isSelected,
        selectedTileColor: const Color(0xFF4F46E5), 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), 
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(
          icon, 
          color: isSelected ? Colors.white : const Color(0xFF64748B), 
          size: 22
        ),
        title: Text(
          label, 
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF334155), 
            fontWeight:FontWeight.bold, 
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildWebFilterTile(String filterType, String label, bool isDark) {
    bool isSelected = _selectedFilter == filterType;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = filterType),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF0F172A)),
            fontWeight:FontWeight.bold,
            fontSize: 13
          ),
        ),
      ),
    );
  }

  Widget _buildMainContentPanel(String operatorUid, bool isDesktop, bool isDark) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        _buildCustomerTab(operatorUid, isDesktop, isDark),
        _buildTransactionHistoryView(operatorUid, isDark),
        _buildSettingsControlPanel(isDark),
      ],
    );
  }

  Widget _buildCustomerTab(String operatorUid, bool isDesktop, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: isDark ? const Color(0xFF111827) : Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: 'Search by name, phone, or balance amount threshold (e.g. 10000)...',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5)),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
              if (!isDesktop) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFilterChip('all', 'All Accounts', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('500', '₹500+ Credit', isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('1000', '₹1000+ Credit', isDark),
                  ],
                )
              ]
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('customers')
                .where('operatorUid', isEqualTo: operatorUid)
                .where('isArchived', isEqualTo: _showArchived)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No active merchant nodes deployed.',
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF0F172A), fontWeight:FontWeight.bold)
                  )
                );
              }

              var docs = snapshot.data!.docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                final phone = (data['phone'] ?? '').toString();
                final balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;

                double? queriedAmountThreshold = double.tryParse(_searchQuery);
                
                bool matchesSearch = false;
                if (queriedAmountThreshold != null) {
                  matchesSearch = balance.abs() >= queriedAmountThreshold;
                } else {
                  matchesSearch = name.contains(_searchQuery) || phone.contains(_searchQuery);
                }

                bool matchesFilter = true;
                if (_selectedFilter == '500') matchesFilter = balance >= 500;
                if (_selectedFilter == '1000') matchesFilter = balance >= 1000;

                return matchesSearch && matchesFilter;
              }).toList();

              if (docs.isEmpty) {
                return Center(
                  child: Text(
                    'No matching accounts found for the current query framework.',
                    style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF0F172A), fontWeight:FontWeight.bold)
                  )
                );
              }

              return isDesktop ? _buildGridSystem(docs, isDark) : _buildStackedList(docs, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGridSystem(List<QueryDocumentSnapshot> docs, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 20, mainAxisSpacing: 16, childAspectRatio: 3.2,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildCustomerRowCard(docs[index], isDark),
    );
  }

  Widget _buildStackedList(List<QueryDocumentSnapshot> docs, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      itemBuilder: (context, index) => _buildCustomerRowCard(docs[index], isDark),
    );
  }

  Widget _buildCustomerRowCard(QueryDocumentSnapshot doc, bool isDark) {
    final data = doc.data() as Map<String, dynamic>;
    final double balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
    final String customerId = doc.id;

    final double absoluteCardVal = balance.abs();
    final String formattedCardBalance = '+₹${absoluteCardVal.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerLedgerScreen(
                customerId: customerId,
                customerName: data['name'] ?? 'Merchant',
                customerPhone: data['phone'] ?? '',
                customerAddress: data['address'] ?? 'No Address Listed',
              ),
            ),
          );
        },
        title: Text(
          data['name'] ?? 'Anonymous Entity', 
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight:FontWeight.bold)
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('+91 ${data['phone'] ?? ""}', style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
            Text(data['address'] ?? "", style: TextStyle(color: Colors.grey.shade500, fontSize: 11, overflow: TextOverflow.ellipsis)),
          ],
        ),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 2,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              formattedCardBalance, 
              style: TextStyle(color: balance >= 0 ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 15)
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 18),
              onPressed: () => _launchWhatsApp(data['phone'] ?? '', data['name'] ?? ''),
            ),
            IconButton(
              icon: Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.amber, size: 18),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('customers').doc(customerId).update({
                  'isArchived': !_showArchived,
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('customers').doc(customerId).delete();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistoryView(String operatorUid, bool isDark) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('operatorUid', isEqualTo: operatorUid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No verified transaction logs archived yet.',
              style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF0F172A), fontWeight:FontWeight.bold)
            )
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final tx = snapshot.data!.docs[index].data() as Map<String, dynamic>;
            final amt = double.tryParse(tx['totalPrice']?.toString() ?? '0.0') ?? 0.0;
            return Card(
              color: isDark ? const Color(0xFF111827) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0))
              ),
              child: ListTile(
                title: Text(
                  tx['productName'] ?? 'Item Record Entry', 
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight:FontWeight.bold)
                ),
                subtitle: Text(
                  'Merchant: ${tx['customerName']} | Qty: ${tx['quantity']}\nCommitment Note: ${tx['commitMessage'] ?? 'None'}',
                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey, fontSize: 12)
                ),
                isThreeLine: true,
                trailing: Text(
                  '₹${amt.toStringAsFixed(2)}', 
                  style: TextStyle(color: tx['type'] == 'credit' ? const Color(0xFFEF4444) : const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsControlPanel(bool isDark) {
    final currentTheme = ref.watch(themeModeProvider);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('SYSTEM THEME CONFIGURATION CANVAS', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111827) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? const Color(0xFF1F2937) : const Color(0xFFE2E8F0), width: 1.5)
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<ThemeMode>(
              value: currentTheme,
              dropdownColor: isDark ? const Color(0xFF111827) : Colors.white,
              icon: const Icon(Icons.palette_rounded, color: Color(0xFF4F46E5)),
              isExpanded: true,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight:FontWeight.bold, fontSize: 14),
              onChanged: (ThemeMode? val) {
                if (val != null) {
                  ref.read(themeModeProvider.notifier).state = val;
                }
              },
              items: const [
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Activate Dark Slate System Profile')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Activate Light Clean System Profile')),
                DropdownMenuItem(value: ThemeMode.system, child: Text('Synchronize Local Operating System Theme')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String filterType, String label, bool isDark) {
    bool isSelected = _selectedFilter == filterType;
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontWeight:FontWeight.bold, color: isSelected ? Colors.white : (isDark ? Colors.white70 : const Color(0xFF0F172A)))),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedFilter = filterType),
      selectedColor: const Color(0xFF4F46E5),
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF1F5F9),
      showCheckmark: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), 
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3)),
      ),
    );
  }

  void _openAddNewCustomerModal(BuildContext context, String operatorUid, bool isDark) {
    final _formModalKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF111827) : Colors.white,
        title: Text('Register Enterprise Node Account', style: TextStyle(fontWeight:FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 16)),
        content: Form(
          key: _formModalKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController, 
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(labelText: 'Customer Legal Full Name *', labelStyle: TextStyle(fontSize: 12)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Corporate name parameter mandatory.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: phoneController, 
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile Communication Gateway *', prefixText: '+91 ', labelStyle: TextStyle(fontSize: 12)),
                  validator: (v) => (v == null || v.isEmpty || v.length != 10) ? 'Provide verified 10-digit primary channel.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: addressController, 
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(labelText: 'Physical Warehousing/Hub Address *', labelStyle: TextStyle(fontSize: 12)),
                  validator: (v) => (v == null || v.isEmpty) ? 'Logistics physical location entry mandatory.' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Abort Session', style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
            onPressed: () async {
              if (_formModalKey.currentState!.validate()) {
                await FirebaseFirestore.instance.collection('customers').add({
                  'operatorUid': operatorUid,
                  'name': nameController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'address': addressController.text.trim(),
                  'balance': 0.0,
                  'isArchived': false,
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Commit Entry', style: TextStyle(color: Colors.white, fontWeight:FontWeight.bold)),
          )
        ],
      ),
    );
  }
}