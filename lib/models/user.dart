class User {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      role: json['role']?.toString() ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role,
    };
  }

  bool get isOwner {
    return role == 'owner';
  }

  bool get isAdmin {
    return role == 'admin' || role == 'owner';
  }

  String get roleName {
    switch (role) {
      case 'owner':
        return 'المالك';

      case 'admin':
        return 'المدير';

      default:
        return 'مستخدم';
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
