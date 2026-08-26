class Part {
  final int id;
  final int userId;
  final int? shopId;
  final String name;
  final int price;
  final String city;
  final String description;
  final String? image;
  final String status;
  final bool vip;
  final String? shopName;
  final String? ownerName;
  final String? shopPlan;

  const Part({
    required this.id,
    required this.userId,
    this.shopId,
    required this.name,
    required this.price,
    required this.city,
    required this.description,
    this.image,
    required this.status,
    required this.vip,
    this.shopName,
    this.ownerName,
    this.shopPlan,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      shopId: json['shop_id'] == null
          ? null
          : _toInt(json['shop_id']),
      name: json['name']?.toString() ?? '',
      price: _toInt(json['price']),
      city: json['city']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      vip: _toBool(json['vip']),
      shopName: json['shop_name']?.toString(),
      ownerName: json['owner_name']?.toString(),
      shopPlan: json['shop_plan']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'shop_id': shopId,
      'name': name,
      'price': price,
      'city': city,
      'description': description,
      'image': image,
      'status': status,
      'vip': vip ? 1 : 0,
      'shop_name': shopName,
      'owner_name': ownerName,
      'shop_plan': shopPlan,
    };
  }

  String get formattedPrice {
    return '${price.toString()} د.ع';
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;

    final text =
        value?.toString().toLowerCase();

    return text == 'true' || text == '1';
  }
}
