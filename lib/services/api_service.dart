import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static final ApiService instance = ApiService._();

  // غيّر هذا الرابط بعد نشر السيرفر على Render.
  // مثال:
  // https://bent-al-mosul-cars.onrender.com
  static const String baseUrl =
      'https://bent-al-mosul-cars.onrender.com';

  String get _apiUrl => '$baseUrl/api';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<String?> getToken() async {
    final prefs = await _prefs;
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await _prefs;
    await prefs.setString('token', token);
  }

  Future<void> clearToken() async {
    final prefs = await _prefs;
    await prefs.remove('token');
    await prefs.remove('user');
  }

  Future<Map<String, String>> _headers({
    bool auth = false,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };

    if (auth) {
      final token = await getToken();

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  dynamic _decode(http.Response response) {
    try {
      if (response.body.isEmpty) {
        return <String, dynamic>{};
      }

      return jsonDecode(response.body);
    } catch (_) {
      return <String, dynamic>{
        'error': 'استجابة غير صالحة من السيرفر',
      };
    }
  }

  String _errorMessage(
    http.Response response,
    dynamic data,
  ) {
    if (data is Map && data['error'] != null) {
      return data['error'].toString();
    }

    if (response.statusCode == 401) {
      return 'يجب تسجيل الدخول';
    }

    if (response.statusCode == 403) {
      return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
    }

    if (response.statusCode == 404) {
      return 'المطلوب غير موجود';
    }

    if (response.statusCode >= 500) {
      return 'حدث خطأ في السيرفر';
    }

    return 'حدث خطأ، حاول مرة أخرى';
  }

  Future<dynamic> _get(
    String path, {
    bool auth = false,
    Map<String, String>? query,
  }) async {
    try {
      final uri = Uri.parse('$_apiUrl$path').replace(
        queryParameters: query,
      );

      final response = await http
          .get(
            uri,
            headers: await _headers(auth: auth),
          )
          .timeout(
            const Duration(seconds: 25),
          );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(response, data),
          response.statusCode,
        );
      }

      return data;
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    } on http.ClientException {
      throw ApiException(
        'تعذر الاتصال بالسيرفر',
        0,
      );
    }
  }

  Future<dynamic> _postJson(
    String path,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    try {
      final headers = await _headers(auth: auth);

      headers['Content-Type'] =
          'application/json; charset=UTF-8';

      final response = await http
          .post(
            Uri.parse('$_apiUrl$path'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(
            const Duration(seconds: 25),
          );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(response, data),
          response.statusCode,
        );
      }

      return data;
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    } on http.ClientException {
      throw ApiException(
        'تعذر الاتصال بالسيرفر',
        0,
      );
    }
  }

  // =========================================================
  // HEALTH
  // =========================================================

  Future<Map<String, dynamic>> health() async {
    final data = await _get('/health');

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // =========================================================
  // CONFIG
  // =========================================================

  Future<Map<String, dynamic>> getConfig() async {
    final data = await _get('/config');

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    final data = await _postJson(
      '/register',
      {
        'name': name.trim(),
        'phone': phone.trim(),
        'email': email?.trim() ?? '',
        'password': password,
      },
    );

    final result = Map<String, dynamic>.from(
      data as Map,
    );

    final token = result['token'];

    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }

    if (result['user'] != null) {
      final prefs = await _prefs;

      await prefs.setString(
        'user',
        jsonEncode(result['user']),
      );
    }

    return result;
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final data = await _postJson(
      '/login',
      {
        'login': login.trim(),
        'password': password,
      },
    );

    final result = Map<String, dynamic>.from(
      data as Map,
    );

    final token = result['token'];

    if (token is String && token.isNotEmpty) {
      await saveToken(token);
    }

    if (result['user'] != null) {
      final prefs = await _prefs;

      await prefs.setString(
        'user',
        jsonEncode(result['user']),
      );
    }

    return result;
  }

  // =========================================================
  // ME
  // =========================================================

  Future<Map<String, dynamic>> me() async {
    final data = await _get(
      '/me',
      auth: true,
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> logout() async {
    await clearToken();
  }

  // =========================================================
  // CARS
  // =========================================================

  Future<List<dynamic>> getCars({
    String? search,
    String? brand,
    String? city,
  }) async {
    final query = <String, String>{};

    if (search != null &&
        search.trim().isNotEmpty) {
      query['search'] = search.trim();
    }

    if (brand != null &&
        brand.trim().isNotEmpty) {
      query['brand'] = brand.trim();
    }

    if (city != null &&
        city.trim().isNotEmpty) {
      query['city'] = city.trim();
    }

    final data = await _get(
      '/cars',
      query: query.isEmpty ? null : query,
    );

    if (data is List) {
      return data;
    }

    if (data is Map &&
        data['cars'] is List) {
      return List<dynamic>.from(
        data['cars'],
      );
    }

    return <dynamic>[];
  }

  // =========================================================
  // RANDOM CARS
  // =========================================================

  Future<List<dynamic>> getRandomCars() async {
    final data = await _get(
      '/cars/random',
    );

    if (data is Map &&
        data['cars'] is List) {
      return List<dynamic>.from(
        data['cars'],
      );
    }

    return <dynamic>[];
  }

  // =========================================================
  // SINGLE CAR
  // =========================================================

  Future<Map<String, dynamic>> getCar(
    int id,
  ) async {
    final data = await _get(
      '/cars/$id',
    );

    return Map<String, dynamic>.from(
      data as Map,
    );
  }

  // =========================================================
  // MY CARS
  // =========================================================

  Future<List<dynamic>> getMyCars() async {
    final data = await _get(
      '/my-cars',
      auth: true,
    );

    if (data is Map &&
        data['cars'] is List) {
      return List<dynamic>.from(
        data['cars'],
      );
    }

    return <dynamic>[];
  }

  // =========================================================
  // ADD CAR
  // =========================================================

  Future<Map<String, dynamic>> addCar({
    required String brand,
    required String model,
    required int year,
    required int price,
    int km = 0,
    required String city,
    String fuel = '',
    String transmission = '',
    String description = '',
    int plan = 10000,
    File? image,
    String? publicNo,
  }) async {
    final token = await getToken();

    if (token == null ||
        token.isEmpty) {
      throw ApiException(
        'يجب تسجيل الدخول أولاً',
        401,
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiUrl/cars'),
      );

      request.headers['Accept'] =
          'application/json';

      request.headers['Authorization'] =
          'Bearer $token';

      request.fields['brand'] =
          brand.trim();

      request.fields['model'] =
          model.trim();

      request.fields['year'] =
          year.toString();

      request.fields['price'] =
          price.toString();

      request.fields['km'] =
          km.toString();

      request.fields['city'] =
          city.trim();

      request.fields['fuel'] =
          fuel;

      request.fields['transmission'] =
          transmission;

      request.fields['description'] =
          description.trim();

      request.fields['plan'] =
          plan.toString();

      if (publicNo != null &&
          publicNo.trim().isNotEmpty) {
        request.fields['public_no'] =
            publicNo.trim();
      }

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }

      final streamedResponse =
          await request.send().timeout(
                const Duration(seconds: 60),
              );

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        if (response.statusCode == 401) {
          await clearToken();
        }

        throw ApiException(
          _errorMessage(
            response,
            data,
          ),
          response.statusCode,
        );
      }

      return Map<String, dynamic>.from(
        data as Map,
      );
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    }
  }

  // =========================================================
  // PAYMENT / RECEIPT
  // =========================================================

  Future<Map<String, dynamic>> uploadPayment({
    required int amount,
    required String kind,
    int? carId,
    required File receipt,
    String reference = '',
  }) async {
    final token = await getToken();

    if (token == null ||
        token.isEmpty) {
      throw ApiException(
        'يجب تسجيل الدخول أولاً',
        401,
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiUrl/payments'),
      );

      request.headers['Accept'] =
          'application/json';

      request.headers['Authorization'] =
          'Bearer $token';

      request.fields['amount'] =
          amount.toString();

      request.fields['kind'] =
          kind;

      request.fields['reference'] =
          reference;

      if (carId != null) {
        request.fields['car_id'] =
            carId.toString();
      }

      request.files.add(
        await http.MultipartFile.fromPath(
          'receipt',
          receipt.path,
        ),
      );

      final streamedResponse =
          await request.send().timeout(
                const Duration(seconds: 60),
              );

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(
            response,
            data,
          ),
          response.statusCode,
        );
      }

      return Map<String, dynamic>.from(
        data as Map,
      );
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    }
  }

  // =========================================================
  // PARTS
  // =========================================================

  Future<List<dynamic>> getParts({
    String? city,
  }) async {
    final query = <String, String>{};

    if (city != null &&
        city.trim().isNotEmpty) {
      query['city'] = city.trim();
    }

    final data = await _get(
      '/parts',
      query: query.isEmpty ? null : query,
    );

    if (data is Map &&
        data['parts'] is List) {
      return List<dynamic>.from(
        data['parts'],
      );
    }

    return <dynamic>[];
  }

  // =========================================================
  // VIP SHOP
  // =========================================================

  Future<Map<String, dynamic>> createVipShop({
    required String shopName,
    required String ownerName,
    required String phone,
    required String city,
    String? email,
    File? logo,
  }) async {
    final token = await getToken();

    if (token == null ||
        token.isEmpty) {
      throw ApiException(
        'يجب تسجيل الدخول أولاً',
        401,
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiUrl/shops/vip'),
      );

      request.headers['Accept'] =
          'application/json';

      request.headers['Authorization'] =
          'Bearer $token';

      request.fields['shop_name'] =
          shopName.trim();

      request.fields['owner_name'] =
          ownerName.trim();

      request.fields['phone'] =
          phone.trim();

      request.fields['city'] =
          city.trim();

      request.fields['email'] =
          email?.trim() ?? '';

      if (logo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'logo',
            logo.path,
          ),
        );
      }

      final streamedResponse =
          await request.send().timeout(
                const Duration(seconds: 60),
              );

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(
            response,
            data,
          ),
          response.statusCode,
        );
      }

      return Map<String, dynamic>.from(
        data as Map,
      );
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    }
  }

  // =========================================================
  // ADD PART
  // =========================================================

  Future<Map<String, dynamic>> addPart({
    required String name,
    required int price,
    required String city,
    String description = '',
    File? image,
  }) async {
    final token = await getToken();

    if (token == null ||
        token.isEmpty) {
      throw ApiException(
        'يجب تسجيل الدخول أولاً',
        401,
      );
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_apiUrl/parts'),
      );

      request.headers['Accept'] =
          'application/json';

      request.headers['Authorization'] =
          'Bearer $token';

      request.fields['name'] =
          name.trim();

      request.fields['price'] =
          price.toString();

      request.fields['city'] =
          city.trim();

      request.fields['description'] =
          description.trim();

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            image.path,
          ),
        );
      }

      final streamedResponse =
          await request.send().timeout(
                const Duration(seconds: 60),
              );

      final response =
          await http.Response.fromStream(
        streamedResponse,
      );

      final data = _decode(response);

      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw ApiException(
          _errorMessage(
            response,
            data,
          ),
          response.statusCode,
        );
      }

      return Map<String, dynamic>.from(
        data as Map,
      );
    } on SocketException {
      throw ApiException(
        'لا يوجد اتصال بالإنترنت',
        0,
      );
    }
  }
}


// ===========================================================
// API EXCEPTION
// ===========================================================

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(
    this.message,
    this.statusCode,
  );

  @override
  String toString() {
    return message;
  }
}
