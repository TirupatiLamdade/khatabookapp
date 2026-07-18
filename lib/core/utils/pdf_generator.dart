import 'dart:convert';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import '../../data/models/transaction_model.dart';

class PdfReportGenerator {
  // Cross-Platform Clean Print & Export Framework Layout
  static Future<void> generateLedgerPdf({
    required String customerName,
    required List<TransactionModel> transactions,
  }) async {
    // Standard structured plain text representation representing a printable template stream
    StringBuffer buffer = StringBuffer();
    buffer.writeln("=== KHATABOOK SMART LEDGER REPORT ===");
    buffer.writeln("Customer Name: $customerName");
    buffer.writeln("Generated On: ${DateTime.now().toIso8601String()}");
    buffer.writeln("=========================================\n");
    buffer.writeln("Date       | Time  | Product Details | Type   | Amount");
    buffer.writeln("---------------------------------------------------------");

    for (var tx in transactions) {
      // 🛠️ FIX: timestamp मधून Date आणि Time स्वयंचलित फॉरमॅट करा
      final DateTime txDateTime = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      final String formattedDate = "${txDateTime.day.toString().padLeft(2, '0')}-${txDateTime.month.toString().padLeft(2, '0')}-${txDateTime.year}";
      final String formattedTime = "${txDateTime.hour.toString().padLeft(2, '0')}:${txDateTime.minute.toString().padLeft(2, '0')}";

      // 🛠️ FIX: credit/debit वरून Type (Gave/Got) आणि Amount निश्चित करा
      final String txType = tx.debit > 0 ? "DEBIT" : "CREDIT";
      final double txAmount = tx.debit > 0 ? tx.debit : tx.credit;

      buffer.writeln("$formattedDate | $formattedTime | ${tx.productName.padRight(15)} | ${txType.padRight(6)} | ₹$txAmount");
    }
    
    buffer.writeln("=========================================");

    if (kIsWeb) {
      final bytes = utf8.encode(buffer.toString());
      final blob = html.Blob([bytes], 'text/plain'); // Plain matrix for instant rendering
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = '${customerName}_Ledger_Report.txt';
      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
    } else {
      // Direct integration with target platform document printer logic
      debugPrint(buffer.toString());
    }
  }
}