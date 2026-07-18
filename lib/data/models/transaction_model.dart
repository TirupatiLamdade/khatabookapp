class TransactionModel {
  final String id;
  final String customerId;
  final String shopId;
  final String ownerId;
  final String productName;
  final int quantity;
  final double price;
  final double credit; // User received cash
  final double debit;  // User gave credit
  final double runningTotal;
  final int timestamp;
  final String? notes;
  final bool isPending;

  TransactionModel({
    required this.id,
    required this.customerId,
    required this.shopId,
    required this.ownerId,
    required this.productName,
    this.quantity = 1,
    this.price = 0.0,
    required this.credit,
    required this.debit,
    required this.runningTotal,
    required this.timestamp,
    this.notes,
    this.isPending = false,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      customerId: json['customerId'] as String,
      shopId: json['shopId'] as String,
      ownerId: json['ownerId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      credit: (json['credit'] as num?)?.toDouble() ?? 0.0,
      debit: (json['debit'] as num?)?.toDouble() ?? 0.0,
      runningTotal: (json['runningTotal'] as num?)?.toDouble() ?? 0.0,
      timestamp: json['timestamp'] as int,
      notes: json['notes'] as String?,
      isPending: json['isPending'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'shopId': shopId,
      'ownerId': ownerId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'credit': credit,
      'debit': debit,
      'runningTotal': runningTotal,
      'timestamp': timestamp,
      'notes': notes,
      'isPending': isPending,
    };
  }
}