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
      'https://YOUR-SERVER-DOMAIN.com/api';

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

    if (_token != null &&
        _token!.trim().isNotEmpty) {
      headers['Authorization'] =
          'Bearer $_token';
    }

    return headers;
  }

  Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse(
      '$baseUrl$path',
    );

    late http.Response response;

    try {
      final headers = {
        ..._headers,
        'Content-Type': 'application/json',
      };

      if (method == 'GET') {
        response = await http.get(
          uri,
          headers: headers,
        );
      } else if (method == 'POST') {
        response = await http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'PUT') {
        response = await http.put(
          uri,
          headers: headers,
          body: jsonEncode(body ?? {}),
        );
      } else if (method == 'DELETE') {
        response = await http.delete(
          uri,
          headers: headers,
        );
      } else {
        throw const ApiException(
          'طريقة الطلب غير مدعومة',
        );
      }
    } on SocketException {
      throw const ApiException(
        'لا يوجد اتصال بالسيرفر',
      );
    } on HttpException {
      throw const ApiException(
        'تعذر الاتصال بالسيرفر',
      );
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      throw const ApiException(
        'حدث خطأ في الاتصال بالسيرفر',
      );
    }

    dynamic data;

    try {
      if (response.body.trim().isNotEmpty) {
        data = jsonDecode(response.body);
      }
    } catch (_) {
      data = null;
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      String message =
          'حدث خطأ في السيرفر';

      if (data is Map) {
        final value =
            data['message'] ??
            data['error'];

        if (value != null &&
            value.toString().isNotEmpty) {
          message = value.toString();
        }
      }

      if (response.statusCode == 401) {
        clearToken();
        message =
            'انتهت جلسة الدخول، سجل دخولك من جديد';
      }

      throw ApiException(
        message,
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  Future<dynamic> login({
    required String phone,
    required String password,
  }) async {
    final data = await _request(
      'POST',
      '/auth/login',
      body: {
        'phone': phone,
        'password': password,
      },
    );

    if (data is Map) {
      final token =
          data['token'] ??
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
  }) async {
    final data = await _request(
      'POST',
      '/auth/register',
      body: {
        'name': name,
        'phone': phone,
        'password': password,
      },
    );

    if (data is Map) {
      final token =
          data['token'] ??
          data['access_token'];

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

    if (data is Map &&
        data['cars'] is List) {
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
    if (_token == null ||
        _token!.isEmpty) {
      throw const ApiException(
        'يجب تسجيل الدخول أولاً',
      );
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/cars'),
    );

    request.headers.addAll(
      _headers,
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
      final streamed =
          await request.send();

      final response =
          await http.Response.fromStream(
        streamed,
      );

      dynamic data;

      try {
        if (response.body
            .trim()
            .isNotEmpty) {
          data = jsonDecode(
            response.body,
          );
        }
      } catch (_) {}

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        String message =
            'تعذر نشر السيارة';

        if (data is Map) {
          final value =
              data['message'] ??
              data['error'];

          if (value != null) {
            message =
                value.toString();
          }
        }

        throw ApiException(
          message,
          statusCode:
              response.statusCode,
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
        'حدث خطأ أثناء رفع الصور',
      );
    }
  }

  Future<dynamic> getAdminData() async {
    return _request(
      'GET',
      '/admin/dashboard',
    );
  }

  Future<dynamic> getPendingRequests() async {
    return _request(
      'GET',
      '/admin/requests/pending',
    );
  }

  Future<dynamic> approveRequest(
    int id,
  ) async {
    return _request(
      'POST',
      '/admin/requests/$id/approve',
    );
  }

  Future<dynamic> rejectRequest(
    int id,
  ) async {
    return _request(
      'POST',
      '/admin/requests/$id/reject',
    );
  }

  Future<dynamic> getPaymentSettings() async {
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
  }) async {
    final body = <String, dynamic>{
      'phone': phone,
      'card_number': cardNumber,
      'account_name': accountName,
    };

    if (method != null) {
      body['method'] = method;
    }

    return _request(
      'PUT',
      '/admin/payment-settings',
      body: body,
    );
  }

  Future<dynamic> updatePlanPrices({
    required int normal,
    required int featured,
    required int vip,
  }) async {
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

  String imageUrl(String path) {
    if (path.startsWith('http://') ||
        path.startsWith('https://')) {
      return path;
    }

    if (path.startsWith('/')) {
      return '$baseUrl$path';
    }

    return '$baseUrl/$path';
  }
}
