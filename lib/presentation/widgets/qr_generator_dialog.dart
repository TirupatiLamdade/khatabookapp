import 'package:flutter/material.dart';

class QrGeneratorDialog extends StatelessWidget {
  final String upiId; // उदा. custom_shop@upi
  final String payeeName; // दुकानाचे नाव
  final double amount;
  final String transactionNote;

  const QrGeneratorDialog({
    super.key,
    required this.upiId,
    required this.payeeName,
    required this.amount,
    required this.transactionNote,
  });

  @override
  Widget build(BuildContext context) {
    // UPI मानकांनुसार डायनेमिक पेमेंट स्ट्रिंग तयार करा
    final String upiUri = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(payeeName)}&am=$amount&tn=${Uri.encodeComponent(transactionNote)}&cu=INR';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.qr_code_scanner, color: Colors.deepPurple),
          SizedBox(width: 10),
          Text('Collect Payment', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scan to Pay: ₹$amount',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 16),
          // QR कोड डिस्प्ले कंटेनर (Can be bound with any standard QR engine)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 200,
              height: 200,
              child: Image.network(
                'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=${Uri.encodeComponent(upiUri)}',
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Text('Failed to load QR code'));
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'UPI ID: $upiId',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}