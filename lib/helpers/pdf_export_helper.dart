

// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart' show kIsWeb;
// import 'package:flutter/material.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:printing/printing.dart';

// class PdfExportHelper {
//   static Future<void> generateAndSavePdf({
//     required String shopName,
//     required String ownerName,
//     required String shopPhone,
//     required String shopAddress,
//     required String customerName,
//     required String customerPhone,
//     required String reportType,
//     required List<Map<String, dynamic>> items,
//   }) async {
//     final pdf = pw.Document();

//     final fontBase = await PdfGoogleFonts.notoSansDevanagariRegular();
//     final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

//     double totalCredit = 0;
//     double totalDebit = 0;

//     for (var item in items) {
//       double price = (item['price'] as num).toDouble();
//       double qty = (item['qty'] as num).toDouble();
//       double total = price * qty;

//       if ((item['type'] ?? 'credit').toString().toLowerCase() == 'credit') {
//         totalCredit += total;
//       } else {
//         totalDebit += total;
//       }
//     }

//     double netBalance = totalCredit - totalDebit;
//     final invoiceNo = "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
//     final currentDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(28),
//         theme: pw.ThemeData.withFont(
//           base: fontBase,
//           bold: fontBold,
//         ),
//         build: (pw.Context context) {
//           return [
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text(
//                       shopName.toUpperCase(),
//                       style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
//                     ),
//                     pw.SizedBox(height: 3),
//                     pw.Text('Owner: $ownerName', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
//                     pw.Text('Address: $shopAddress', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
//                     pw.Text('Mobile: +91 $shopPhone', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
//                   ],
//                 ),
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.end,
//                   children: [
//                     pw.Text('STATEMENT OF ACCOUNT', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
//                     pw.SizedBox(height: 2),
//                     pw.Text('Ref No: $invoiceNo', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
//                     pw.Text('Date: $currentDate', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
//                   ],
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 10),
//             pw.Divider(thickness: 1.5, color: PdfColors.blue900),
//             pw.SizedBox(height: 10),

//             pw.Container(
//               padding: const pw.EdgeInsets.all(10),
//               decoration: pw.BoxDecoration(
//                 border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
//                 borderRadius: pw.BorderRadius.circular(6),
//                 color: PdfColors.grey100,
//               ),
//               child: pw.Row(
//                 mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                 children: [
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.start,
//                     children: [
//                       pw.Text('CUSTOMER INFORMATION:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
//                       pw.SizedBox(height: 3),
//                       pw.Text('Name: $customerName', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
//                       pw.Text('Mobile: +91 $customerPhone', style: const pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                   pw.Column(
//                     crossAxisAlignment: pw.CrossAxisAlignment.end,
//                     children: [
//                       pw.Text('Filter Period: $reportType', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
//                       pw.SizedBox(height: 3),
//                       pw.Text('Total Items: ${items.length}', style: const pw.TextStyle(fontSize: 10)),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             pw.SizedBox(height: 14),

//             pw.Table.fromTextArray(
//               headers: ['#', 'Product / Service Description', 'Type', 'Date', 'Rate', 'Qty', 'Total (₹)'],
//               data: List.generate(items.length, (index) {
//                 final item = items[index];
//                 final lineTotal = (item['price'] as num) * (item['qty'] as num);
//                 final typeStr = (item['type'] ?? 'credit').toString().toUpperCase();

//                 return [
//                   '${index + 1}',
//                   item['name'],
//                   typeStr,
//                   "${item['date']}\n${item['time']}",
//                   "₹${(item['price'] as num).toStringAsFixed(2)}",
//                   "${item['qty']}",
//                   "₹${lineTotal.toStringAsFixed(2)}",
//                 ];
//               }),
//               headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10, font: fontBold),
//               headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
//               cellHeight: 26,
//               cellStyle: pw.TextStyle(fontSize: 9, font: fontBase),
//               cellAlignments: {
//                 0: pw.Alignment.center,
//                 1: pw.Alignment.centerLeft,
//                 2: pw.Alignment.center,
//                 3: pw.Alignment.center,
//                 4: pw.Alignment.centerRight,
//                 5: pw.Alignment.center,
//                 6: pw.Alignment.centerRight,
//               },
//             ),
//             pw.SizedBox(height: 14),

//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.end,
//               children: [
//                 pw.Container(
//                   width: 220,
//                   padding: const pw.EdgeInsets.all(10),
//                   decoration: pw.BoxDecoration(
//                     color: PdfColors.grey100,
//                     border: pw.Border.all(color: PdfColors.grey400),
//                     borderRadius: pw.BorderRadius.circular(6),
//                   ),
//                   child: pw.Column(
//                     children: [
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Total Credit (+):', style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text('₹${totalCredit.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
//                         ],
//                       ),
//                       pw.SizedBox(height: 3),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Total Debit (-):', style: const pw.TextStyle(fontSize: 9)),
//                           pw.Text('₹${totalDebit.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
//                         ],
//                       ),
//                       pw.Divider(thickness: 0.8),
//                       pw.Row(
//                         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//                         children: [
//                           pw.Text('Net Balance:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
//                           pw.Text(
//                             '₹${netBalance.toStringAsFixed(2)}',
//                             style: pw.TextStyle(
//                               fontSize: 11,
//                               fontWeight: pw.FontWeight.bold,
//                               color: netBalance >= 0 ? PdfColors.green900 : PdfColors.red900,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             pw.SizedBox(height: 35),

//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text('Note: Computer generated billing statement.', style: pw.TextStyle(fontSize: 8, font: fontBase, color: PdfColors.grey600)),
//                 pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.center,
//                   children: [
//                     pw.Text(ownerName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
//                     pw.Container(width: 120, height: 1, color: PdfColors.grey700, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
//                     pw.Text('Authorized Signatory / Owner', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
//                   ],
//                 ),
//               ],
//             ),
//           ];
//         },
//       ),
//     );

//     final pdfBytes = await pdf.save();
//     final filename = "Invoice_${customerName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";

//     // 💡 PDF Bytes ला Base64 String मध्ये Encode करून Firestore मध्ये Save करणे
//     final String pdfBase64 = base64Encode(pdfBytes);

//     final currentUser = FirebaseAuth.instance.currentUser;
//     if (currentUser != null) {
//       try {
//         await FirebaseFirestore.instance.collection('saved_reports').add({
//           'fileName': filename,
//           'customerName': customerName,
//           'customerPhone': customerPhone,
//           'pdfBase64': pdfBase64, // 👈 Store Entire PDF in Firestore
//           'operatorUid': currentUser.uid,
//           'createdAt': FieldValue.serverTimestamp(),
//           'itemsCount': items.length,
//           'netBalance': netBalance,
//           'isTrash': false,
//         });
//       } catch (e) {
//         debugPrint("Firestore Save Error: $e");
//       }
//     }

//     if (!kIsWeb) {
//       try {
//         final appDir = await getApplicationDocumentsDirectory();
//         final file = File('${appDir.path}/$filename');
//         await file.writeAsBytes(pdfBytes);
//       } catch (e) {
//         debugPrint("Local Save Error: $e");
//       }
//     }

//     await Printing.sharePdf(
//       bytes: pdfBytes,
//       filename: filename,
//     );
//   }

//   static void showExportDialog(
//     BuildContext context, {
//     required String customerId,
//     required String customerName,
//     required String customerPhone,
//   }) {
//     showDialog(
//       context: context,
//       builder: (ctx) => _PdfExportDialogWidget(
//         customerId: customerId,
//         customerName: customerName,
//         customerPhone: customerPhone,
//       ),
//     );
//   }

//   static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
//     final overlay = Overlay.maybeOf(context);
//     if (overlay == null) return;

//     final overlayEntry = OverlayEntry(
//       builder: (context) => Positioned(
//         top: MediaQuery.of(context).padding.top + 10,
//         left: 16,
//         right: 16,
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
// }

// class _PdfExportDialogWidget extends StatefulWidget {
//   final String customerId;
//   final String customerName;
//   final String customerPhone;

//   const _PdfExportDialogWidget({
//     required this.customerId,
//     required this.customerName,
//     required this.customerPhone,
//   });

//   @override
//   State<_PdfExportDialogWidget> createState() => _PdfExportDialogWidgetState();
// }

// class _PdfExportDialogWidgetState extends State<_PdfExportDialogWidget> {
//   String selectedFilter = 'All';
//   final List<String> filterOptions = ['All', 'Daily', 'Weekly', 'Monthly', 'Custom'];
//   DateTimeRange? customDateRange;
//   bool isGenerating = false;

//   DateTime _parseTimestamp(dynamic timestamp) {
//     if (timestamp == null) return DateTime.now();
//     if (timestamp is Timestamp) return timestamp.toDate();
//     if (timestamp is DateTime) return timestamp;
//     if (timestamp is String) {
//       return DateTime.tryParse(timestamp) ?? DateTime.now();
//     }
//     return DateTime.now();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
//     final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

//     return AlertDialog(
//       backgroundColor: dialogBg,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
//       ),
//       title: Row(
//         children: [
//           const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 24),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Text(
//               'Export Billing PDF',
//               style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Select Date Filter:',
//               style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700], fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             Wrap(
//               spacing: 8,
//               children: filterOptions.map((filter) {
//                 final isSelected = selectedFilter == filter;
//                 return ChoiceChip(
//                   label: Text(filter),
//                   selected: isSelected,
//                   selectedColor: const Color(0xFFEF4444),
//                   labelStyle: TextStyle(
//                     color: isSelected ? Colors.white : textColor,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   onSelected: (val) async {
//                     if (filter == 'Custom') {
//                       final picked = await showDateRangePicker(
//                         context: context,
//                         firstDate: DateTime(2020),
//                         lastDate: DateTime.now(),
//                       );
//                       if (picked != null) {
//                         setState(() {
//                           customDateRange = picked;
//                           selectedFilter = filter;
//                         });
//                       }
//                     } else {
//                       setState(() => selectedFilter = filter);
//                     }
//                   },
//                 );
//               }).toList(),
//             ),
//             if (selectedFilter == 'Custom' && customDateRange != null) ...[
//               const SizedBox(height: 6),
//               Text(
//                 'Range: ${DateFormat('dd MMM').format(customDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(customDateRange!.end)}',
//                 style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: isGenerating ? null : () => Navigator.pop(context),
//           child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
//         ),
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFEF4444),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           ),
//           icon: isGenerating
//               ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//               : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
//           label: Text(
//             isGenerating ? 'Exporting...' : 'Export PDF',
//             style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//           ),
//           onPressed: isGenerating
//               ? null
//               : () async {
//                   setState(() => isGenerating = true);

//                   try {
//                     final currentUser = FirebaseAuth.instance.currentUser;
//                     String liveShopName = 'My Ledger Shop';
//                     String liveOwnerName = 'Shop Owner';
//                     String liveShopPhone = '+91 9876543210';
//                     String liveShopAddress = 'Market Area, City';

//                     if (currentUser != null) {
//                       final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(currentUser.uid).get();
//                       if (shopDoc.exists) {
//                         final data = shopDoc.data()!;
//                         liveShopName = data['shopName'] ?? data['name'] ?? liveShopName;
//                         liveOwnerName = data['ownerName'] ?? data['owner'] ?? liveOwnerName;
//                         liveShopPhone = data['phone'] ?? data['mobile'] ?? liveShopPhone;
//                         liveShopAddress = data['address'] ?? liveShopAddress;
//                       } else {
//                         final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
//                         if (userDoc.exists) {
//                           final data = userDoc.data()!;
//                           liveShopName = data['shopName'] ?? liveShopName;
//                           liveOwnerName = data['name'] ?? data['ownerName'] ?? liveOwnerName;
//                           liveShopPhone = data['phone'] ?? data['mobile'] ?? liveShopPhone;
//                           liveShopAddress = data['address'] ?? liveShopAddress;
//                         }
//                       }
//                     }

//                     QuerySnapshot querySnap;
//                     if (widget.customerId.isNotEmpty) {
//                       querySnap = await FirebaseFirestore.instance
//                           .collection('transactions')
//                           .where('customerId', isEqualTo: widget.customerId)
//                           .get();
//                     } else {
//                       querySnap = await FirebaseFirestore.instance
//                           .collection('transactions')
//                           .where('customerName', isEqualTo: widget.customerName)
//                           .get();
//                     }

//                     if (querySnap.docs.isEmpty && widget.customerName.isNotEmpty) {
//                       querySnap = await FirebaseFirestore.instance
//                           .collection('transactions')
//                           .where('customerName', isEqualTo: widget.customerName)
//                           .get();
//                     }

//                     if (querySnap.docs.isEmpty) {
//                       if (context.mounted) {
//                         Navigator.pop(context);
//                         PdfExportHelper.showTopNotification(
//                           context,
//                           'No transactions found for this customer!',
//                           isError: true,
//                         );
//                       }
//                       return;
//                     }

//                     final now = DateTime.now();
//                     final todayStart = DateTime(now.year, now.month, now.day);

//                     final filteredDocs = querySnap.docs.where((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final txDate = _parseTimestamp(data['timestamp']);

//                       if (selectedFilter == 'Daily') {
//                         return txDate.year == now.year &&
//                             txDate.month == now.month &&
//                             txDate.day == now.day;
//                       } else if (selectedFilter == 'Weekly') {
//                         final weekAgo = todayStart.subtract(const Duration(days: 7));
//                         return txDate.isAfter(weekAgo);
//                       } else if (selectedFilter == 'Monthly') {
//                         final monthAgo = DateTime(now.year, now.month - 1, now.day);
//                         return txDate.isAfter(monthAgo);
//                       } else if (selectedFilter == 'Custom' && customDateRange != null) {
//                         final start = customDateRange!.start;
//                         final end = customDateRange!.end.add(const Duration(days: 1));
//                         return txDate.isAfter(start) && txDate.isBefore(end);
//                       }
//                       return true;
//                     }).toList();

//                     if (filteredDocs.isEmpty) {
//                       if (context.mounted) {
//                         Navigator.pop(context);
//                         PdfExportHelper.showTopNotification(
//                           context,
//                           'No transactions match "$selectedFilter" filter!',
//                           isError: true,
//                         );
//                       }
//                       return;
//                     }

//                     List<Map<String, dynamic>> items = filteredDocs.map((doc) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final dt = _parseTimestamp(data['timestamp']);

//                       return {
//                         'name': data['productName'] ?? 'Item Entry',
//                         'type': data['type'] ?? 'credit',
//                         'price': double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
//                         'qty': double.tryParse(data['quantity']?.toString() ?? '0.0') ?? 0.0,
//                         'date': DateFormat('dd MMM yyyy').format(dt),
//                         'time': DateFormat('hh:mm a').format(dt),
//                       };
//                     }).toList();

//                     await PdfExportHelper.generateAndSavePdf(
//                       shopName: liveShopName,
//                       ownerName: liveOwnerName,
//                       shopPhone: liveShopPhone,
//                       shopAddress: liveShopAddress,
//                       customerName: widget.customerName,
//                       customerPhone: widget.customerPhone,
//                       reportType: selectedFilter,
//                       items: items,
//                     );

//                     if (context.mounted) {
//                       Navigator.pop(context);
//                       PdfExportHelper.showTopNotification(
//                         context,
//                         'PDF Billing Invoice Saved & Exported (${filteredDocs.length} items)!',
//                       );
//                     }
//                   } catch (e) {
//                     if (context.mounted) {
//                       PdfExportHelper.showTopNotification(
//                         context,
//                         'Failed to export PDF report!',
//                         isError: true,
//                       );
//                     }
//                   } finally {
//                     if (mounted) {
//                       setState(() => isGenerating = false);
//                     }
//                   }
//                 },
//         ),
//       ],
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

class PdfExportHelper {
  static Future<void> generateAndSavePdf({
    required String shopName,
    required String ownerName,
    required String shopPhone,
    required String shopAddress,
    required String customerName,
    required String customerPhone,
    required String reportType,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();

    final fontBase = await PdfGoogleFonts.notoSansDevanagariRegular();
    final fontBold = await PdfGoogleFonts.notoSansDevanagariBold();

    double totalCredit = 0;
    double totalDebit = 0;

    for (var item in items) {
      double price = (item['price'] as num).toDouble();
      double qty = (item['qty'] as num).toDouble();
      double total = price * qty;

      if ((item['type'] ?? 'credit').toString().toLowerCase() == 'credit') {
        totalCredit += total;
      } else {
        totalDebit += total;
      }
    }

    double netBalance = totalCredit - totalDebit;
    final invoiceNo = "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    final currentDate = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        theme: pw.ThemeData.withFont(
          base: fontBase,
          bold: fontBold,
        ),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      shopName.toUpperCase(),
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text('Owner: $ownerName', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900)),
                    pw.Text('Address: $shopAddress', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                    pw.Text('Mobile: +91 $shopPhone', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('STATEMENT OF ACCOUNT', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.red800)),
                    pw.SizedBox(height: 2),
                    pw.Text('Ref No: $invoiceNo', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                    pw.Text('Date: $currentDate', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(thickness: 1.5, color: PdfColors.blue900),
            pw.SizedBox(height: 10),

            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 0.8),
                borderRadius: pw.BorderRadius.circular(6),
                color: PdfColors.grey100,
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('CUSTOMER INFORMATION:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                      pw.SizedBox(height: 3),
                      pw.Text('Name: $customerName', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Mobile: +91 $customerPhone', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Filter Period: $reportType', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                      pw.SizedBox(height: 3),
                      pw.Text('Total Items: ${items.length}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            pw.Table.fromTextArray(
              headers: ['#', 'Product / Service Description', 'Type', 'Date', 'Rate', 'Qty', 'Total (₹)'],
              data: List.generate(items.length, (index) {
                final item = items[index];
                final lineTotal = (item['price'] as num) * (item['qty'] as num);
                final typeStr = (item['type'] ?? 'credit').toString().toUpperCase();

                return [
                  '${index + 1}',
                  item['name'],
                  typeStr,
                  "${item['date']}\n${item['time']}",
                  "₹${(item['price'] as num).toStringAsFixed(2)}",
                  "${item['qty']}",
                  "₹${lineTotal.toStringAsFixed(2)}",
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 10, font: fontBold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
              cellHeight: 26,
              cellStyle: pw.TextStyle(fontSize: 9, font: fontBase),
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.centerRight,
                5: pw.Alignment.center,
                6: pw.Alignment.centerRight,
              },
            ),
            pw.SizedBox(height: 14),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 220,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: PdfColors.grey400),
                    borderRadius: pw.BorderRadius.circular(6),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Credit (+):', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('₹${totalCredit.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.green900)),
                        ],
                      ),
                      pw.SizedBox(height: 3),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Total Debit (-):', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('₹${totalDebit.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.red900)),
                        ],
                      ),
                      pw.Divider(thickness: 0.8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Net Balance:', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          pw.Text(
                            '₹${netBalance.toStringAsFixed(2)}',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: netBalance >= 0 ? PdfColors.green900 : PdfColors.red900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 35),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Note: Computer generated billing statement.', style: pw.TextStyle(fontSize: 8, font: fontBase, color: PdfColors.grey600)),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(ownerName, style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
                    pw.Container(width: 120, height: 1, color: PdfColors.grey700, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                    pw.Text('Authorized Signatory / Owner', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
          ];
        },
      ),
    );

    final pdfBytes = await pdf.save();
    final filename = "Invoice_${customerName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf";

    // PDF Bytes ला Base64 String मध्ये Encode करून Firestore मध्ये Save करणे
    final String pdfBase64 = base64Encode(pdfBytes);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await FirebaseFirestore.instance.collection('saved_reports').add({
          'fileName': filename,
          'customerName': customerName,
          'customerPhone': customerPhone,
          'pdfBase64': pdfBase64,
          'operatorUid': currentUser.uid,
          'createdAt': FieldValue.serverTimestamp(),
          'itemsCount': items.length,
          'netBalance': netBalance,
          'isTrash': false,
        });
      } catch (e) {
        debugPrint("Firestore Save Error: $e");
      }
    }

    if (!kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final file = File('${appDir.path}/$filename');
        await file.writeAsBytes(pdfBytes);
      } catch (e) {
        debugPrint("Local Save Error: $e");
      }
    }

    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: filename,
    );
  }

  static void showExportDialog(
    BuildContext context, {
    required String customerId,
    required String customerName,
    required String customerPhone,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => _PdfExportDialogWidget(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
      ),
    );
  }

  static void showTopNotification(BuildContext context, String message, {bool isError = false}) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
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
}

class _PdfExportDialogWidget extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String customerPhone;

  const _PdfExportDialogWidget({
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<_PdfExportDialogWidget> createState() => _PdfExportDialogWidgetState();
}

class _PdfExportDialogWidgetState extends State<_PdfExportDialogWidget> {
  String selectedFilter = 'All';
  final List<String> filterOptions = ['All', 'Daily', 'Weekly', 'Monthly', 'Custom'];
  DateTimeRange? customDateRange;
  bool isGenerating = false;

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is String) {
      return DateTime.tryParse(timestamp) ?? DateTime.now();
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogBg = isDark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);

    return AlertDialog(
      backgroundColor: dialogBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
      ),
      title: Row(
        children: [
          const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Export Billing PDF',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Date Filter:',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[700], fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: filterOptions.map((filter) {
                final isSelected = selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: const Color(0xFFEF4444),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  onSelected: (val) async {
                    if (filter == 'Custom') {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          customDateRange = picked;
                          selectedFilter = filter;
                        });
                      }
                    } else {
                      setState(() => selectedFilter = filter);
                    }
                  },
                );
              }).toList(),
            ),
            if (selectedFilter == 'Custom' && customDateRange != null) ...[
              const SizedBox(height: 6),
              Text(
                'Range: ${DateFormat('dd MMM').format(customDateRange!.start)} - ${DateFormat('dd MMM yyyy').format(customDateRange!.end)}',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isGenerating ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: isGenerating
              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.download_rounded, size: 18, color: Colors.white),
          label: Text(
            isGenerating ? 'Exporting...' : 'Export PDF',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          onPressed: isGenerating
              ? null
              : () async {
                  setState(() => isGenerating = true);

                  try {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    String liveShopName = 'My Ledger Shop';
                    String liveOwnerName = 'Shop Owner';
                    String liveShopPhone = '+91 9876543210';
                    String liveShopAddress = 'Market Area, City';

                    if (currentUser != null) {
                      final shopDoc = await FirebaseFirestore.instance.collection('shops').doc(currentUser.uid).get();
                      if (shopDoc.exists) {
                        final data = shopDoc.data()!;
                        liveShopName = data['shopName'] ?? data['name'] ?? liveShopName;
                        liveOwnerName = data['ownerName'] ?? data['owner'] ?? liveOwnerName;
                        liveShopPhone = data['phone'] ?? data['mobile'] ?? liveShopPhone;
                        liveShopAddress = data['address'] ?? liveShopAddress;
                      } else {
                        final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
                        if (userDoc.exists) {
                          final data = userDoc.data()!;
                          liveShopName = data['shopName'] ?? liveShopName;
                          liveOwnerName = data['name'] ?? data['ownerName'] ?? liveOwnerName;
                          liveShopPhone = data['phone'] ?? data['mobile'] ?? liveShopPhone;
                          liveShopAddress = data['address'] ?? liveShopAddress;
                        }
                      }
                    }

                    QuerySnapshot querySnap;
                    if (widget.customerId.isNotEmpty) {
                      querySnap = await FirebaseFirestore.instance
                          .collection('transactions')
                          .where('customerId', isEqualTo: widget.customerId)
                          .get();
                    } else {
                      querySnap = await FirebaseFirestore.instance
                          .collection('transactions')
                          .where('customerName', isEqualTo: widget.customerName)
                          .get();
                    }

                    if (querySnap.docs.isEmpty && widget.customerName.isNotEmpty) {
                      querySnap = await FirebaseFirestore.instance
                          .collection('transactions')
                          .where('customerName', isEqualTo: widget.customerName)
                          .get();
                    }

                    if (querySnap.docs.isEmpty) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        PdfExportHelper.showTopNotification(
                          context,
                          'No transactions found for this customer!',
                          isError: true,
                        );
                      }
                      return;
                    }

                    final now = DateTime.now();
                    final todayStart = DateTime(now.year, now.month, now.day);

                    final filteredDocs = querySnap.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final txDate = _parseTimestamp(data['timestamp']);

                      if (selectedFilter == 'Daily') {
                        return txDate.year == now.year &&
                            txDate.month == now.month &&
                            txDate.day == now.day;
                      } else if (selectedFilter == 'Weekly') {
                        final weekAgo = todayStart.subtract(const Duration(days: 7));
                        return txDate.isAfter(weekAgo);
                      } else if (selectedFilter == 'Monthly') {
                        final monthAgo = DateTime(now.year, now.month - 1, now.day);
                        return txDate.isAfter(monthAgo);
                      } else if (selectedFilter == 'Custom' && customDateRange != null) {
                        final start = customDateRange!.start;
                        final end = customDateRange!.end.add(const Duration(days: 1));
                        return txDate.isAfter(start) && txDate.isBefore(end);
                      }
                      return true;
                    }).toList();

                    if (filteredDocs.isEmpty) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        PdfExportHelper.showTopNotification(
                          context,
                          'No transactions match "$selectedFilter" filter!',
                          isError: true,
                        );
                      }
                      return;
                    }

                    List<Map<String, dynamic>> items = filteredDocs.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final dt = _parseTimestamp(data['timestamp']);

                      return {
                        'name': data['productName'] ?? 'Item Entry',
                        'type': data['type'] ?? 'credit',
                        'price': double.tryParse(data['price']?.toString() ?? '0.0') ?? 0.0,
                        'qty': double.tryParse(data['quantity']?.toString() ?? '0.0') ?? 0.0,
                        'date': DateFormat('dd MMM yyyy').format(dt),
                        'time': DateFormat('hh:mm a').format(dt),
                      };
                    }).toList();

                    await PdfExportHelper.generateAndSavePdf(
                      shopName: liveShopName,
                      ownerName: liveOwnerName,
                      shopPhone: liveShopPhone,
                      shopAddress: liveShopAddress,
                      customerName: widget.customerName,
                      customerPhone: widget.customerPhone,
                      reportType: selectedFilter,
                      items: items,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      PdfExportHelper.showTopNotification(
                        context,
                        'PDF Billing Invoice Saved & Exported (${filteredDocs.length} items)!',
                      );
                    }
                  } on SocketException catch (_) {
                    // 🟢 नेटवर्क नसल्यास दाखवायचा टॉप मेसेज
                    if (context.mounted) {
                      PdfExportHelper.showTopNotification(
                        context,
                        'No internet access. Please try again.',
                        isError: true,
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      final String errStr = e.toString().contains("ClientException") || e.toString().contains("Failed host lookup")
                          ? 'No internet access. Please try again.'
                          : 'Failed to export PDF report!';
                      PdfExportHelper.showTopNotification(
                        context,
                        errStr,
                        isError: true,
                      );
                    }
                  } finally {
                    if (mounted) {
                      setState(() => isGenerating = false);
                    }
                  }
                },
        ),
      ],
    );
  }
}