class Payment {
  final int id;
  final int userId;
  final int? carId;
  final String kind;
  final int amount;
  final String? receipt;
  final String reference;
  final String status;
  final String? createdAt;

  const Payment({
    required this.id,
    required this.userId,
    this.carId,
    required this.kind,
    required this.amount,
    this.receipt,
    required this.reference,
    required this.status,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      carId: json['car_id'] == null
          ? null
          : _toInt(json['car_id']),
      kind: json['kind']?.toString() ?? 'car',
      amount: _toInt(json['amount']),
      receipt: json['receipt']?.toString(),
      reference: json['reference']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'car_id': carId,
      'kind': kind,
      'amount': amount,
      'receipt': receipt,
      'reference': reference,
      'status': status,
      'created_at': createdAt,
    };
  }

  bool get isPending => status == 'pending';

  bool get isApproved =>
      status == 'approved' || status == 'published';

  bool get isRejected => status == 'rejected';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
