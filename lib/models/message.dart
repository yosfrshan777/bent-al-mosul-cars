class Message {
  final int id;
  final int? carId;
  final int senderId;
  final int receiverId;
  final String body;
  final String? createdAt;

  const Message({
    required this.id,
    this.carId,
    required this.senderId,
    required this.receiverId,
    required this.body,
    this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: _toInt(json['id']),
      carId: json['car_id'] == null
          ? null
          : _toInt(json['car_id']),
      senderId: _toInt(json['sender_id']),
      receiverId: _toInt(json['receiver_id']),
      body: json['body']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'car_id': carId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'body': body,
      'created_at': createdAt,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
