class Offer {
  final int id;
  final String target;
  final int discount;
  final String title;
  final String description;
  final String color;
  final String startAt;
  final String endAt;
  final bool active;
  final String? createdAt;

  const Offer({
    required this.id,
    required this.target,
    required this.discount,
    required this.title,
    required this.description,
    required this.color,
    required this.startAt,
    required this.endAt,
    required this.active,
    this.createdAt,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: _toInt(json['id']),
      target: json['target']?.toString() ?? '',
      discount: _toInt(json['discount']),
      title: json['title']?.toString() ?? '',
      description:
          json['description']?.toString() ?? '',
      color: json['color']?.toString() ?? 'pink',
      startAt: json['start_at']?.toString() ?? '',
      endAt: json['end_at']?.toString() ?? '',
      active: _toBool(json['active']),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target': target,
      'discount': discount,
      'title': title,
      'description': description,
      'color': color,
      'start_at': startAt,
      'end_at': endAt,
      'active': active ? 1 : 0,
      'created_at': createdAt,
    };
  }

  bool get isActive => active;

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

    return text == 'true' || text == '1';
  }
}
