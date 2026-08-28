import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  // غيّر هذا الرابط لاحقاً إلى رابط السيرفر الحقيقي
  static const String baseUrl = 'https://YOUR-SERVER.com/api';

  String imageUrl(String image) {
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    return '$baseUrl/$image';
  }

  Future<List<dynamic>> getCars() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cars'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final data = _decode(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        _message(data, 'تعذر تحميل السيارات'),
      );
    }

    if (data is List) {
      return data;
    }

    if (data is Map && data['cars'] is List) {
      return data['cars'];
    }

    if (data is Map && data['data'] is List) {
      return data['data'];
    }

    return [];
  }

  Future<dynamic> createCar({
    required String brand,
    required String model,
    required int year,
    required int price,
    required int km,
    required String city,
    required String fuel,
    required String transmission,
    required String description,
    required String plan,
    required List<XFile> images,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/cars'),
    );

    request.fields.addAll({
      'brand': brand,
      'model': model,
      'year': year.toString(),
      'price': price.toString(),
      'km': km.toString(),
      'city': city,
      'fuel': fuel,
      'transmission': transmission,
      'description': description,
      'plan': _planToPrice(plan),
    });

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images[]',
          image.path,
        ),
      );
    }

    final streamed = await request.send();
    final response =
        await http.Response.fromStream(streamed);

    final data = _decode(response);

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw ApiException(
        _message(data, 'تعذر إضافة السيارة'),
      );
    }

    return data;
  }

  int _planToPrice(String plan) {
    switch (plan) {
      case 'VIP':
        return 30000;
      case 'مميز':
        return 20000;
      default:
        return 10000;
    }
  }

  dynamic _decode(http.Response response) {
    if (response.body.trim().isEmpty) {
      return {};
    }

    try {
      return jsonDecode(response.body);
    } catch (_) {
      return {
        'message': response.body,
      };
    }
  }

  String _message(
    dynamic data,
    String fallback,
  ) {
    if (data is Map) {
      final message =
          data['message'] ?? data['error'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return fallback;
  }
}
