class ShopModel {
  final String id;
  final String ownerId;
  final String name;
  final String businessType; // Grocery, Medical, Clothing etc.
  final String? gstNumber;
  final String? address;
  final String? logoUrl;
  final Map<String, String> collaborators; // {"user_uid": "Manager" / "Staff"}

  ShopModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.businessType,
    this.gstNumber,
    this.address,
    this.logoUrl,
    required this.collaborators,
  });

  // JSON / Firestore मॅपिंग
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      name: json['name'] as String,
      businessType: json['businessType'] as String,
      gstNumber: json['gstNumber'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logoUrl'] as String?,
      collaborators: Map<String, String>.from(json['collaborators'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'businessType': businessType,
      'gstNumber': gstNumber,
      'address': address,
      'logoUrl': logoUrl,
      'collaborators': collaborators,
    };
  }
}