
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
import '../shop/shop_management_screen.dart'; 
import '../../widgets/customer_dialogs.dart';
import '../../widgets/ai_chat_floating_widget.dart';
import 'dashboard_overview_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  double? _customMinFilter;
  bool _showArchived = false;

  // 🔔 Persistent Notification Side Panel & Filter State
  bool _isNotificationOpen = false;
  String _notificationTabFilter = 'unread'; // 'unread', 'read'
  late AnimationController _bellAnimationController;

  Offset _aiPosition = const Offset(20, 85);
  final Map<String, bool> _buttonLoadingState = {};

  @override
  void initState() {
    super.initState();
    _bellAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowWelcomeDialog();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bellAnimationController.dispose();
    super.dispose();
  }

  // 🔔 LOG NOTIFICATION TO FIRESTORE
  Future<void> _addNotification({
    required String title,
    required String body,
    required String type, // 'add', 'edit', 'delete'
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('notifications').add({
        'operatorUid': user.uid,
        'title': title,
        'body': body,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      _triggerBellVibration();
    } catch (_) {}
  }

  void _triggerBellVibration() {
    if (mounted) {
      _bellAnimationController.forward(from: 0.0).then((_) {
        _bellAnimationController.reverse();
      });
    }
  }

  // 🎉 FIRST TIME LOGIN DIALOG
  Future<void> _checkAndShowWelcomeDialog() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && (doc.data()?['isFirstTime'] ?? false) == true) {
        if (!mounted) return;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
            elevation: 10,
            child: Container(
              padding: const EdgeInsets.all(24),
              constraints: const BoxConstraints(maxWidth: 380),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Congratulations! 🎉',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Successfully logged in to Khatabook App!',
                    style: TextStyle(
                      color: isDark ? const Color(0xFF94A3B8) : Colors.grey.shade600,
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066CC),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 2,
                      ),
                      onPressed: () async {
                        Navigator.of(dialogCtx).pop();
                        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                          'isFirstTime': false,
                        });
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    } catch (_) {}
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

      await _addNotification(
        title: 'Customer Deleted',
        body: 'Danger Alert: Customer $customerName was removed and archived.',
        type: 'delete',
      );

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

  // 🗺️ ROUTE NAVIGATION MAP POPUP
  void _showRouteMapPopup(BuildContext context, String customerId, Map<String, dynamic> customerData, bool isDark) {
    final String name = customerData['name'] ?? 'Customer';
    final String address = customerData['address'] ?? '';

    final Color dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: dialogBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.navigation_rounded, color: Color(0xFF38BDF8), size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Live Navigation Route',
                        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: subTextColor, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.my_location_rounded, color: Color(0xFF10B981), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your Current Location',
                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4, bottom: 4),
                      child: Row(
                        children: [
                          Container(width: 2, height: 16, color: const Color(0xFF38BDF8)),
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$name\'s Location:',
                                style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                address.isNotEmpty ? address : 'No address specified for this customer.',
                                style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: const DecorationImage(
                    image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=India&zoom=4&size=400x150&sensor=false'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.black.withOpacity(0.35),
                  ),
                  child: Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _launchGoogleMapsRoute(address);
                      },
                      icon: const Icon(Icons.directions_car_rounded, color: Colors.black, size: 18),
                      label: const Text('Start Live Directions', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: TextStyle(color: subTextColor, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF38BDF8)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      CustomerDialogs.openEditCustomerModal(
                        context: context,
                        customerId: customerId,
                        currentData: customerData,
                        isButtonLoading: _isButtonLoading,
                        setButtonLoading: (id, loading) {
                          _setButtonLoading(id, loading);
                          if (!loading) {
                            _addNotification(
                              title: 'Customer Updated',
                              body: 'Account profile for $name was modified.',
                              type: 'edit',
                            );
                          }
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_location_alt_rounded, color: Color(0xFF38BDF8), size: 16),
                    label: const Text('Edit Address', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchGoogleMapsRoute(String destinationAddress) async {
    if (destinationAddress.trim().isEmpty) {
      CustomerDialogs.showTopNotification(context, 'Please enter customer address first!', isError: true);
      return;
    }
    final Uri googleMapsRouteUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(destinationAddress.trim())}&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsRouteUrl)) {
        await launchUrl(googleMapsRouteUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          CustomerDialogs.showTopNotification(context, 'Could not open Google Maps app!', isError: true);
        }
      }
    } catch (_) {
      if (mounted) {
        CustomerDialogs.showTopNotification(context, 'Failed to route navigation!', isError: true);
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

    final String? activeShopId = ref.watch(activeShopIdProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: cardBgColor,
        elevation: 0,
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF38BDF8), size: 20),
            ),
            const SizedBox(width: 8),
            // 🎯 EXPANDED PREVENTS OVERLAPPING WITH ICONS
            Expanded(
              child: Text(
                'Smart Ledger System',
                style: TextStyle(
                  fontWeight: FontWeight.w900, 
                  fontSize: 15, 
                  color: textColor, 
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔔 GOLDEN BELL WITH RED COUNTER BADGE
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .where('operatorUid', isEqualTo: currentUser.uid)
                    .where('isRead', isEqualTo: false)
                    .snapshots(),
                builder: (context, notifSnap) {
                  int unreadCount = notifSnap.hasData ? notifSnap.data!.docs.length : 0;

                  if (unreadCount > 0 && !_bellAnimationController.isAnimating) {
                    _triggerBellVibration();
                  }

                  final Color bellColor = unreadCount > 0 
                      ? const Color(0xFFEAB308) // Golden Yellow
                      : const Color(0xFF38BDF8); // Cyan Blue

                  return RotationTransition(
                    turns: Tween(begin: -0.05, end: 0.05).animate(_bellAnimationController),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_rounded, color: bellColor, size: 22),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              _isNotificationOpen = !_isNotificationOpen;
                            });
                          },
                        ),
                        if (unreadCount > 0)
                          Positioned(
                            top: -1,
                            right: -1,
                            child: IgnorePointer(
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cardBgColor, width: 1.5),
                                ),
                                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                                child: Text(
                                  unreadCount > 99 ? '99+' : '$unreadCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: const Icon(Icons.delete_sweep_rounded, color: Colors.amber, size: 21),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RecycleBinScreen())),
              ),
              const SizedBox(width: 2),
              IconButton(
                icon: Icon(_showArchived ? Icons.archive_rounded : Icons.archive_outlined, color: _showArchived ? const Color(0xFF38BDF8) : Colors.grey, size: 21),
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _showArchived = !_showArchived);
                  CustomerDialogs.showTopNotification(context, _showArchived ? 'Displaying Archived Accounts' : 'Displaying Active Ledger Accounts');
                },
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: IconButton(
                  icon: const Icon(Icons.storefront_rounded, color: Color(0xFF38BDF8), size: 21),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                ),
              ),
            ],
          ),
        ],
        shape: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      body: Stack(
        children: [
          // 1️⃣ MAIN WORKSPACE
          isDesktop
              ? Row(
                  children: [
                    _buildWebVerticalSlider(isDark, textColor, cardBgColor, borderColor),
                    Expanded(child: _buildMainContentPanel(currentUser.uid, activeShopId, isDesktop, isDark, textColor, cardBgColor, borderColor)),
                  ],
                )
              : _buildMainContentPanel(currentUser.uid, activeShopId, isDesktop, isDark, textColor, cardBgColor, borderColor),

          // 2️⃣ FLOATING AI CHAT WIDGET
          Positioned(
            right: _aiPosition.dx,
            bottom: _aiPosition.dy + (isDesktop ? 0 : 75),
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  double newDx = _aiPosition.dx - details.delta.dx;
                  double newDy = _aiPosition.dy - details.delta.dy;

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

          // 3️⃣ BOTTOM NAVIGATION BAR
          if (!isDesktop)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _buildCustomFloatingNavBar(isDark),
            ),

          // 4️⃣ ➡ RIGHT PERSISTENT SIDE PANEL WITH NOTIFICATION OVERLAY MANAGEMENT
          if (_isNotificationOpen)
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(
                width: isDesktop ? 380 : size.width * 0.88,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  border: Border(left: BorderSide(color: borderColor, width: 1.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 25,
                      offset: const Offset(-5, 0),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    // HEADER WITH CLOSE BUTTON
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        border: Border(bottom: BorderSide(color: borderColor)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded, color: Color(0xFFEAB308), size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Notifications Center',
                                style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444), size: 22),
                            onPressed: () {
                              setState(() => _isNotificationOpen = false);
                            },
                          ),
                        ],
                      ),
                    ),

                    // 🎛️ 1-LINE CONTROL BAR
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            _buildSingleLineOption(
                              label: 'Unread',
                              icon: Icons.mark_email_unread_rounded,
                              isSelected: _notificationTabFilter == 'unread',
                              color: const Color(0xFF38BDF8),
                              onTap: () => setState(() => _notificationTabFilter = 'unread'),
                            ),
                            const SizedBox(width: 6),
                            _buildSingleLineOption(
                              label: 'Read',
                              icon: Icons.mark_email_read_rounded,
                              isSelected: _notificationTabFilter == 'read',
                              color: const Color(0xFF38BDF8),
                              onTap: () => setState(() => _notificationTabFilter = 'read'),
                            ),
                            const SizedBox(width: 6),
                            _buildSingleLineOption(
                              label: 'Mark All Read',
                              icon: Icons.done_all_rounded,
                              isSelected: false,
                              color: const Color(0xFF10B981),
                              onTap: () async {
                                final batch = FirebaseFirestore.instance.batch();
                                final docs = await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .where('operatorUid', isEqualTo: currentUser.uid)
                                    .where('isRead', isEqualTo: false)
                                    .get();
                                for (var d in docs.docs) {
                                  batch.update(d.reference, {'isRead': true});
                                }
                                await batch.commit();
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildSingleLineOption(
                              label: 'Delete All',
                              icon: Icons.delete_forever_rounded,
                              isSelected: false,
                              color: const Color(0xFFEF4444),
                              onTap: () async {
                                final docs = await FirebaseFirestore.instance
                                    .collection('notifications')
                                    .where('operatorUid', isEqualTo: currentUser.uid)
                                    .get();
                                for (var d in docs.docs) {
                                  await d.reference.delete();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 📜 REAL-TIME FILTERED LIST STREAM
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _notificationTabFilter == 'unread'
                            ? FirebaseFirestore.instance
                                .collection('notifications')
                                .where('operatorUid', isEqualTo: currentUser.uid)
                                .where('isRead', isEqualTo: false)
                                .snapshots()
                            : FirebaseFirestore.instance
                                .collection('notifications')
                                .where('operatorUid', isEqualTo: currentUser.uid)
                                .where('isRead', isEqualTo: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text(
                                'No ${_notificationTabFilter.toUpperCase()} notifications found.',
                                style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontWeight: FontWeight.bold),
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs;

                          return ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.all(12),
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final data = docs[index].data() as Map<String, dynamic>;
                              final String docId = docs[index].id;
                              final String type = data['type'] ?? 'info';
                              final String title = data['title'] ?? 'System Alert';
                              final String body = data['body'] ?? '';
                              final Timestamp? ts = data['createdAt'] as Timestamp?;
                              final String timeStr = ts != null ? DateFormat('dd MMM, hh:mm a').format(ts.toDate()) : 'Just now';

                              IconData typeIcon = Icons.info_outline_rounded;
                              Color typeColor = const Color(0xFF38BDF8);

                              if (type == 'add') {
                                typeIcon = Icons.person_add_alt_1_rounded;
                                typeColor = const Color(0xFF10B981);
                              } else if (type == 'edit') {
                                typeIcon = Icons.edit_note_rounded;
                                typeColor = const Color(0xFF38BDF8);
                              } else if (type == 'delete') {
                                typeIcon = Icons.report_problem_rounded;
                                typeColor = const Color(0xFFEF4444);
                              }

                              return InkWell(
                                onTap: () async {
                                  await FirebaseFirestore.instance.collection('notifications').doc(docId).update({
                                    'isRead': true,
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: typeColor.withOpacity(0.3), width: 1.2),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 16,
                                        backgroundColor: typeColor.withOpacity(0.15),
                                        child: Icon(typeIcon, color: typeColor, size: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    title,
                                                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12.5),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text(timeStr, style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, fontSize: 9.5)),
                                              ],
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              body,
                                              style: TextStyle(color: textColor.withOpacity(0.85), fontSize: 11.5),
                                            ),
                                          ],
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await FirebaseFirestore.instance.collection('notifications').doc(docId).delete();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Icon(Icons.close_rounded, size: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (_currentIndex == 1 && !_isNotificationOpen)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: FloatingActionButton.extended(
                onPressed: () => CustomerDialogs.openAddNewCustomerModal(
                  context: context,
                  operatorUid: currentUser.uid,
                  textColor: textColor,
                  cardBgColor: cardBgColor,
                  isButtonLoading: _isButtonLoading,
                  setButtonLoading: (id, loading) {
                    _setButtonLoading(id, loading);
                    if (!loading) {
                      _addNotification(
                        title: 'New Customer Added',
                        body: 'A new customer profile was created.',
                        type: 'add',
                      );
                    }
                  },
                ),
                backgroundColor: const Color(0xFF10B981),
                elevation: 4,
                icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
                label: const Text('Add New Customer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
              ),
            )
          : null,
    );
  }

  Widget _buildSingleLineOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomFloatingNavBar(bool isDark) {
    final Color navBgColor = isDark ? const Color(0xFF0F172A) : Colors.white;
    final Color navBorderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final Color shadowColor = isDark ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.08);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: navBgColor,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: navBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home', isDark),
          _buildNavItem(1, Icons.receipt_long_rounded, 'Ledger', isDark),
          _buildNavItem(2, Icons.storefront_rounded, 'Shops', isDark),
          _buildNavItem(3, Icons.credit_card_rounded, 'History', isDark),
          _buildNavItem(4, Icons.person_outline_rounded, 'Setting', isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
    final isSelected = _currentIndex == index;
    final unselectedIconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          setState(() => _currentIndex = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0066FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : unselectedIconColor,
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ],
        ),
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
          _buildSliderButton(index: 2, label: 'My Shops Management', icon: Icons.storefront_rounded, isDark: isDark, textColor: textColor),
          _buildSliderButton(index: 3, label: 'History Flow', icon: Icons.history_toggle_off_rounded, isDark: isDark, textColor: textColor),
          _buildSliderButton(index: 4, label: 'Setting Desk', icon: Icons.settings_suggest_rounded, isDark: isDark, textColor: textColor),
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

  Widget _buildMainContentPanel(String operatorUid, String? activeShopId, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
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
        _buildCustomerTab(operatorUid, activeShopId, isDesktop, isDark, textColor, cardBgColor, borderColor),
        const ShopManagementScreen(), 
        const HistoryScreen(),          
        SettingsControlPanel(isDark: isDark, textColor: textColor, cardBgColor: cardBgColor, borderColor: borderColor), 
      ],
    );
  }

  Widget _buildCustomerTab(String operatorUid, String? activeShopId, bool isDesktop, bool isDark, Color textColor, Color cardBgColor, Color borderColor) {
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
            key: ValueKey(activeShopId ?? 'default_shop'),
            stream: (activeShopId != null && activeShopId.isNotEmpty)
                ? FirebaseFirestore.instance
                    .collection('customers')
                    .where('operatorUid', isEqualTo: operatorUid)
                    .where('shopId', isEqualTo: activeShopId)
                    .where('isArchived', isEqualTo: _showArchived)
                    .snapshots()
                : FirebaseFirestore.instance
                    .collection('customers')
                    .where('operatorUid', isEqualTo: operatorUid)
                    .where('isArchived', isEqualTo: _showArchived)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(child: Text('No active merchant nodes deployed for this shop.', style: TextStyle(color: textColor, fontWeight: FontWeight.w900)));
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
                key: PageStorageKey<String>('smooth_customer_list_${activeShopId ?? "all"}'),
                physics: const BouncingScrollPhysics(),
                cacheExtent: 500,
                padding: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 120),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: InkWell(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '+91 ${data['phone'] ?? ""}',
                      style: TextStyle(color: isDark ? Colors.grey.shade300 : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if ((data['address'] ?? "").toString().isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        data['address'] ?? "",
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 11, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        const SizedBox(width: 3),
                        Text(
                          'Added: $formattedDate',
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+₹${balance.abs().toStringAsFixed(2)}',
                    style: TextStyle(
                      color: balance >= 0 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(width: 2),

                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981), size: 17),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
                    onPressed: () => _launchWhatsApp(data['phone'] ?? '', customerName),
                  ),
                  const SizedBox(width: 2),

                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Color(0xFF38BDF8), size: 17),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
                    onPressed: () => CustomerDialogs.openEditCustomerModal(
                      context: context,
                      customerId: customerId,
                      currentData: data,
                      isButtonLoading: _isButtonLoading,
                      setButtonLoading: (id, loading) {
                        _setButtonLoading(id, loading);
                        if (!loading) {
                          _addNotification(
                            title: 'Customer Updated',
                            body: 'Account profile for $customerName was modified.',
                            type: 'edit',
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 2),

                  IconButton(
                    icon: const Icon(Icons.location_on_outlined, color: Color(0xFF38BDF8), size: 17),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
                    onPressed: () => _showRouteMapPopup(context, customerId, data, isDark),
                  ),
                  const SizedBox(width: 2),

                  IconButton(
                    icon: isArchiving
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2))
                        : Icon(_showArchived ? Icons.unarchive_rounded : Icons.archive_rounded, color: Colors.amber, size: 17),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
                    onPressed: () async {
                      _setButtonLoading('arch_$customerId', true);
                      await FirebaseFirestore.instance.collection('customers').doc(customerId).update({'isArchived': !_showArchived});
                      _setButtonLoading('arch_$customerId', false);
                      if (mounted) {
                        CustomerDialogs.showTopNotification(context, _showArchived ? 'Restored $customerName to active ledger!' : 'Archived $customerName!');
                      }
                    },
                  ),
                  const SizedBox(width: 2),

                  IconButton(
                    icon: isDeleting
                        ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(color: Color(0xFFEF4444), strokeWidth: 2))
                        : const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 17),
                    padding: const EdgeInsets.all(3),
                    constraints: const BoxConstraints(),
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