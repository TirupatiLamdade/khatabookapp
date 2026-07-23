
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:intl/intl.dart';
// import '../../../core/providers/global_provider_hub.dart';
// import '../customer/ledger_screen.dart';
// import '../customer/recycle_bin_screen.dart';
// import '../customer/history_screen.dart'; // 👈 Added HistoryScreen import
// import '../profile/profile_screen.dart';
// import '../setting/setting_screen.dart';
// import '../../widgets/customer_dialogs.dart';
// import 'dashboard_overview_tab.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends ConsumerState<HomeScreen> {
//   int _currentIndex = 0;
//   final _searchController = TextEditingController();
//   String _searchQuery = '';
//   String _selectedFilter = 'all';
//   double? _customMinFilter;
//   bool _showArchived = false;

//   final Map<String, bool> _buttonLoadingState = {};

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _setButtonLoading(String id, bool loading) {
//     if (mounted) {
//       setState(() {
//         _buttonLoadingState[id] = loading;
//       });
//     }
//   }

//   bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

//   void _launchWhatsApp(String phone, String name) async {
//     final message = "Hello $name, your business ledger account update has been logged. Please review your balance sheets.";
//     final url = "https://wa.me/91$phone?text=${Uri.encodeComponent(message)}";
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'WhatsApp dispatch initiated for $name');
//       }
//     } else {
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Could not launch WhatsApp client', isError: true);
//       }
//     }
//   }

//   // 🗑️ MOVE CUSTOMER & TRANSACTIONS TO RECYCLE BIN / HISTORY
//   Future<void> _archiveCustomerToHistory(String customerId, String customerName, String operatorUid, Map<String, dynamic> customerData) async {
//     _setButtonLoading('del_$customerId', true);
//     try {
//       final txSnapshot = await FirebaseFirestore.instance
//           .collection('transactions')
//           .where('operatorUid', isEqualTo: operatorUid)
//           .where('customerId', isEqualTo: customerId)
//           .get();

//       List<Map<String, dynamic>> txList = txSnapshot.docs.map((d) => d.data()).toList();

//       await FirebaseFirestore.instance.collection('deleted_customers_history').doc(customerId).set({
//         ...customerData,
//         'deletedAt': FieldValue.serverTimestamp(),
//         'deletedAtIso': DateTime.now().toIso8601String(),
//         'archivedTransactions': txList,
//       });

//       await FirebaseFirestore.instance.collection('customers').doc(customerId).delete();
//       for (var doc in txSnapshot.docs) {
//         await doc.reference.delete();
//       }

//       _setButtonLoading('del_$customerId', false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, '$customerName moved to Recycle Bin successfully!');
//       }
//     } catch (e) {
//       _setButtonLoading('del_$customerId', false);
//       if (mounted) {
//         CustomerDialogs.showTopNotification(context, 'Failed to archive customer record!', isError: true);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     final isDesktop = size.width > 1024;
//     final currentUser = FirebaseAuth.instance.currentUser;

//     if (currentUser == null) {
//       return const Scaffold(
//         backgroundColor: Colors.black,
//         body: Center(child: Text('Unauthorized Session Request.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))),
//       );
//     }

//     final currentTheme = ref.watch(themeModeProvider);
//     final isDark = currentTheme == ThemeMode.dark || (currentTheme == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

//     final bgColor = isDark ? Colors.black : const Color(0xFFF8FAFC);
//     final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
//     final cardBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
//     final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: cardBgColor,
//         elevation: 0,
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
//               child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 24),
//             ),
//             const SizedBox(width: 14),
//             Text('Smart Ledger System', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor, letterSpacing: 0.5)),
//           ],
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete_sweep_rounded, color: Colors.amber),
//             onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen())),
//             tooltip: 'View Recycle Bin & Deleted History',
//           ),
//           IconButton(
//             icon: Icon(_showArchived ? Icons.archive_rounded : Icons.archive_outlined, color: _showArchived ? const Color(0xFF38BDF8) : Colors.grey),
//             onPressed: () {
//               setState(() => _showArchived = !_showArchived);
//               CustomerDialogs.showTopNotification(context, _showArchived ? 'Displaying Archived Accounts' : 'Displaying Active Ledger Accounts');
//             },
//             tooltip: 'View Archived Node Accounts',
//           ),
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: IconButton(
//               icon: const Icon(Icons.storefront_rounded, color: Color(0xFF38BDF8)),
//               tooltip: 'Shop Profile Management',
//               onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
//             ),
//           ),
//         ],
//         shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
//       ),
//       body: isDesktop
//           ? Row(
//               children: [
//                 _buildWebVerticalSlider(isDark, textColor, cardBgColor, borderColor),
//                 Expanded(child: _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor)),
//               ],
//             )
//           : _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor),
//       floatingActionButton: _currentIndex == 1
//           ? FloatingActionButton.extended(
//               onPressed: () => CustomerDialogs.openAddNewCustomerModal(
//                 context: context,
//                 operatorUid: currentUser.uid,
//                 textColor: textColor,
//                 cardBgColor: cardBgColor,
//                 isButtonLoading: _isButtonLoading,
//                 setButtonLoading: _setButtonLoading,
//               ),
//               backgroundColor: const Color(0xFF10B981),
//               elevation: 4,
//               icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
//               label: const Text('Add New Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
//             )
//           : null,
//       bottomNavigationBar: isDesktop
//           ? null
//           : BottomNavigationBar(
//               currentIndex: _currentIndex,
//               onTap: (index) {
//                 if (_currentIndex != index) {
//                   setState(() => _currentIndex = index);
//                 }
//               },
//               backgroundColor: cardBgColor,
//               selectedItemColor: const Color(0xFF38BDF8),
//               unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
//               selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
//               unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//               type: BottomNavigationBarType.fixed,
//               enableFeedback: true,
//               items: const [
//                 BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
//                 BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Ledger Book'),
//                 BottomNavigationBarItem(icon: Icon(Icons.history_toggle_off_rounded), label: 'History Flow'),
//                 BottomNavigationBarItem(icon: Icon(Icons.settings_suggest_rounded), label: 'Control Desk'),
//               ],
//             ),
//     );
//   }

//   Widget _buildWebVerticalSlider(bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
//     return Container(
//       width: 280,
//       decoration: BoxDecoration(color: cardBgColor, border: Border(right: BorderSide(color: borderColor, width: 1.5))),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const SizedBox(height: 24),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24),
//             child: Text('WORKSPACE NAVIGATION', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
//           ),
//           const SizedBox(height: 16),
//           _buildSliderButton(index: 0, label: 'Dashboard Home', icon: Icons.grid_view_rounded, isDark: isDark, textColor: textColor),
//           _buildSliderButton(index: 1, label: 'Ledger Book', icon: Icons.menu_book_rounded, isDark: isDark, textColor: textColor),
//           _buildSliderButton(index: 2, label: 'History Flow', icon: Icons.history_toggle_off_rounded, isDark: isDark, textColor: textColor),
//           _buildSliderButton(index: 3, label: 'Control Desk', icon: Icons.settings_suggest_rounded, isDark: isDark, textColor: textColor),
//           const Spacer(),
//           if (_currentIndex == 1) ...[
//             Divider(color: borderColor, height: 1),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('CUSTOMER FILTERS', style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2)),
//                       InkWell(
//                         onTap: () => CustomerDialogs.openCustomFilterModal(
//                           context: context,
//                           customMinFilter: _customMinFilter,
//                           onFilterApplied: (filter, minVal) {
//                             setState(() {
//                               _selectedFilter = filter;
//                               _customMinFilter = minVal;
//                             });
//                           },
//                         ),
//                         child: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 18),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   _buildWebFilterTile('all', 'All Accounts', isDark, textColor),
//                   _buildWebFilterTile('500', '₹500+ Credit Limit', isDark, textColor),
//                   _buildWebFilterTile('1000', '₹1000+ Credit Limit', isDark, textColor),
//                   if (_selectedFilter == 'custom')
//                     _buildWebFilterTile('custom', 'Custom: ₹${_customMinFilter?.toStringAsFixed(0)}+', isDark, textColor),
//                 ],
//               ),
//             )
//           ],
//           const SizedBox(height: 12),
//         ],
//       ),
//     );
//   }

//   Widget _buildSliderButton({required int index, required String label, required IconData icon, required bool isDark, required Color textColor}) {
//     bool isSelected = _currentIndex == index;
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: InkWell(
//         onTap: () {
//           if (_currentIndex != index) {
//             setState(() => _currentIndex = index);
//           }
//         },
//         borderRadius: BorderRadius.circular(14),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           decoration: BoxDecoration(
//             gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
//             borderRadius: BorderRadius.circular(14),
//             boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0066CC).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), size: 20),
//               const SizedBox(width: 14),
//               Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 13.5)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildWebFilterTile(String filterType, String label, bool isDark, Color textColor) {
//     bool isSelected = _selectedFilter == filterType;
//     return InkWell(
//       onTap: () {
//         if (filterType == 'custom' && _customMinFilter == null) {
//           CustomerDialogs.openCustomFilterModal(
//             context: context,
//             customMinFilter: _customMinFilter,
//             onFilterApplied: (filter, minVal) {
//               setState(() {
//                 _selectedFilter = filter;
//                 _customMinFilter = minVal;
//               });
//             },
//           );
//         } else {
//           setState(() => _selectedFilter = filterType);
//         }
//       },
//       borderRadius: BorderRadius.circular(10),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
//         margin: const EdgeInsets.only(bottom: 6),
//         decoration: BoxDecoration(
//           gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 12.5)),
//       ),
//     );
//   }

//   Widget _buildMainContentPanel(String operatorUid, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
//     return IndexedStack(
//       index: _currentIndex,
//       children: [
//         DashboardOverviewTab(
//           operatorUid: operatorUid,
//           isDark: isDark,
//           textColor: textColor,
//           cardBgColor: cardBgColor,
//           borderColor: borderColor,
//         ),
//         _buildCustomerTab(operatorUid, isDesktop, isDark, textColor, cardBgColor, borderColor),
//         const HistoryScreen(), // 👈 History Flow Tab now directly loads HistoryScreen
//         SettingsControlPanel(isDark: isDark, textColor: textColor, cardBgColor: cardBgColor, borderColor: borderColor),
//       ],
//     );
//   }

//   Widget _buildCustomerTab(String operatorUid, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(16),
//           color: cardBgColor,
//           child: Column(
//             children: [
//               TextField(
//                 controller: _searchController,
//                 style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
//                 decoration: InputDecoration(
//                   hintText: 'Search by name, phone (+91), or amount...',
//                   hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold),
//                   prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: const Icon(Icons.clear, size: 18),
//                           onPressed: () {
//                             _searchController.clear();
//                             setState(() => _searchQuery = '');
//                           },
//                         )
//                       : null,
//                   filled: true,
//                   fillColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                 ),
//                 onChanged: (val) {
//                   setState(() => _searchQuery = val.trim().toLowerCase());
//                 },
//               ),
//               if (!isDesktop) ...[
//                 const SizedBox(height: 12),
//                 SingleChildScrollView(
//                   scrollDirection: Axis.horizontal,
//                   child: Row(
//                     children: [
//                       _buildFilterChip('all', 'All Accounts', isDark, textColor),
//                       const SizedBox(width: 8),
//                       _buildFilterChip('500', '₹500+ Credit', isDark, textColor),
//                       const SizedBox(width: 8),
//                       _buildFilterChip('1000', '₹1000+ Credit', isDark, textColor),
//                       const SizedBox(width: 8),
//                       InkWell(
//                         onTap: () => CustomerDialogs.openCustomFilterModal(
//                           context: context,
//                           customMinFilter: _customMinFilter,
//                           onFilterApplied: (filter, minVal) {
//                             setState(() {
//                               _selectedFilter = filter;
//                               _customMinFilter = minVal;
//                             });
//                           },
//                         ),
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                           decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
//                           child: const Icon(Icons.tune_rounded, color: Color(0xFF38BDF8), size: 20),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               ]
//             ],
//           ),
//         ),
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('customers')
//                 .where('operatorUid', isEqualTo: operatorUid)
//                 .where('isArchived', isEqualTo: _showArchived)
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Center(child: Text('No active merchant nodes deployed.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
//               }

//               var docs = snapshot.data!.docs.where((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final name = (data['name'] ?? '').toString().toLowerCase();
//                 final phone = (data['phone'] ?? '').toString().toLowerCase();
//                 final balanceDouble = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
//                 final balanceString = balanceDouble.abs().toStringAsFixed(2);

//                 bool matchesSearch = _searchQuery.isEmpty ||
//                     name.contains(_searchQuery) ||
//                     phone.contains(_searchQuery) ||
//                     balanceString.contains(_searchQuery);

//                 bool matchesFilter = true;
//                 if (_selectedFilter == '500') matchesFilter = balanceDouble.abs() >= 500;
//                 if (_selectedFilter == '1000') matchesFilter = balanceDouble.abs() >= 1000;
//                 if (_selectedFilter == 'custom' && _customMinFilter != null) matchesFilter = balanceDouble.abs() >= _customMinFilter!;

//                 return matchesSearch && matchesFilter;
//               }).toList();

//               if (docs.isEmpty) {
//                 return Center(child: Text('No matching accounts found for search query.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
//               }

//               return ListView.builder(
//                 key: const PageStorageKey<String>('smooth_customer_list_view'),
//                 physics: const BouncingScrollPhysics(),
//                 cacheExtent: 500, // ⚡ Performance optimization for smooth scrolling
//                 padding: const EdgeInsets.all(16),
//                 itemCount: docs.length,
//                 itemBuilder: (context, index) => _buildCustomerRowCard(docs[index], operatorUid, isDark, textColor, cardBgColor, borderColor),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCustomerRowCard(QueryDocumentSnapshot doc, String operatorUid, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
//     final data = doc.data() as Map<String, dynamic>;
//     final double balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
//     final String customerId = doc.id;
//     final String customerName = data['name'] ?? 'Merchant';

//     final Timestamp? timestamp = data['createdAt'] as Timestamp?;
//     final DateTime admitDate = timestamp != null ? timestamp.toDate() : DateTime.now();
//     final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(admitDate);

//     bool isArchiving = _isButtonLoading('arch_$customerId');
//     bool isDeleting = _isButtonLoading('del_$customerId');

//     return RepaintBoundary(
//       key: ValueKey('cust_$customerId'),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: cardBgColor,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: borderColor, width: 1.5),
//         ),
//         child: ListTile(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) => CustomerLedgerScreen(
//                   customerId: customerId,
//                   customerName: customerName,
//                   customerPhone: data['phone'] ?? '',
//                   customerAddress: data['address'] ?? 'No Address Listed',
//                 ),
//               ),
//             );
//           },
//           title: Text(
//             customerName,
//             style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           subtitle: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 '+91 ${data['phone'] ?? ""}',
//                 style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.bold),
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               if ((data['address'] ?? "").toString().isNotEmpty)
//                 Text(
//                   data['address'] ?? "",
//                   style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   Icon(Icons.access_time_rounded, size: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
//                   const SizedBox(width: 4),
//                   Text(
//                     'Added: $formattedDate',
//                     style: TextStyle(
//                       color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           isThreeLine: true,
//           trailing: Wrap(
//             spacing: 2,
//             alignment: WrapAlignment.center,
//             crossAxisAlignment: WrapCrossAlignment.center,
//             children: [
//               Text(
//                 '+₹${balance.abs().toStringAsFixed(2)}',
//                 style: TextStyle(
//                   color: balance >= 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//                   fontWeight: FontWeight.w900,
//                   fontSize: 15,
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 18),
//                 onPressed: () => _launchWhatsApp(data['phone'] ?? '', customerName),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 18),
//                 tooltip: 'Edit Customer Info',
//                 onPressed: () => CustomerDialogs.openEditCustomerModal(
//                   context: context,
//                   customerId: customerId,
//                   currentData: data,
//                   isButtonLoading: _isButtonLoading,
//                   setButtonLoading: _setButtonLoading,
//                 ),
//               ),
//               IconButton(
//                 icon: isArchiving
//                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
//                     : Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.amber, size: 18),
//                 onPressed: () async {
//                   _setButtonLoading('arch_$customerId', true);
//                   await FirebaseFirestore.instance.collection('customers').doc(customerId).update({'isArchived': !_showArchived});
//                   _setButtonLoading('arch_$customerId', false);
//                   if (mounted) {
//                     CustomerDialogs.showTopNotification(context, _showArchived ? 'Restored $customerName to active ledger!' : 'Archived $customerName!');
//                   }
//                 },
//               ),
//               IconButton(
//                 icon: isDeleting
//                     ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
//                     : const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
//                 onPressed: () async {
//                   bool confirm = await CustomerDialogs.openSecureDeleteDialog(
//                     context: context,
//                     customerId: customerId,
//                     customerName: customerName,
//                     isButtonLoading: _isButtonLoading,
//                     setButtonLoading: _setButtonLoading,
//                   );

//                   if (confirm) {
//                     await _archiveCustomerToHistory(customerId, customerName, operatorUid, data);
//                   }
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChip(String filterType, String label, bool isDark, Color textColor) {
//     bool isSelected = _selectedFilter == filterType;
//     return ChoiceChip(
//       label: Text(label, style: TextStyle(fontWeight: FontWeight.w900, color: isSelected ? Colors.white : textColor)),
//       selected: isSelected,
//       onSelected: (val) => setState(() => _selectedFilter = filterType),
//       selectedColor: const Color(0xFF0066CC),
//       backgroundColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
//       showCheckmark: false,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3))),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/global_provider_hub.dart';
import '../customer/ledger_screen.dart';
import '../customer/recycle_bin_screen.dart';
import '../customer/history_screen.dart';
import '../profile/profile_screen.dart';
import '../setting/setting_screen.dart';
import '../../widgets/customer_dialogs.dart';
import '../../widgets/ai_chat_floating_widget.dart';
import 'dashboard_overview_tab.dart';

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

  // 🖐️ FREE DRAGGABLE AI ICON COORDINATES
  Offset _aiPosition = const Offset(20, 85); // Default initial placement

  final Map<String, bool> _buttonLoadingState = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setButtonLoading(String id, bool loading) {
    if (mounted) {
      setState(() {
        _buttonLoadingState[id] = loading;
      });
    }
  }

  bool _isButtonLoading(String id) => _buttonLoadingState[id] ?? false;

  void _launchWhatsApp(String phone, String name) async {
    final message = "Hello $name, your business ledger account update has been logged. Please review your balance sheets.";
    final url = "https://wa.me/91$phone?text=${Uri.encodeComponent(message)}";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'WhatsApp dispatch initiated for $name');
      }
    } else {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Could not launch WhatsApp client', isError: true);
      }
    }
  }

  // 🗑️ MOVE CUSTOMER & TRANSACTIONS TO RECYCLE BIN / HISTORY
  Future<void> _archiveCustomerToHistory(String customerId, String customerName, String operatorUid, Map<String, dynamic> customerData) async {
    _setButtonLoading('del_$customerId', true);
    try {
      final txSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('operatorUid', isEqualTo: operatorUid)
          .where('customerId', isEqualTo: customerId)
          .get();

      List<Map<String, dynamic>> txList = txSnapshot.docs.map((d) => d.data()).toList();

      await FirebaseFirestore.instance.collection('deleted_customers_history').doc(customerId).set({
        ...customerData,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedAtIso': DateTime.now().toIso8601String(),
        'archivedTransactions': txList,
      });

      await FirebaseFirestore.instance.collection('customers').doc(customerId).delete();
      for (var doc in txSnapshot.docs) {
        await doc.reference.delete();
      }

      _setButtonLoading('del_$customerId', false);
      if (mounted) {
        CustomerDialogs.showTopNotification(context, '$customerName moved to Recycle Bin successfully!');
      }
    } catch (e) {
      _setButtonLoading('del_$customerId', false);
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to archive customer record!', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 1024;
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Unauthorized Session Request.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      );
    }

    final currentTheme = ref.watch(themeModeProvider);
    final isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system && MediaQuery.of(context).platformBrightness == Brightness.dark);

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
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 24),
            ),
            const SizedBox(width: 14),
            Text(
              'Smart Ledger System',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: textColor, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.amber),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen())),
            tooltip: 'View Recycle Bin & Deleted History',
          ),
          IconButton(
            icon: Icon(_showArchived ? Icons.archive_rounded : Icons.archive_outlined, color: _showArchived ? const Color(0xFF38BDF8) : Colors.grey),
            onPressed: () {
              setState(() => _showArchived = !_showArchived);
              CustomerDialogs.showTopNotification(context, _showArchived ? 'Displaying Archived Accounts' : 'Displaying Active Ledger Accounts');
            },
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
      body: Stack(
        children: [
          // -------------------------------------------------------------
          // 1️⃣ MAIN WORKSPACE PANEL
          // -------------------------------------------------------------
          isDesktop
              ? Row(
                  children: [
                    _buildWebVerticalSlider(isDark, textColor, cardBgColor, borderColor),
                    Expanded(child: _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor)),
                  ],
                )
              : _buildMainContentPanel(currentUser.uid, isDesktop, isDark, textColor, cardBgColor, borderColor),

          // -------------------------------------------------------------
          // 2️⃣ 🤖 FULLY DRAGGABLE FREE-POSITION AI ICON OVERLAY
          // Allows moving the AI widget freely anywhere across the screen
          // -------------------------------------------------------------
          Positioned(
            right: _aiPosition.dx,
            bottom: _aiPosition.dy,
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  // Drag logic: dynamically adjusts position while constraining within screen boundaries
                  double newDx = _aiPosition.dx - details.delta.dx;
                  double newDy = _aiPosition.dy - details.delta.dy;

                  // Screen safety boundaries calculation
                  if (newDx >= 10 && newDx <= size.width - 70) {
                    _aiPosition = Offset(newDx, _aiPosition.dy);
                  }
                  if (newDy >= 10 && newDy <= size.height - 150) {
                    _aiPosition = Offset(_aiPosition.dx, newDy);
                  }
                });
              },
              child: const AiChatFloatingWidget(),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton.extended(
              onPressed: () => CustomerDialogs.openAddNewCustomerModal(
                context: context,
                operatorUid: currentUser.uid,
                textColor: textColor,
                cardBgColor: cardBgColor,
                isButtonLoading: _isButtonLoading,
                setButtonLoading: _setButtonLoading,
              ),
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
              onTap: (index) {
                if (_currentIndex != index) {
                  setState(() => _currentIndex = index);
                }
              },
              backgroundColor: cardBgColor,
              selectedItemColor: const Color(0xFF38BDF8),
              unselectedItemColor: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
              type: BottomNavigationBarType.fixed,
              enableFeedback: true,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
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
          _buildSliderButton(index: 0, label: 'Dashboard Home', icon: Icons.grid_view_rounded, isDark: isDark, textColor: textColor),
          _buildSliderButton(index: 1, label: 'Ledger Book', icon: Icons.menu_book_rounded, isDark: isDark, textColor: textColor),
          _buildSliderButton(index: 2, label: 'History Flow', icon: Icons.history_toggle_off_rounded, isDark: isDark, textColor: textColor),
          _buildSliderButton(index: 3, label: 'Control Desk', icon: Icons.settings_suggest_rounded, isDark: isDark, textColor: textColor),
          const Spacer(),
          if (_currentIndex == 1) ...[
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
                        onTap: () => CustomerDialogs.openCustomFilterModal(
                          context: context,
                          customMinFilter: _customMinFilter,
                          onFilterApplied: (filter, minVal) {
                            setState(() {
                              _selectedFilter = filter;
                              _customMinFilter = minVal;
                            });
                          },
                        ),
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

  Widget _buildSliderButton({required int index, required String label, required IconData icon, required bool isDark, required Color textColor}) {
    bool isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () {
          if (_currentIndex != index) {
            setState(() => _currentIndex = index);
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF0066CC).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))] : [],
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade600), size: 20),
              const SizedBox(width: 14),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 13.5)),
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
          CustomerDialogs.openCustomFilterModal(
            context: context,
            customMinFilter: _customMinFilter,
            onFilterApplied: (filter, minVal) {
              setState(() {
                _selectedFilter = filter;
                _customMinFilter = minVal;
              });
            },
          );
        } else {
          setState(() => _selectedFilter = filterType);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? const LinearGradient(colors: [Color(0xFF0066CC), Color(0xFF0284C7)]) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : textColor, fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold, fontSize: 12.5)),
      ),
    );
  }

  Widget _buildMainContentPanel(String operatorUid, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    return IndexedStack(
      index: _currentIndex,
      children: [
        DashboardOverviewTab(
          operatorUid: operatorUid,
          isDark: isDark,
          textColor: textColor,
          cardBgColor: cardBgColor,
          borderColor: borderColor,
        ),
        _buildCustomerTab(operatorUid, isDesktop, isDark, textColor, cardBgColor, borderColor),
        const HistoryScreen(),
        SettingsControlPanel(isDark: isDark, textColor: textColor, cardBgColor: cardBgColor, borderColor: borderColor),
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
                  hintText: 'Search by name, phone (+91), or amount...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF38BDF8)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? Colors.black : const Color(0xFFF1F5F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  setState(() => _searchQuery = val.trim().toLowerCase());
                },
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
                        onTap: () => CustomerDialogs.openCustomFilterModal(
                          context: context,
                          customMinFilter: _customMinFilter,
                          onFilterApplied: (filter, minVal) {
                            setState(() {
                              _selectedFilter = filter;
                              _customMinFilter = minVal;
                            });
                          },
                        ),
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
            stream: FirebaseFirestore.instance
                .collection('customers')
                .where('operatorUid', isEqualTo: operatorUid)
                .where('isArchived', isEqualTo: _showArchived)
                .snapshots(),
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
                final phone = (data['phone'] ?? '').toString().toLowerCase();
                final balanceDouble = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
                final balanceString = balanceDouble.abs().toStringAsFixed(2);

                bool matchesSearch = _searchQuery.isEmpty ||
                    name.contains(_searchQuery) ||
                    phone.contains(_searchQuery) ||
                    balanceString.contains(_searchQuery);

                bool matchesFilter = true;
                if (_selectedFilter == '500') matchesFilter = balanceDouble.abs() >= 500;
                if (_selectedFilter == '1000') matchesFilter = balanceDouble.abs() >= 1000;
                if (_selectedFilter == 'custom' && _customMinFilter != null) matchesFilter = balanceDouble.abs() >= _customMinFilter!;

                return matchesSearch && matchesFilter;
              }).toList();

              if (docs.isEmpty) {
                return Center(child: Text('No matching accounts found for search query.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
              }

              return ListView.builder(
                key: const PageStorageKey<String>('smooth_customer_list_view'),
                physics: const BouncingScrollPhysics(),
                cacheExtent: 500,
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 100),
                itemCount: docs.length,
                itemBuilder: (context, index) => _buildCustomerRowCard(docs[index], operatorUid, isDark, textColor, cardBgColor, borderColor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRowCard(QueryDocumentSnapshot doc, String operatorUid, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
    final data = doc.data() as Map<String, dynamic>;
    final double balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;
    final String customerId = doc.id;
    final String customerName = data['name'] ?? 'Merchant';

    final Timestamp? timestamp = data['createdAt'] as Timestamp?;
    final DateTime admitDate = timestamp != null ? timestamp.toDate() : DateTime.now();
    final String formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(admitDate);

    bool isArchiving = _isButtonLoading('arch_$customerId');
    bool isDeleting = _isButtonLoading('del_$customerId');

    return RepaintBoundary(
      key: ValueKey('cust_$customerId'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
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
          title: Text(
            customerName,
            style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+91 ${data['phone'] ?? ""}',
                style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if ((data['address'] ?? "").toString().isNotEmpty)
                Text(
                  data['address'] ?? "",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Added: $formattedDate',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          isThreeLine: true,
          trailing: Wrap(
            spacing: 2,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '+₹${balance.abs().toStringAsFixed(2)}',
                style: TextStyle(
                  color: balance >= 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 18),
                onPressed: () => _launchWhatsApp(data['phone'] ?? '', customerName),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 18),
                tooltip: 'Edit Customer Info',
                onPressed: () => CustomerDialogs.openEditCustomerModal(
                  context: context,
                  customerId: customerId,
                  currentData: data,
                  isButtonLoading: _isButtonLoading,
                  setButtonLoading: _setButtonLoading,
                ),
              ),
              IconButton(
                icon: isArchiving
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                    : Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.amber, size: 18),
                onPressed: () async {
                  _setButtonLoading('arch_$customerId', true);
                  await FirebaseFirestore.instance.collection('customers').doc(customerId).update({'isArchived': !_showArchived});
                  _setButtonLoading('arch_$customerId', false);
                  if (mounted) {
                    CustomerDialogs.showTopNotification(context, _showArchived ? 'Restored $customerName to active ledger!' : 'Archived $customerName!');
                  }
                },
              ),
              IconButton(
                icon: isDeleting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                    : const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                onPressed: () async {
                  bool confirm = await CustomerDialogs.openSecureDeleteDialog(
                    context: context,
                    customerId: customerId,
                    customerName: customerName,
                    isButtonLoading: _isButtonLoading,
                    setButtonLoading: _setButtonLoading,
                  );

                  if (confirm) {
                    await _archiveCustomerToHistory(customerId, customerName, operatorUid, data);
                  }
                },
              ),
            ],
          ),
        ),
      ),
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
}