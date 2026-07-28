
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:printing/printing.dart';

// class SavedReportsScreen extends StatefulWidget {
//   const SavedReportsScreen({super.key});

//   @override
//   State<SavedReportsScreen> createState() => _SavedReportsScreenState();
// }

// class _SavedReportsScreenState extends State<SavedReportsScreen> {
//   final currentUser = FirebaseAuth.instance.currentUser;

//   void _showTopNotification(String message, {bool isError = false}) {
//     if (!mounted) return;
//     final overlay = Overlay.maybeOf(context);
//     if (overlay == null) return;

//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: kIsWeb ? MediaQuery.of(context).size.width * 0.2 : 16,
//         right: kIsWeb ? MediaQuery.of(context).size.width * 0.2 : 16,
//         child: Material(
//           color: Colors.transparent,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
//               borderRadius: BorderRadius.circular(12),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 )
//               ],
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
//                   color: Colors.white,
//                   size: 22,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     message,
//                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );

//     overlay.insert(overlayEntry);
//     Future.delayed(const Duration(milliseconds: 2500), () {
//       overlayEntry.remove();
//     });
//   }

//   // 💡 Decode Base64 from Firestore to Bytes
//   Uint8List? _getpdfBytes(String? pdfBase64) {
//     if (pdfBase64 == null || pdfBase64.trim().isEmpty) return null;
//     try {
//       return base64Decode(pdfBase64);
//     } catch (_) {
//       return null;
//     }
//   }

//   // 1. SHARE / DOWNLOAD PDF (Web & Android Compatible)
//   Future<void> _shareOrDownloadPdf(String? pdfBase64, String fileName) async {
//     final pdfBytes = _getpdfBytes(pdfBase64);
//     if (pdfBytes == null) {
//       _showTopNotification('PDF data not found in Firestore!', isError: true);
//       return;
//     }

//     _showTopNotification('Opening PDF...');
//     await Printing.sharePdf(
//       bytes: pdfBytes,
//       filename: fileName,
//     );
//   }

//   // 2. PERMANENT DELETE (Firestore Delete)
//   void _confirmAndPermanentDelete(String docId, String fileName) {
//     showDialog(
//       context: context,
//       builder: (dialogCtx1) => AlertDialog(
//         backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text('Delete Report?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//         content: Text('Are you sure you want to delete "$fileName"?', style: const TextStyle(fontSize: 13)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogCtx1),
//             child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
//             onPressed: () async {
//               Navigator.pop(dialogCtx1);
//               try {
//                 // Firestore मधील Document Clear करणे
//                 await FirebaseFirestore.instance.collection('saved_reports').doc(docId).delete();

//                 // Android मधील local file असल्यास delete करणे
//                 if (!kIsWeb) {
//                   try {
//                     final dir = await getApplicationDocumentsDirectory();
//                     final file = File('${dir.path}/$fileName');
//                     if (await file.exists()) {
//                       await file.delete();
//                     }
//                   } catch (_) {}
//                 }

//                 _showTopNotification('Report permanently deleted!');
//               } catch (e) {
//                 _showTopNotification('Failed to delete report!', isError: true);
//               }
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWebOrDesktop = screenWidth > 600;

//     final userId = currentUser?.uid;

//     return Scaffold(
//       backgroundColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
//       appBar: AppBar(
//         title: const Text('Saved PDF Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
//         centerTitle: true,
//         backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
//         elevation: 0.5,
//       ),
//       body: userId == null
//           ? const Center(child: Text('Please log in to view saved reports.'))
//           : StreamBuilder<QuerySnapshot>(
//               stream: FirebaseFirestore.instance
//                   .collection('saved_reports')
//                   .where('operatorUid', isEqualTo: userId)
//                   .snapshots(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final docs = snapshot.data?.docs ?? [];

//                 if (docs.isEmpty) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.folder_off_rounded, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
//                         const SizedBox(height: 12),
//                         Text(
//                           'No saved PDF reports found.',
//                           style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   );
//                 }

//                 return Center(
//                   child: Container(
//                     constraints: BoxConstraints(maxWidth: isWebOrDesktop ? 800 : double.infinity),
//                     child: ListView.builder(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isWebOrDesktop ? 24 : 14,
//                         vertical: 12,
//                       ),
//                       itemCount: docs.length,
//                       itemBuilder: (context, index) {
//                         final doc = docs[index];
//                         final data = doc.data() as Map<String, dynamic>? ?? {};
//                         final docId = doc.id;
//                         final fileName = data['fileName'] as String? ?? 'Report.pdf';
//                         final customerName = data['customerName'] as String? ?? 'Customer';
//                         final pdfBase64 = data['pdfBase64'] as String?;
//                         final timestamp = data['createdAt'] as Timestamp?;
                        
//                         final dateStr = timestamp != null
//                             ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
//                             : 'Recently';

//                         return Card(
//                           color: isDark ? const Color(0xFF121824) : Colors.white,
//                           margin: const EdgeInsets.only(bottom: 12),
//                           elevation: 1,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
//                           ),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(12),
//                             child: Material(
//                               color: Colors.transparent,
//                               child: Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
//                                 child: ListTile(
//                                   contentPadding: EdgeInsets.zero,
//                                   leading: Container(
//                                     padding: const EdgeInsets.all(8),
//                                     decoration: BoxDecoration(
//                                       color: const Color(0xFFEF4444).withOpacity(0.12),
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 26),
//                                   ),
//                                   title: Text(
//                                     fileName,
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: TextStyle(
//                                       color: isDark ? Colors.white : const Color(0xFF0F172A),
//                                       fontSize: isWebOrDesktop ? 14 : 13,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     '$customerName • Saved: $dateStr',
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(fontSize: 11, color: Colors.grey),
//                                   ),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       // SHARE / VIEW BUTTON
//                                       IconButton(
//                                         constraints: const BoxConstraints(),
//                                         padding: const EdgeInsets.all(6),
//                                         icon: const Icon(Icons.share_rounded, color: Color(0xFF38BDF8), size: 20),
//                                         tooltip: 'Share',
//                                         onPressed: () => _shareOrDownloadPdf(pdfBase64, fileName),
//                                       ),
//                                       // DOWNLOAD / SAVE BUTTON
//                                       IconButton(
//                                         constraints: const BoxConstraints(),
//                                         padding: const EdgeInsets.all(6),
//                                         icon: const Icon(Icons.download_rounded, color: Color(0xFF10B981), size: 20),
//                                         tooltip: 'Download & Open',
//                                         onPressed: () => _shareOrDownloadPdf(pdfBase64, fileName),
//                                       ),
//                                       // DELETE BUTTON
//                                       IconButton(
//                                         constraints: const BoxConstraints(),
//                                         padding: const EdgeInsets.all(6),
//                                         icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
//                                         tooltip: 'Delete',
//                                         onPressed: () => _confirmAndPermanentDelete(docId, fileName),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:login_setup/core/services/notification_service.dart'; // 🔔 Notification Service Import

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;

  void _showTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: kIsWeb ? MediaQuery.of(context).size.width * 0.2 : 16,
        right: kIsWeb ? MediaQuery.of(context).size.width * 0.2 : 16,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });
  }

  // 💡 Decode Base64 from Firestore to Bytes
  Uint8List? _getpdfBytes(String? pdfBase64) {
    if (pdfBase64 == null || pdfBase64.trim().isEmpty) return null;
    try {
      return base64Decode(pdfBase64);
    } catch (_) {
      return null;
    }
  }

  // 1. SHARE / DOWNLOAD PDF (Web & Android Compatible)
  Future<void> _shareOrDownloadPdf(String? pdfBase64, String fileName) async {
    final pdfBytes = _getpdfBytes(pdfBase64);
    if (pdfBytes == null) {
      _showTopNotification('PDF data not found in Firestore!', isError: true);
      return;
    }

    _showTopNotification('Opening PDF...');

    // 🔔 TRIGGER NOTIFICATION
    await NotificationService.sendNotification(
      title: 'Report Opened',
      body: 'Opening report "$fileName".',
      type: 'info',
    );

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: fileName,
    );
  }

  // 2. PERMANENT DELETE (Firestore Delete)
  void _confirmAndPermanentDelete(String docId, String fileName) {
    showDialog(
      context: context,
      builder: (dialogCtx1) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Report?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete "$fileName"?', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx1),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            onPressed: () async {
              Navigator.pop(dialogCtx1);
              try {
                // Firestore मधील Document Clear करणे
                await FirebaseFirestore.instance.collection('saved_reports').doc(docId).delete();

                // Android मधील local file असल्यास delete करणे
                if (!kIsWeb) {
                  try {
                    final dir = await getApplicationDocumentsDirectory();
                    final file = File('${dir.path}/$fileName');
                    if (await file.exists()) {
                      await file.delete();
                    }
                  } catch (_) {}
                }

                // 🔔 TRIGGER NOTIFICATION
                await NotificationService.sendNotification(
                  title: 'Report Deleted',
                  body: 'Report "$fileName" was permanently deleted.',
                  type: 'delete',
                );

                _showTopNotification('Report permanently deleted!');
              } catch (e) {
                _showTopNotification('Failed to delete report!', isError: true);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWebOrDesktop = screenWidth > 600;

    final userId = currentUser?.uid;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Saved PDF Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        elevation: 0.5,
      ),
      body: userId == null
          ? const Center(child: Text('Please log in to view saved reports.'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('saved_reports')
                  .where('operatorUid', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_off_rounded, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No saved PDF reports found.',
                          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600], fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  );
                }

                return Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: isWebOrDesktop ? 800 : double.infinity),
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isWebOrDesktop ? 24 : 14,
                        vertical: 12,
                      ),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>? ?? {};
                        final docId = doc.id;
                        final fileName = data['fileName'] as String? ?? 'Report.pdf';
                        final customerName = data['customerName'] as String? ?? 'Customer';
                        final pdfBase64 = data['pdfBase64'] as String?;
                        final timestamp = data['createdAt'] as Timestamp?;
                        
                        final dateStr = timestamp != null
                            ? DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate())
                            : 'Recently';

                        return Card(
                          color: isDark ? const Color(0xFF121824) : Colors.white,
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Material(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 26),
                                  ),
                                  title: Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                      fontSize: isWebOrDesktop ? 14 : 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$customerName • Saved: $dateStr',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // SHARE / VIEW BUTTON
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                        icon: const Icon(Icons.share_rounded, color: Color(0xFF38BDF8), size: 20),
                                        tooltip: 'Share',
                                        onPressed: () => _shareOrDownloadPdf(pdfBase64, fileName),
                                      ),
                                      // DOWNLOAD / SAVE BUTTON
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                        icon: const Icon(Icons.download_rounded, color: Color(0xFF10B981), size: 20),
                                        tooltip: 'Download & Open',
                                        onPressed: () => _shareOrDownloadPdf(pdfBase64, fileName),
                                      ),
                                      // DELETE BUTTON
                                      IconButton(
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(6),
                                        icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 20),
                                        tooltip: 'Delete',
                                        onPressed: () => _confirmAndPermanentDelete(docId, fileName),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}