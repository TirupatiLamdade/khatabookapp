import 'package:excel/excel.dart';
import '../../../data/models/transaction_model.dart';

class PdfExcelExporter {
  // १. एक्सेल (XLSX) जनरेटर आणि एक्स्पोर्टर
  static List<int>? exportTransactionsToExcel({
    required String customerName,
    required List<TransactionModel> transactions,
  }) {
    final Excel excel = Excel.createExcel();
    final Sheet sheetObject = excel['Ledger Report'];

    // 🛠️ FIX: CellValue.value ऐवजी योग्य विशिष्ट CellValue प्रकार वापरले आहेत
    // Headers (सर्व टेक्स्ट आहेत म्हणून TextCellValue वापरले)
    sheetObject.appendRow([
      TextCellValue('Transaction ID'),
      TextCellValue('Product / Particulars'),
      TextCellValue('Quantity'),
      TextCellValue('Price'),
      TextCellValue('Debit (Gave)'),
      TextCellValue('Credit (Received)'),
      TextCellValue('Running Total'),
      TextCellValue('Timestamp'),
    ]);

    // Data rows
    for (var tx in transactions) {
      sheetObject.appendRow([
        TextCellValue(tx.id),
        TextCellValue(tx.productName),
        IntCellValue(tx.quantity),
        DoubleCellValue(tx.price),
        DoubleCellValue(tx.debit),
        DoubleCellValue(tx.credit),
        DoubleCellValue(tx.runningTotal),
        TextCellValue(DateTime.fromMillisecondsSinceEpoch(tx.timestamp).toIso8601String()),
      ]);
    }

    return excel.encode();
  }

  // २. लाईटवेट सीएसव्ही (CSV) एक्स्पोर्टर
  static String exportTransactionsToCsv({
    required List<TransactionModel> transactions,
  }) {
    final List<List<String>> csvData = [
      ['Transaction ID', 'Product', 'Quantity', 'Price', 'Debit', 'Credit', 'Running Total', 'Date']
    ];

    for (var tx in transactions) {
      final txDate = DateTime.fromMillisecondsSinceEpoch(tx.timestamp);
      csvData.add([
        tx.id,
        tx.productName,
        tx.quantity.toString(),
        tx.price.toString(),
        tx.debit.toString(),
        tx.credit.toString(),
        tx.runningTotal.toString(),
        '${txDate.day}-${txDate.month}-${txDate.year}'
      ]);
    }

    // CSV फॉरमॅट स्ट्रिंग मॅपिंग
    return const ListToCsvConverter().convert(csvData);
  }
}

// Simple internal helper class to avoid external csv library initialization issues
class ListToCsvConverter {
  const ListToCsvConverter();
  
  String convert(List<List<String>> rows) {
    return rows.map((row) {
      return row.map((field) {
        if (field.contains(',') || field.contains('\n') || field.contains('"')) {
          return '"${field.replaceAll('"', '""')}"';
        }
        return field;
      }).join(',');
    }).join('\r\n');
  }
}