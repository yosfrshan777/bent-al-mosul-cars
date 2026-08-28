class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String text;
  final bool isRead;
  final String? senderName;
  final String? receiverName;
  final String? createdAt;

  const Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.isRead,
    this.senderName,
    this.receiverName,
    this.createdAt,
  });

  factory Message.fromJson(
    Map<String, dynamic> json,
  ) {
    return Message(
      id: _toInt(json['id']),
      senderId: _toInt(json['sender_id']),
      receiverId: _toInt(json['receiver_id']),
      text: json['text']?.toString() ?? '',
      isRead: _toBool(json['is_read']),
      senderName:
          json['sender_name']?.toString(),
      receiverName:
          json['receiver_name']?.toString(),
      createdAt:
          json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'text': text,
      'is_read': isRead,
      'sender_name': senderName,
      'receiver_name': receiverName,
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

  static bool _toBool(dynamic value) {
    if (value is bool) return value;

    if (value is num) {
      return value != 0;
    }

    final text =
        value?.toString().toLowerCase();

    return text == 'true' ||
        text == '1' ||
        text == 'yes';
  }
}
