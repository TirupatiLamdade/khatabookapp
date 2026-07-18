import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'transaction_viewmodel.dart';
import '../../../data/models/transaction_model.dart';

// रिपोर्ट स्टेट मॉडेल
class ReportState {
  final double totalCredit;
  final double totalDebit;
  final double netOutstanding;
  final double collectionRate;

  ReportState({
    this.totalCredit = 0.0,
    this.totalDebit = 0.0,
    this.netOutstanding = 0.0,
    this.collectionRate = 0.0,
  });
}

final reportsProvider = Provider<ReportState>((ref) {
  final transactions = ref.watch(transactionProvider);

  if (transactions.isEmpty) return ReportState();

  double creditSum = 0.0;
  double debitSum = 0.0;

  for (var tx in transactions) {
    creditSum += tx.credit;
    debitSum += tx.debit;
  }

  // निव्वळ येणे बाकी रक्कम (Net Outstanding)
  double outstanding = debitSum - creditSum;

  // कलेक्शन रेट फॉर्म्युला: (एकूण वसूल झालेली रक्कम (Credit) / एकूण दिलेली उधारी (Debit)) * 100
  double rate = 0.0;
  if (debitSum > 0) {
    rate = double.parse(((creditSum / debitSum) * 100).toStringAsFixed(2));
  }

  return ReportState(
    totalCredit: creditSum,
    totalDebit: debitSum,
    netOutstanding: outstanding,
    collectionRate: rate > 100 ? 100.0 : rate,
  );
});