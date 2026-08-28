class Payment {
  final int id;
  final int userId;
  final int amount;
  final String method;
  final String status;
  final String? phone;
  final String? cardNumber;
  final String? accountName;
  final String? reference;
  final String? createdAt;

  const Payment({
    required this.id,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.phone,
    this.cardNumber,
    this.accountName,
    this.reference,
    this.createdAt,
  });

  factory Payment.fromJson(
    Map<String, dynamic> json,
  ) {
    return Payment(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      amount: _toInt(json['amount']),
      method:
          json['method']?.toString() ?? '',
      status:
          json['status']?.toString() ??
              'pending',
      phone:
          json['phone']?.toString(),
      cardNumber:
          json['card_number']?.toString(),
      accountName:
          json['account_name']?.toString(),
      reference:
          json['reference']?.toString(),
      createdAt:
          json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'phone': phone,
      'card_number': cardNumber,
      'account_name': accountName,
      'reference': reference,
      'created_at': createdAt,
    };
  }

  bool get isPending =>
      status == 'pending';

  bool get isApproved =>
      status == 'approved' ||
      status == 'completed';

  bool get isRejected =>
      status == 'rejected';

  String get statusName {
    switch (status) {
      case 'approved':
      case 'completed':
        return 'مكتمل';

      case 'rejected':
        return 'مرفوض';

      default:
        return 'قيد المراجعة';
    }
  }

  String get methodName {
    switch (method) {
      case 'card':
        return 'بطاقة';

      case 'phone':
        return 'رقم هاتف';

      default:
        return method.isEmpty
            ? 'غير محدد'
            : method;
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
