class TransactionModel {
  final String id;
  final String productName;
  final double price;
  final String type; // 'DEBIT' किंवा 'CREDIT'
  final DateTime date;
  final String commitMessage;
  final bool isEdited;
  final double runningTotal; // 🟢 final केले आणि Null-safety फिक्स केली
  final int quantity;        // 🟢 'var' ऐवजी 'final int' प्रकार सुरक्षित केला

  TransactionModel({
    required this.id,
    required this.productName,
    required this.price,
    required this.type,
    required this.date,
    this.commitMessage = '',
    this.isEdited = false,
    this.runningTotal = 0.0, // 🟢 डिफॉल्ट व्हॅल्यू सेट केली
    this.quantity = 1,       // 🟢 डिफॉल्ट क्वांटिटी 1 सेट केली
  });

  // 🟢 pdf_generator.dart साठी आवश्यक कोअर गेटर्स
  int get timestamp => date.millisecondsSinceEpoch;
  double get debit => type == 'DEBIT' ? price : 0.0;
  double get credit => type == 'CREDIT' ? price : 0.0;

  // 🟢 सर्व नवीन फील्ड्ससह सुसज्ज copyWith मेथड
  TransactionModel copyWith({
    String? productName,
    double? price,
    String? type,
    String? commitMessage,
    bool? isEdited,
    double? runningTotal,
    int? quantity,
  }) {
    return TransactionModel(
      id: id,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      type: type ?? this.type,
      date: date,
      commitMessage: commitMessage ?? this.commitMessage,
      isEdited: isEdited ?? this.isEdited,
      runningTotal: runningTotal ?? this.runningTotal,
      quantity: quantity ?? this.quantity,
    );
  }
}