import 'dart:convert';
import 'dart:io';

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

  static const String baseUrl =
      'https://YOUR-SERVER.com/api';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    return {
      'Accept': 'application/json',
      if (_token != null && _token!.isNotEmpty)
        'Authorization': 'Bearer $_token',
    };
  }

  String imageUrl(String image) {
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    final cleanImage = image.startsWith('/')
        ? image.substring(1)
        : image;

    return '$cleanBase/$cleanImage';
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  String _message(dynamic data) {
    if (data is Map) {
      final value =
          data['message'] ?? data['error'];

      if (value != null) {
        return value.toString();
      }
    }

    return 'حدث خطأ في السيرفر';
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      late http.Response response;

      final headers = {
        'Content-Type': 'application/json',
        ..._headers,
      };

      switch (method) {
        case 'GET':
          response = await http.get(
            uri,
            headers: _headers,
          );
          break;

        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body ?? {}),
          );
          break;

        case 'DELETE':
          response = await http.delete(
            uri,
            headers: _headers,
          );
          break;

        default:
          throw const ApiException(
            'طريقة الطلب غير مدعومة',
          );
      }

      final data = _decode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _message(data),
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'لا يوجد اتصال بالسيرفر',
      );
    } on HttpException {
      throw const ApiException(
        'تعذر الوصول إلى السيرفر',
      );
    } catch (_) {
      throw const ApiException(
        'حدث خطأ أثناء الاتصال بالسيرفر',
      );
    }
  }

  // =========================================================
  // AUTH
  // =========================================================

  Future<dynamic> login({
    required String phone,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );

    if (data is Map) {
      final token = data['token'] ??
          data['access_token'];

      if (token != null) {
        setToken(token.toString());
      }
    }

    return data;
  }

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

  Future<dynamic> me() {
    return _request(
      'GET',
      '/me',
    );
  }

  Future<void> logout() async {
    try {
      await _request(
        'POST',
        '/logout',
      );
    } finally {
      clearToken();
    }
  }

  // =========================================================
  // CARS
  // =========================================================

  Future<List<dynamic>> getCars() async {
    final data = await _request(
      'GET',
      '/cars',
    );

    if (data is List) {
      return data;
    }

    if (data is Map) {
      final cars = data['cars'];

      if (cars is List) {
        return cars;
      }

      final items = data['items'];

      if (items is List) {
        return items;
      }

      final results = data['results'];

      if (results is List) {
        return results;
      }
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
    final uri = Uri.parse('$baseUrl/cars');

    final request =
        http.MultipartRequest('POST', uri);

    request.headers.addAll(_headers);

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
      'plan': plan,
    });

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

      final data = _decode(response.body);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _message(data),
        );
      }

      return data;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'لا يوجد اتصال بالسيرفر',
      );
    } catch (_) {
      throw const ApiException(
        'حدث خطأ أثناء رفع السيارة',
      );
    }
  }

  Future<dynamic> updateCar({
    required int id,
    required Map<String, dynamic> data,
  }) {
    return _request(
      'PUT',
      '/cars/$id',
      body: data,
    );
  }

  Future<dynamic> deleteCar(int id) {
    return _request(
      'DELETE',
      '/cars/$id',
    );
  }

  // =========================================================
  // ADMIN
  // =========================================================

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

  // =========================================================
  // الأقسام
  // =========================================================

  Future<dynamic> getPendingRequests({
    String? section,
  }) {
    final path = section == null ||
            section.isEmpty
        ? '/admin/requests/pending'
        : '/admin/requests/pending?section=$section';

    return _request(
      'GET',
      path,
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

  // =========================================================
  // الأدمن والمالك
  // =========================================================

  Future<dynamic> getAdmins() {
    return _request(
      'GET',
      '/admin/admins',
    );
  }

  Future<dynamic> addAdmin({
    required String name,
    required String phone,
    required String password,
  }) {
    return _request(
      'POST',
      '/admin/admins',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
      },
    );
  }

  Future<dynamic> removeAdmin(int id) {
    return _request(
      'DELETE',
      '/admin/admins/$id',
    );
  }

  // =========================================================
  // إعدادات الاستلام والتحويل
  // =========================================================

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
    String? method,
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
        if (method != null)
          'method': method,
      },
    );
  }

  // =========================================================
  // أسعار الإعلانات
  // =========================================================

  Future<dynamic> getPlanPrices() {
    return _request(
      'GET',
      '/admin/plan-prices',
    );
  }

  Future<dynamic> updatePlanPrices({
    required int normal,
    required int featured,
    required int vip,
  }) {
    return _request(
      'PUT',
      '/admin/plan-prices',
      body: {
        'normal': normal,
        'featured': featured,
        'vip': vip,
      },
    );
  }
}
