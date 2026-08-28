import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiException implements Exception {
  final String message;

  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  // ضع رابط السيرفر الحقيقي هنا لاحقاً.
  static const String baseUrl =
      'https://YOUR-SERVER.com/api';

  String imageUrl(String image) {
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    return '$baseUrl/$image';
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    late http.Response response;

    try {
      if (method == 'GET') {
        response = await http.get(
          uri,
          headers: headers,
        );
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            ...?headers,
          },
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: headers,
        );
      } else {
        throw ApiException(
          'طريقة الطلب غير مدعومة',
        );
      }
    } on SocketException {
      throw ApiException(
        'تعذر الاتصال بالسيرفر',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        'حدث خطأ في الاتصال بالسيرفر',
      );
    }

    dynamic data;

    try {
      data = response.body.isEmpty
          ? null
          : jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message =
          'حدث خطأ في السيرفر';

      if (data is Map &&
          data['message'] != null) {
        message = data['message'].toString();
      }

      throw ApiException(message);
    }

    return data;
  }

  // =========================
  // السيارات
  // =========================

  Future<List<dynamic>> getCars() async {
    final data = await _request(
      'GET',
      '/cars',
    );

    if (data is List) {
      return data;
    }

    if (data is Map &&
        data['cars'] is List) {
      return data['cars'];
    }

    return [];
  }

  Future<dynamic> getCar(int id) {
    return _request(
      'GET',
      '/cars/$id',
    );
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

    request.fields['brand'] = brand;
    request.fields['model'] = model;
    request.fields['year'] =
        year.toString();
    request.fields['price'] =
        price.toString();
    request.fields['km'] =
        km.toString();
    request.fields['city'] = city;
    request.fields['fuel'] = fuel;
    request.fields['transmission'] =
        transmission;
    request.fields['description'] =
        description;
    request.fields['plan'] = plan;

    for (final image in images) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
        ),
      );
    }

    try {
      final streamed =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamed,
      );

      dynamic data;

      try {
        data = response.body.isEmpty
            ? null
            : jsonDecode(response.body);
      } catch (_) {
        data = response.body;
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        String message =
            'تعذر إضافة السيارة';

        if (data is Map &&
            data['message'] != null) {
          message =
              data['message'].toString();
        }

        throw ApiException(message);
      }

      return data;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw ApiException(
        'تعذر الاتصال بالسيرفر',
      );
    } catch (_) {
      throw ApiException(
        'حدث خطأ أثناء إضافة السيارة',
      );
    }
  }

  // =========================
  // تسجيل الدخول
  // =========================

  Future<dynamic> login({
    required String phone,
    required String password,
  }) {
    return _request(
      'POST',
      '/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );
  }

  // =========================
  // التسجيل
  // =========================

  Future<dynamic> register({
    required String name,
    required String phone,
    required String password,
  }) {
    return _request(
      'POST',
      '/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
      },
    );
  }

  // =========================
  // الإدارة
  // =========================

  Future<dynamic> getAdminData() {
    return _request(
      'GET',
      '/admin',
    );
  }

  Future<dynamic> getAdminUsers() {
    return _request(
      'GET',
      '/admin/users',
    );
  }

  Future<dynamic> getPendingCars() {
    return _request(
      'GET',
      '/admin/cars/pending',
    );
  }

  Future<dynamic> approveCar(int id) {
    return _request(
      'POST',
      '/admin/cars/$id/approve',
    );
  }

  Future<dynamic> rejectCar(int id) {
    return _request(
      'POST',
      '/admin/cars/$id/reject',
    );
  }

  // =========================
  // الطلبات
  // =========================

  Future<dynamic> getPendingRequests() {
    return _request(
      'GET',
      '/admin/requests/pending',
    );
  }

  Future<dynamic> approveRequest(
    int id,
  ) {
    return _request(
      'POST',
      '/admin/requests/$id/approve',
    );
  }

  Future<dynamic> rejectRequest(
    int id,
  ) {
    return _request(
      'POST',
      '/admin/requests/$id/reject',
    );
  }

  // =========================
  // إعدادات التحويل والاستلام
  // =========================

  Future<dynamic> getPaymentSettings() {
    return _request(
      'GET',
      '/admin/payment-settings',
    );
  }

  Future<dynamic> updatePaymentSettings({
    String? phone,
    String? cardNumber,
    String? accountName,
  }) {
    return _request(
      'PUT',
      '/admin/payment-settings',
      body: {
        if (phone != null)
          'phone': phone,
        if (cardNumber != null)
          'card_number': cardNumber,
        if (accountName != null)
          'account_name': accountName,
      },
    );
  }
}
