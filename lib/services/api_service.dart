import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(
    this.message, {
    this.statusCode,
  });

  @override
  String toString() => message;
}

class ApiService {
  ApiService({
    String? baseUrl,
  }) : baseUrl = (baseUrl ?? _defaultBaseUrl)
            .replaceFirst(RegExp(r'/$'), '');

  static const String _defaultBaseUrl =
      'https://bent-al-mosul-cars.onrender.com/api';

  final String baseUrl;

  String? _token;

  String get token => _token ?? '';

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$baseUrl$path');

    try {
      final headers = {
        ..._headers,
        'Content-Type': 'application/json',
      };

      late http.Response response;

      switch (method) {
        case 'GET':
          response = await http.get(
            uri,
            headers: headers,
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
            headers: headers,
          );
          break;

        default:
          throw const ApiException(
            'طريقة الطلب غير مدعومة',
          );
      }

      dynamic data;

      if (response.body.trim().isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } catch (_) {
          data = null;
        }
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        String message = 'حدث خطأ في السيرفر';

        if (data is Map) {
          final value =
              data['message'] ?? data['error'];

          if (value != null) {
            message = value.toString();
          }
        }

        if (response.statusCode == 401) {
          clearToken();
          message =
              'رقم الهاتف أو كلمة المرور غير صحيحة';
        }

        throw ApiException(
          message,
          statusCode: response.statusCode,
        );
      }

      return data;
    } on SocketException {
      throw const ApiException(
        'لا يوجد اتصال بالسيرفر',
      );
    } on HttpException {
      throw const ApiException(
        'تعذر الاتصال بالسيرفر',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'حدث خطأ أثناء الاتصال بالسيرفر',
      );
    }
  }

  Future<dynamic> login({
    required String phone,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {
        'phone': phone.trim(),
        'password': password,
      },
    );

    if (data is Map) {
      final token =
          data['token'] ?? data['access_token'];

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
  }) async {
    final data = await _request(
      'POST',
      '/auth/register',
      body: {
        'name': name.trim(),
        'phone': phone.trim(),
        'password': password,
      },
    );

    if (data is Map) {
      final token =
          data['token'] ?? data['access_token'];

      if (token != null) {
        setToken(token.toString());
      }
    }

    return data;
  }

  Future<dynamic> me() async {
    return _request(
      'GET',
      '/auth/me',
    );
  }

  Future<void> logout() async {
    try {
      await _request(
        'POST',
        '/auth/logout',
      );
    } finally {
      clearToken();
    }
  }

  Future<List<dynamic>> getCars() async {
    final data = await _request(
      'GET',
      '/cars',
    );

    if (data is List) {
      return data;
    }

    if (data is Map && data['cars'] is List) {
      return data['cars'];
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
    if (_token == null || _token!.isEmpty) {
      throw const ApiException(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/cars'),
    );

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
          filename: image.name,
        ),
      );
    }

    try {
      final streamed = await request.send();
      final response =
          await http.Response.fromStream(streamed);

      dynamic data;

      if (response.body.trim().isNotEmpty) {
        try {
          data = jsonDecode(response.body);
        } catch (_) {}
      }

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        String message = 'تعذر نشر السيارة';

        if (data is Map) {
          final value =
              data['message'] ?? data['error'];

          if (value != null) {
            message = value.toString();
          }
        }

        throw ApiException(
          message,
          statusCode: response.statusCode,
        );
      }

      return data;
    } on SocketException {
      throw const ApiException(
        'لا يوجد اتصال بالسيرفر',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'حدث خطأ أثناء رفع السيارة',
      );
    }
  }

  Future<dynamic> getAdminData() {
    return _request(
      'GET',
      '/admin/dashboard',
    );
  }

  Future<dynamic> getPendingRequests() {
    return _request(
      'GET',
      '/admin/requests/pending',
    );
  }

  Future<dynamic> approveRequest(int id) {
    return _request(
      'POST',
      '/admin/requests/$id/approve',
    );
  }

  Future<dynamic> rejectRequest(int id) {
    return _request(
      'POST',
      '/admin/requests/$id/reject',
    );
  }

  Future<dynamic> getPaymentSettings() {
    return _request(
      'GET',
      '/admin/payment-settings',
    );
  }

  Future<dynamic> updatePaymentSettings({
    required String phone,
    required String cardNumber,
    required String accountName,
    String? method,
  }) {
    return _request(
      'PUT',
      '/admin/payment-settings',
      body: {
        'phone': phone,
        'card_number': cardNumber,
        'account_name': accountName,
        'method': method ?? 'card',
      },
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

  Future<dynamic> getShowrooms() {
    return _request(
      'GET',
      '/showrooms',
    );
  }

  Future<dynamic> getShowroom(int id) {
    return _request(
      'GET',
      '/showrooms/$id',
    );
  }

  Future<dynamic> requestShowroom({
    required String name,
    required String phone,
    required String city,
  }) {
    return _request(
      'POST',
      '/showrooms/request',
      body: {
        'name': name,
        'phone': phone,
        'city': city,
      },
    );
  }

  Future<dynamic> getParts() {
    return _request(
      'GET',
      '/parts',
    );
  }

  Future<dynamic> getPartStore(int id) {
    return _request(
      'GET',
      '/parts/$id',
    );
  }

  Future<dynamic> requestParts({
    required String name,
    required String phone,
    required String city,
  }) {
    return _request(
      'POST',
      '/parts/request',
      body: {
        'name': name,
        'phone': phone,
        'city': city,
      },
    );
  }

  Future<dynamic> getConversations() {
    return _request(
      'GET',
      '/messages/conversations',
    );
  }

  Future<dynamic> getMessages(int userId) {
    return _request(
      'GET',
      '/messages/$userId',
    );
  }

  Future<dynamic> sendMessage({
    required int receiverId,
    required String text,
  }) {
    return _request(
      'POST',
      '/messages',
      body: {
        'receiver_id': receiverId,
        'text': text,
      },
    );
  }

  Future<dynamic> createPayment({
    required int amount,
    required String method,
    String? phone,
    String? cardNumber,
    String? accountName,
    String? reference,
  }) {
    return _request(
      'POST',
      '/payment',
      body: {
        'amount': amount,
        'method': method,
        'phone': phone,
        'card_number': cardNumber,
        'account_name': accountName,
        'reference': reference,
      },
    );
  }

  Future<dynamic> getMyPayments() {
    return _request(
      'GET',
      '/payment/mine',
    );
  }

  Future<dynamic> getAdminPayments() {
    return _request(
      'GET',
      '/payment/admin',
    );
  }

  Future<dynamic> approvePayment(int id) {
    return _request(
      'POST',
      '/payment/admin/$id/approve',
    );
  }

  Future<dynamic> rejectPayment(int id) {
    return _request(
      'POST',
      '/payment/admin/$id/reject',
    );
  }

  String imageUrl(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return baseUrl.replaceFirst('/api', '') + path;
    }

    return baseUrl.replaceFirst('/api', '') + '/$path';
  }
}
