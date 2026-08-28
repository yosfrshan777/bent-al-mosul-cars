class Car {
  final int id;
  final int userId;
  final String brand;
  final String model;
  final int year;
  final int price;
  final int km;
  final String city;
  final String fuel;
  final String transmission;
  final String description;
  final String plan;
  final String status;
  final String? image;
  final String? sellerName;
  final String? sellerPhone;
  final DateTime? createdAt;

  const Car({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
    required this.km,
    required this.city,
    required this.fuel,
    required this.transmission,
    required this.description,
    required this.plan,
    required this.status,
    this.image,
    this.sellerName,
    this.sellerPhone,
    this.createdAt,
  });

  bool get isVip {
    return plan.toUpperCase() == 'VIP';
  }

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      brand: _toString(json['brand']),
      model: _toString(json['model']),
      year: _toInt(json['year']),
      price: _toInt(json['price']),
      km: _toInt(json['km']),
      city: _toString(json['city']),
      fuel: _toString(
        json['fuel'],
        fallback: 'بنزين',
      ),
      transmission: _toString(
        json['transmission'],
        fallback: 'أوتوماتيك',
      ),
      description: _toString(json['description']),
      plan: _toString(
        json['plan'],
        fallback: 'عادي',
      ),
      status: _toString(
        json['status'],
        fallback: 'approved',
      ),
      image: _nullableString(json['image']),
      sellerName: _nullableString(
        json['seller_name'],
      ),
      sellerPhone: _nullableString(
        json['seller_phone'],
      ),
      createdAt: _toDateTime(
        json['created_at'],
      ),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  static String _toString(
    dynamic value, {
    String fallback = '',
  }) {
    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    return text.isEmpty ? fallback : text;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    return text.isEmpty ? null : text;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}
