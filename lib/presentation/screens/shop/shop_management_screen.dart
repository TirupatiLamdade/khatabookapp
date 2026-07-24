// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ShopManagementScreen extends ConsumerStatefulWidget {
//   const ShopManagementScreen({Key? key}) : super(key: key);

//   @override
//   ConsumerState<ShopManagementScreen> createState() => _ShopManagementScreenState();
// }

// class _ShopManagementScreenState extends ConsumerState<ShopManagementScreen> {
//   final User? currentUser = FirebaseAuth.instance.currentUser;

//   @override
//   Widget build(BuildContext context) {
//     final double screenWidth = MediaQuery.of(context).size.width;
//     final bool isTabletOrWeb = screenWidth > 600;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A), // Dark Blue App Theme
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E293B),
//         title: const Text("My Shops Management", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         // 📡 'users' मधील सर्व दुकाने फेच करणे
//         stream: FirebaseFirestore.instance.collection('users').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent)));
//           }

//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return _buildNoShopsFound();
//           }

//           final allUserDocs = snapshot.data!.docs;

//           return Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 850),
//               child: ListView.builder(
//                 padding: EdgeInsets.symmetric(horizontal: isTabletOrWeb ? 24 : 12, vertical: 16),
//                 itemCount: allUserDocs.length,
//                 itemBuilder: (context, index) {
//                   final shopData = allUserDocs[index].data() as Map<String, dynamic>;
//                   final String shopId = allUserDocs[index].id;

//                   // 🟢 Active status चेक करणे
//                   final bool isActive = shopData['isActive'] == true;

//                   return _buildShopCard(
//                     context: context,
//                     shopId: shopId,
//                     shopData: shopData,
//                     isActive: isActive,
//                     isTabletOrWeb: isTabletOrWeb,
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // 🎴 Responsive Shop Item Card
//   Widget _buildShopCard({
//     required BuildContext context,
//     required String shopId,
//     required Map<String, dynamic> shopData,
//     required bool isActive,
//     required bool isTabletOrWeb,
//   }) {
//     final String shopName = shopData['shopName'] ?? shopData['name'] ?? 'Shop';
//     final String ownerName = shopData['ownerName'] ?? 'Owner';
//     final String address = shopData['shopAddress'] ?? shopData['address'] ?? 'No Address';
//     final String phone = shopData['phone'] ?? shopData['ownerPhone'] ?? 'No Phone';
//     final String shopEmail = shopData['email'] ?? shopData['ownerEmail'] ?? 'No Email';

//     return Card(
//       color: const Color(0xFF1E293B), // Dark Card Background
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(
//           color: isActive ? Colors.greenAccent : Colors.grey.shade800,
//           width: isActive ? 2 : 1,
//         ),
//       ),
//       elevation: isActive ? 6 : 2,
//       child: Padding(
//         padding: EdgeInsets.all(isTabletOrWeb ? 20.0 : 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: isTabletOrWeb ? 28 : 22,
//                   backgroundColor: Colors.blue.withOpacity(0.2),
//                   child: Icon(Icons.storefront_rounded, color: Colors.blueAccent, size: isTabletOrWeb ? 30 : 24),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         shopName,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: isTabletOrWeb ? 18 : 16,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text("Owner: $ownerName", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
//                     ],
//                   ),
//                 ),
//                 if (isActive)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                     decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
//                     child: const Text("ACTIVE", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 10)),
//                   ),
//               ],
//             ),
//             const Divider(height: 24, color: Colors.white10),
//             Row(children: [
//               const Icon(Icons.phone_android_outlined, size: 16, color: Colors.grey),
//               const SizedBox(width: 8),
//               Text(phone, style: const TextStyle(fontSize: 13, color: Colors.white70)),
//             ]),
//             const SizedBox(height: 6),
//             Row(children: [
//               const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
//               const SizedBox(width: 8),
//               Expanded(child: Text(address, style: const TextStyle(fontSize: 13, color: Colors.white70))),
//             ]),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 if (!isActive)
//                   Expanded(
//                     child: ElevatedButton.icon(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.blueAccent,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                       ),
//                       icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
//                       label: const Text("Switch to Shop", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       onPressed: () => _showProfessionalSwitchDialog(shopId, shopName),
//                     ),
//                   )
//                 else
//                   const Expanded(
//                     child: Text("Currently in use", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
//                   ),
//                 const SizedBox(width: 8),
//                 IconButton(
//                   icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
//                   onPressed: () => _showPermanentDeleteDialog(shopId, shopName, shopEmail),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // 💼 PROFESSIONAL SWITCH DIALOG WITH CHECKBOX
//   void _showProfessionalSwitchDialog(String shopId, String shopName) {
//     bool isConfirmed = false;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF1E293B),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//               title: const Row(
//                 children: [
//                   Icon(Icons.published_with_changes_rounded, color: Colors.blueAccent),
//                   SizedBox(width: 8),
//                   Text("Confirm Shop Switch", style: TextStyle(color: Colors.white, fontSize: 18)),
//                 ],
//               ),
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     "You are switching context to '$shopName'. All customer records, ledgers, and reports will update globally.",
//                     style: TextStyle(color: Colors.grey.shade300, fontSize: 13),
//                   ),
//                   const SizedBox(height: 12),
//                   CheckboxListTile(
//                     value: isConfirmed,
//                     activeColor: Colors.blueAccent,
//                     contentPadding: EdgeInsets.zero,
//                     title: const Text(
//                       "I confirm to switch workspace to this shop.",
//                       style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
//                     ),
//                     onChanged: (val) => setDialogState(() => isConfirmed = val ?? false),
//                   ),
//                 ],
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
//                 ),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     disabledBackgroundColor: Colors.grey.shade800,
//                   ),
//                   onPressed: isConfirmed
//                       ? () {
//                           Navigator.pop(context);
//                           _executeShopSwitch(shopId, shopName);
//                         }
//                       : null,
//                   child: const Text("Switch Context", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   // 🟦 BLUE SPLASH TRANSITION & FIRESTORE BATCH UPDATE
//   void _executeShopSwitch(String selectedShopId, String shopName) async {
//     try {
//       // 1. 🔥 Firestore मध्ये Atomic Batch म्‍हाणून सर्व Shops चा Status बदलणे
//       final batch = FirebaseFirestore.instance.batch();
//       final allDocs = await FirebaseFirestore.instance.collection('users').get();

//       for (var doc in allDocs.docs) {
//         batch.update(doc.reference, {'isActive': doc.id == selectedShopId});
//       }
//       await batch.commit();
//     } catch (e) {
//       debugPrint("Error updating shop context: $e");
//     }

//     if (!mounted) return;

//     // 2. ⏳ 3-Second Dark Blue Splash Loader (Matching App UI)
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => Scaffold(
//         backgroundColor: const Color(0xFF0F172A),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(color: Colors.blueAccent),
//               const SizedBox(height: 24),
//               Text(
//                 "Switching Context to $shopName...",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 "Updating ledgers, authorization, and customer data...",
//                 style: TextStyle(color: Colors.white70, fontSize: 13),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );

//     // 3. 🚀 ३ सेकंदांनंतर होम पेजवर रिडायरेक्ट करणे (इथे संपूर्ण डेटा ऑटोमॅटिक रीलोड होईल)
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         Navigator.pop(context);
//         Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
//       }
//     });
//   }

//   // 🗑️ PERMANENT DELETE DIALOG WITH CHECKBOX
//   void _showPermanentDeleteDialog(String shopId, String shopName, String registeredEmail) {
//     bool isAgreed = false;
//     final emailController = TextEditingController(text: registeredEmail);
//     final passwordController = TextEditingController();
//     bool isVerifying = false;

//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setDialogState) {
//             return AlertDialog(
//               backgroundColor: const Color(0xFF1E293B),
//               title: const Row(
//                 children: [
//                   Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
//                   SizedBox(width: 8),
//                   Text("Delete Shop", style: TextStyle(color: Colors.white)),
//                 ],
//               ),
//               content: SingleChildScrollView(
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       "Are you sure you want to PERMANENTLY delete '$shopName'?",
//                       style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 12),
//                     CheckboxListTile(
//                       value: isAgreed,
//                       activeColor: Colors.redAccent,
//                       contentPadding: EdgeInsets.zero,
//                       title: const Text("I agree to permanently delete this shop and data.", style: TextStyle(fontSize: 12, color: Colors.white70)),
//                       onChanged: (val) => setDialogState(() => isAgreed = val ?? false),
//                     ),
//                     if (isAgreed) ...[
//                       const SizedBox(height: 8),
//                       TextField(
//                         controller: emailController,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: const InputDecoration(labelText: "Email", labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), isDense: true),
//                       ),
//                       const SizedBox(height: 10),
//                       TextField(
//                         controller: passwordController,
//                         obscureText: true,
//                         style: const TextStyle(color: Colors.white),
//                         decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.grey), border: OutlineInputBorder(), isDense: true),
//                       ),
//                     ]
//                   ],
//                 ),
//               ),
//               actions: [
//                 TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.grey))),
//                 ElevatedButton(
//                   style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
//                   onPressed: (isAgreed && !isVerifying)
//                       ? () async {
//                           setDialogState(() => isVerifying = true);
//                           await _verifyAndDelete(
//                             context: context,
//                             shopId: shopId,
//                             shopName: shopName,
//                             email: emailController.text.trim(),
//                             password: passwordController.text.trim(),
//                           );
//                           setDialogState(() => isVerifying = false);
//                         }
//                       : null,
//                   child: isVerifying
//                       ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : const Text("Verify & Delete", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }

//   Future<void> _verifyAndDelete({
//     required BuildContext context,
//     required String shopId,
//     required String shopName,
//     required String email,
//     required String password,
//   }) async {
//     try {
//       if (email.isNotEmpty && password.isNotEmpty) {
//         AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
//         await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
//         await FirebaseAuth.instance.currentUser?.sendEmailVerification();
//       }

//       await FirebaseFirestore.instance.collection('users').doc(shopId).delete();

//       if (!mounted) return;
//       Navigator.pop(context);

//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'$shopName' deleted successfully!")));
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.redAccent, content: Text("Authentication Failed! Check credentials.")));
//     }
//   }

//   Widget _buildNoShopsFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade600),
//           const SizedBox(height: 12),
//           const Text("No shops found in database.", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShopManagementScreen extends ConsumerStatefulWidget {
  const ShopManagementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ShopManagementScreen> createState() => _ShopManagementScreenState();
}

class _ShopManagementScreenState extends ConsumerState<ShopManagementScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Detection (Syncs with Settings toggle)
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color cardBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color appBarBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final Color subTextColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final Color borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTabletOrWeb = screenWidth > 600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          "My Shops Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 📡 Stream all users/shops
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildNoShopsFound(textColor, subTextColor);
          }

          final allUserDocs = snapshot.data!.docs;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: ListView.builder(
                // 🟢 Extra bottom padding (140px) prevents floating widgets from blocking cards
                padding: EdgeInsets.only(
                  left: isTabletOrWeb ? 24 : 12,
                  right: isTabletOrWeb ? 24 : 12,
                  top: 16,
                  bottom: 140,
                ),
                itemCount: allUserDocs.length,
                itemBuilder: (context, index) {
                  final shopData = allUserDocs[index].data() as Map<String, dynamic>;
                  final String shopId = allUserDocs[index].id;
                  final bool isActive = shopData['isActive'] == true;

                  return _buildShopCard(
                    context: context,
                    shopId: shopId,
                    shopData: shopData,
                    isActive: isActive,
                    isTabletOrWeb: isTabletOrWeb,
                    isDark: isDark,
                    cardBgColor: cardBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    borderColor: borderColor,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  // 🎴 Responsive Shop Item Card with Dynamic Theme Support
  Widget _buildShopCard({
    required BuildContext context,
    required String shopId,
    required Map<String, dynamic> shopData,
    required bool isActive,
    required bool isTabletOrWeb,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color subTextColor,
    required Color borderColor,
  }) {
    final String shopName = shopData['shopName'] ?? shopData['name'] ?? 'Shop';
    final String ownerName = shopData['ownerName'] ?? 'Owner';
    final String address = shopData['shopAddress'] ?? shopData['address'] ?? 'No Address';
    final String phone = shopData['phone'] ?? shopData['ownerPhone'] ?? 'No Phone';
    final String shopEmail = shopData['email'] ?? shopData['ownerEmail'] ?? 'No Email';

    return Card(
      color: cardBgColor,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isActive ? Colors.greenAccent : borderColor,
          width: isActive ? 2 : 1,
        ),
      ),
      elevation: isActive ? 4 : (isDark ? 2 : 1),
      child: Padding(
        padding: EdgeInsets.all(isTabletOrWeb ? 20.0 : 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: isTabletOrWeb ? 28 : 22,
                  backgroundColor: Colors.blue.withOpacity(0.15),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: Colors.blueAccent,
                    size: isTabletOrWeb ? 30 : 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shopName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTabletOrWeb ? 18 : 16,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Owner: $ownerName",
                        style: TextStyle(color: subTextColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          "ACTIVE",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Divider(height: 24, color: borderColor),
            Row(
              children: [
                Icon(Icons.phone_android_outlined, size: 16, color: subTextColor),
                const SizedBox(width: 8),
                Text(phone, style: TextStyle(fontSize: 13, color: textColor)),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: subTextColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(address, style: TextStyle(fontSize: 13, color: textColor)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isActive)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        "Switch to Shop",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showProfessionalSwitchDialog(shopId, shopName, isDark, cardBgColor, textColor, subTextColor),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      "Currently in use",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
                  onPressed: () => _showPermanentDeleteDialog(shopId, shopName, shopEmail, isDark, cardBgColor, textColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 💼 PROFESSIONAL SWITCH DIALOG WITH CHECKBOX
  void _showProfessionalSwitchDialog(
    String shopId,
    String shopName,
    bool isDark,
    Color cardBgColor,
    Color textColor,
    Color subTextColor,
  ) {
    bool isConfirmed = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardBgColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.published_with_changes_rounded, color: Colors.blueAccent),
                  const SizedBox(width: 8),
                  Text("Confirm Shop Switch", style: TextStyle(color: textColor, fontSize: 18)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "You are switching context to '$shopName'. All customer records, ledgers, and reports will update globally.",
                    style: TextStyle(color: subTextColor, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: isConfirmed,
                    activeColor: Colors.blueAccent,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      "I confirm to switch workspace to this shop.",
                      style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    onChanged: (val) => setDialogState(() => isConfirmed = val ?? false),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: subTextColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                  ),
                  onPressed: isConfirmed
                      ? () {
                          Navigator.pop(context);
                          _executeShopSwitch(shopId, shopName);
                        }
                      : null,
                  child: const Text("Switch Context", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // 🟦 SPLASH TRANSITION & FIRESTORE BATCH UPDATE
  void _executeShopSwitch(String selectedShopId, String shopName) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final allDocs = await FirebaseFirestore.instance.collection('users').get();

      for (var doc in allDocs.docs) {
        batch.update(doc.reference, {'isActive': doc.id == selectedShopId});
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error updating shop context: $e");
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Scaffold(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                "Switching Context to $shopName...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Updating ledgers, authorization, and customer data...",
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context);
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    });
  }

  // 🗑️ PERMANENT DELETE DIALOG WITH CHECKBOX
  void _showPermanentDeleteDialog(
    String shopId,
    String shopName,
    String registeredEmail,
    bool isDark,
    Color cardBgColor,
    Color textColor,
  ) {
    bool isAgreed = false;
    final emailController = TextEditingController(text: registeredEmail);
    final passwordController = TextEditingController();
    bool isVerifying = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardBgColor,
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Text("Delete Shop", style: TextStyle(color: textColor)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Are you sure you want to PERMANENTLY delete '$shopName'?",
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: isAgreed,
                      activeColor: Colors.redAccent,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        "I agree to permanently delete this shop and data.",
                        style: TextStyle(fontSize: 12, color: textColor.withOpacity(0.8)),
                      ),
                      onChanged: (val) => setDialogState(() => isAgreed = val ?? false),
                    ),
                    if (isAgreed) ...[
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: textColor.withOpacity(0.6)),
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: textColor.withOpacity(0.6))),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                  onPressed: (isAgreed && !isVerifying)
                      ? () async {
                          setDialogState(() => isVerifying = true);
                          await _verifyAndDelete(
                            context: context,
                            shopId: shopId,
                            shopName: shopName,
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                          setDialogState(() => isVerifying = false);
                        }
                      : null,
                  child: isVerifying
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text("Verify & Delete", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _verifyAndDelete({
    required BuildContext context,
    required String shopId,
    required String shopName,
    required String email,
    required String password,
  }) async {
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
        await FirebaseAuth.instance.currentUser?.reauthenticateWithCredential(credential);
        await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      }

      await FirebaseFirestore.instance.collection('users').doc(shopId).delete();

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("'$shopName' deleted successfully!")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text("Authentication Failed! Check credentials."),
        ),
      );
    }
  }

  Widget _buildNoShopsFound(Color textColor, Color subTextColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront_outlined, size: 64, color: subTextColor),
          const SizedBox(height: 12),
          Text(
            "No shops found in database.",
            style: TextStyle(fontSize: 16, color: textColor, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}