class CustomerModel {
  final String id;
  final String shopId;
  final String ownerId;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double creditLimit;
  final double openingBalance;
  final List<String> tags;
  final bool isFavourite;
  final bool isBlocked;

  CustomerModel({
    required this.id,
    required this.shopId,
    required this.ownerId,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.creditLimit = 50000.0,
    this.openingBalance = 0.0,
    this.tags = const [],
    this.isFavourite = false,
    this.isBlocked = false,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      shopId: json['shopId'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      address: json['address'] as String?,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 50000.0,
      openingBalance: (json['openingBalance'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(json['tags'] ?? []),
      isFavourite: json['isFavourite'] as bool? ?? false,
      isBlocked: json['isBlocked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shopId': shopId,
      'ownerId': ownerId,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'creditLimit': creditLimit,
      'openingBalance': openingBalance,
      'tags': tags,
      'isFavourite': isFavourite,
      'isBlocked': isBlocked,
    };
  }
}