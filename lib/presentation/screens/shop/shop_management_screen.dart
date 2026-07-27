
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/global_provider_hub.dart';

class ShopManagementScreen extends ConsumerWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 🎨 Dynamic Theme Mode Watcher
    final currentTheme = ref.watch(themeModeProvider);
    final bool isDark = currentTheme == ThemeMode.dark ||
        (currentTheme == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final currentUser = FirebaseAuth.instance.currentUser;
    final dynamic activeShopState = ref.watch(activeShopIdProvider);

    String? activeShopId;
    if (activeShopState is AsyncValue) {
      activeShopId = activeShopState.asData?.value as String?;
    } else if (activeShopState is String?) {
      activeShopId = activeShopState;
    }

    final String targetShopId = (activeShopId != null && activeShopId.isNotEmpty)
        ? activeShopId
        : (currentUser?.uid ?? '');

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "Current Shop Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
        ),
      ),
      body: targetShopId.isEmpty
          ? Center(
              child: Text(
                "Please login to access real shop details",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 140),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: _SingleActiveShopPanel(
                    shopId: targetShopId,
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    borderColor: borderColor,
                  ),
                ),
              ),
            ),
    );
  }
}

class _SingleActiveShopPanel extends StatelessWidget {
  final String shopId;
  final bool isDark;
  final Color cardBgColor;
  final Color textColor;
  final Color subTextColor;
  final Color borderColor;

  const _SingleActiveShopPanel({
    Key? key,
    required this.shopId,
    required this.isDark,
    required this.cardBgColor,
    required this.textColor,
    required this.subTextColor,
    required this.borderColor,
  }) : super(key: key);

  // 🗺️ Google Maps Directions Launcher
  Future<void> _launchGoogleMaps(BuildContext context, String address) async {
    if (address.trim().isEmpty || address == 'No Address Listed') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No valid address available for navigation!')),
      );
      return;
    }
    final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(address.trim())}&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open Google Maps!')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to launch route directions.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('shops').doc(shopId).snapshots(),
      builder: (context, shopSnap) {
        if (shopSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
        }

        Map<String, dynamic> shopData = {};
        if (shopSnap.hasData && shopSnap.data!.exists && shopSnap.data!.data() != null) {
          shopData = shopSnap.data!.data() as Map<String, dynamic>;
        }

        return FutureBuilder<DocumentSnapshot>(
          future: shopData.isEmpty
              ? FirebaseFirestore.instance.collection('users').doc(shopId).get()
              : Future.value(null),
          builder: (context, userSnap) {
            Map<String, dynamic> userData = {};
            if (userSnap.hasData && userSnap.data != null && userSnap.data!.exists) {
              userData = userSnap.data!.data() as Map<String, dynamic>;
            }

            final String realShopName = shopData['shopName'] ?? shopData['name'] ?? userData['shopName'] ?? 'My Business Shop';
            
            String realOwnerName = 'Shop Owner';
            if (shopData['ownerName'] != null && shopData['ownerName'].toString().trim().isNotEmpty) {
              realOwnerName = shopData['ownerName'];
            } else if (shopData['owner'] != null && shopData['owner'].toString().trim().isNotEmpty) {
              realOwnerName = shopData['owner'];
            } else if (userData['ownerName'] != null && userData['ownerName'].toString().trim().isNotEmpty) {
              realOwnerName = userData['ownerName'];
            } else if (userData['name'] != null && userData['name'].toString().trim().isNotEmpty) {
              realOwnerName = userData['name'];
            } else if (currentUser?.displayName != null && currentUser!.displayName!.isNotEmpty) {
              realOwnerName = currentUser.displayName!;
            }

            final String realAddress = shopData['address'] ?? shopData['shopAddress'] ?? userData['address'] ?? 'No Address Listed';
            final String realCategory = shopData['category'] ?? userData['category'] ?? 'General Business';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1️⃣ ACTIVE SHOP HEADER CARD
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                          : [const Color(0xFF0066CC), const Color(0xFF0284C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  realShopName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Owner: $realOwnerName | $realCategory',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: Colors.amber, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    realAddress,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF10B981)),
                            ),
                            child: const Text(
                              'LOGGED IN SHOP',
                              style: TextStyle(color: Color(0xFF10B981), fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2️⃣ 📊 LIVE ANALYTICS STREAM
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('customers')
                      .where('operatorUid', isEqualTo: currentUser?.uid)
                      .snapshots(),
                  builder: (context, custSnap) {
                    if (!custSnap.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                    }

                    final custDocs = custSnap.data!.docs;
                    int totalCustomers = custDocs.length;
                    int activeCustomersCount = 0;
                    int recoveredCustomersCount = 0;

                    double totalUdhari = 0.0;
                    double maxUdhari = 0.0;
                    String highestUdhariCustName = "None";

                    double minUdhari = double.infinity;
                    String lowestUdhariCustName = "None";

                    for (var doc in custDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Customer';
                      bool isArchived = data['isArchived'] ?? false;
                      double balance = double.tryParse(data['balance']?.toString() ?? '0.0') ?? 0.0;

                      if (isArchived) {
                        recoveredCustomersCount++;
                      } else {
                        activeCustomersCount++;
                      }

                      if (balance > 0) {
                        totalUdhari += balance;

                        if (balance > maxUdhari) {
                          maxUdhari = balance;
                          highestUdhariCustName = name;
                        }
                        if (balance < minUdhari) {
                          minUdhari = balance;
                          lowestUdhariCustName = name;
                        }
                      }
                    }

                    if (minUdhari == double.infinity) minUdhari = 0.0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // COUNTS OVERVIEW
                        Text(
                          "CUSTOMER ACCOUNTS & RECOVERY OVERVIEW",
                          style: TextStyle(
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0066CC),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _buildCountTile(
                                title: "Total Accounts",
                                count: "$totalCustomers",
                                icon: Icons.groups_rounded,
                                color: const Color(0xFF38BDF8),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCountTile(
                                title: "Active Accounts",
                                count: "$activeCustomersCount",
                                icon: Icons.check_circle_rounded,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildCountTile(
                                title: "Recovered / Archive",
                                count: "$recoveredCustomersCount",
                                icon: Icons.archive_rounded,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // UDHARI GRAPHICS
                        Text(
                          "CUSTOMER UDHARI GRAPHICS & HIGHLIGHTS",
                          style: TextStyle(
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0066CC),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Udhari Balance",
                                    style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "₹${totalUdhari.toStringAsFixed(2)}",
                                    style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF4444).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.arrow_circle_up_rounded, color: Color(0xFFEF4444), size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "Highest Udhari",
                                                style: TextStyle(color: Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            highestUdhariCustName,
                                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₹${maxUdhari.toStringAsFixed(2)}",
                                            style: const TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w900, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Icon(Icons.arrow_circle_down_rounded, color: Color(0xFF10B981), size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                "Lowest / Clear",
                                                style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            lowestUdhariCustName,
                                            style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "₹${minUdhari.toStringAsFixed(2)}",
                                            style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              Text(
                                "Highest Udhari Ratio",
                                style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: totalUdhari > 0 ? (maxUdhari / totalUdhari).clamp(0.05, 1.0) : 0.0,
                                  backgroundColor: borderColor,
                                  color: const Color(0xFFEF4444),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // 3️⃣ 📍 LIVE CUSTOMER MAP & ADDRESS LIST (REAL-TIME UPDATES)
                        Text(
                          "CUSTOMER LIVE LOCATION MAPS & ADDRESSES",
                          style: TextStyle(
                            color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0066CC),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (custDocs.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cardBgColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: borderColor),
                            ),
                            child: Center(
                              child: Text(
                                "No registered customer locations found for this shop.",
                                style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: custDocs.length,
                            itemBuilder: (context, idx) {
                              final cData = custDocs[idx].data() as Map<String, dynamic>;
                              final String cName = cData['name'] ?? 'Customer';
                              final String cPhone = cData['phone'] ?? 'N/A';
                              final String cAddress = (cData['address'] ?? '').toString().trim().isNotEmpty
                                  ? cData['address']
                                  : 'No Address Listed';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: cardBgColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: borderColor, width: 1.2),
                                ),
                                child: Row(
                                  children: [
                                    // 🟢 Contact Circle Avatar with Customer Name Initial
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: const Color(0xFF38BDF8).withOpacity(0.15),
                                      child: Text(
                                        cName.isNotEmpty ? cName[0].toUpperCase() : 'C',
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // 🟢 Live Name, Phone & Address
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cName,
                                            style: TextStyle(
                                              color: textColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Icon(Icons.phone_android_rounded, size: 12, color: subTextColor),
                                              const SizedBox(width: 4),
                                              Text(
                                                "+91 $cPhone",
                                                style: TextStyle(color: subTextColor, fontSize: 11, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFFEF4444)),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  cAddress,
                                                  style: TextStyle(
                                                    color: textColor.withOpacity(0.85),
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // 🗺️ Interactive Live Route Map Circle Button
                                    InkWell(
                                      onTap: () => _launchGoogleMaps(context, cAddress),
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF38BDF8).withOpacity(0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
                                        ),
                                        child: const Icon(
                                          Icons.map_rounded,
                                          color: Color(0xFF38BDF8),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCountTile({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: subTextColor, fontSize: 10, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}