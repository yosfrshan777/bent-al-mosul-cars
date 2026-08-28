class Car {
  final int id;
  final int userId;
  final String? publicNo;
  final String brand;
  final String model;
  final int year;
  final int price;
  final int km;
  final String city;
  final String fuel;
  final String transmission;
  final String description;
  final String? image;
  final int plan;
  final String status;
  final String? sellerName;
  final String? sellerPhone;
  final String? createdAt;

  const Car({
    required this.id,
    required this.userId,
    this.publicNo,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.km,
    required this.city,
    required this.fuel,
    required this.transmission,
    required this.description,
    this.image,
    required this.plan,
    required this.status,
    this.sellerName,
    this.sellerPhone,
    this.createdAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      publicNo: json['public_no']?.toString(),
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      year: _toInt(json['year']),
      price: _toInt(json['price']),
      km: _toInt(json['km']),
      city: json['city']?.toString() ?? '',
      fuel: json['fuel']?.toString() ?? '',
      transmission:
          json['transmission']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      image: json['image']?.toString(),
      plan: _toInt(
        json['plan'],
        fallback: 10000,
      ),
      status:
          json['status']?.toString() ?? 'pending',
      sellerName:
          json['seller_name']?.toString(),
      sellerPhone:
          json['seller_phone']?.toString(),
      createdAt:
          json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'public_no': publicNo,
      'brand': brand,
      'model': model,
      'year': year,
      'price': price,
      'km': km,
      'city': city,
      'fuel': fuel,
      'transmission': transmission,
      'description': description,
      'image': image,
      'plan': plan,
      'status': status,
      'seller_name': sellerName,
      'seller_phone': sellerPhone,
      'created_at': createdAt,
    };
  }

  String get planName {
    switch (plan) {
      case 30000:
        return 'VIP';
      case 20000:
        return 'مميز';
      default:
        return 'عادي';
    }
  }

  bool get isVip => plan >= 30000;

  bool get isFeatured => plan >= 20000;

  bool get isApproved =>
      status == 'approved' ||
      status == 'active';

  static int _toInt(
    dynamic value, {
    int fallback = 0,
  }) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        fallback;
  }
}
