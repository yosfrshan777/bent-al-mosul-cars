class Shop {
  final int id;
  final int userId;
  final String shopName;
  final String ownerName;
  final String phone;
  final String? email;
  final String city;
  final String? logo;
  final String plan;
  final int amount;
  final String status;
  final String? expiresAt;
  final String? createdAt;

  const Shop({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.ownerName,
    required this.phone,
    this.email,
    required this.city,
    this.logo,
    required this.plan,
    required this.amount,
    required this.status,
    this.expiresAt,
    this.createdAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      shopName: json['shop_name']?.toString() ?? '',
      ownerName: json['owner_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      city: json['city']?.toString() ?? '',
      logo: json['logo']?.toString(),
      plan: json['plan']?.toString() ?? 'normal',
      amount: _toInt(json['amount']),
      status: json['status']?.toString() ?? 'pending',
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_name': shopName,
      'owner_name': ownerName,
      'phone': phone,
      'email': email,
      'city': city,
      'logo': logo,
      'plan': plan,
      'amount': amount,
      'status': status,
      'expires_at': expiresAt,
      'created_at': createdAt,
    };
  }

  bool get isVip => plan.toLowerCase() == 'vip';

  bool get isApproved => status == 'published';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
