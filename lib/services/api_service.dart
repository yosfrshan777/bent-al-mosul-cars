import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});
  @override String toString() => message;
}

class ApiService {
  ApiService({String? baseUrl}) : baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/$'), '');
  static const String _defaultBaseUrl = 'https://bent-al-mosul-cars.onrender.com/api';
  static const String _tokenKey = 'zyocar_auth_token';
  final String baseUrl;
  String? _token;
  String get token => _token ?? '';
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  Future<void> initAuth() async { final prefs = await SharedPreferences.getInstance(); final savedToken = prefs.getString(_tokenKey); if (savedToken != null && savedToken.isNotEmpty) _token = savedToken; }
  Future<void> setToken(String token) async { _token = token; final prefs = await SharedPreferences.getInstance(); await prefs.setString(_tokenKey, token); }
  Future<void> clearToken() async { _token = null; final prefs = await SharedPreferences.getInstance(); await prefs.remove(_tokenKey); }

  Map<String, String> get _headers { final headers = <String, String>{'Accept':'application/json'}; if (isLoggedIn) headers['Authorization']='Bearer $_token'; return headers; }

  Future<dynamic> _request(String method, String path, {Map<String,dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    try {
      final headers = {..._headers, 'Content-Type':'application/json'};
      late http.Response response;
      switch (method) {
        case 'GET': response = await http.get(uri, headers: headers); break;
        case 'POST': response = await http.post(uri, headers: headers, body: jsonEncode(body ?? {})); break;
        case 'PUT': response = await http.put(uri, headers: headers, body: jsonEncode(body ?? {})); break;
        case 'DELETE': response = await http.delete(uri, headers: headers); break;
        default: throw const ApiException('طريقة الطلب غير مدعومة');
      }
      dynamic data;
      if (response.body.trim().isNotEmpty) { try { data = jsonDecode(response.body); } catch (_) {} }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message='حدث خطأ في السيرفر';
        if (data is Map && (data['message'] ?? data['error']) != null) message=(data['message'] ?? data['error']).toString();
        if (response.statusCode == 401) { await clearToken(); message='انتهت جلسة الدخول، يرجى تسجيل الدخول مرة أخرى'; }
        throw ApiException(message, statusCode: response.statusCode);
      }
      return data;
    } on SocketException { throw const ApiException('لا يوجد اتصال بالسيرفر'); }
    on HttpException { throw const ApiException('تعذر الاتصال بالسيرفر'); }
    on ApiException { rethrow; }
    catch (_) { throw const ApiException('حدث خطأ أثناء الاتصال بالسيرفر'); }
  }

  Future<dynamic> login({required String phone, required String password}) async { final data=await _request('POST','/auth/login',body:{'phone':phone.trim(),'password':password}); if(data is Map){final token=data['token']??data['access_token']; if(token!=null) await setToken(token.toString());} return data; }
  Future<dynamic> register({required String name,required String phone,required String password}) async { final data=await _request('POST','/auth/register',body:{'name':name.trim(),'phone':phone.trim(),'password':password}); if(data is Map){final token=data['token']??data['access_token']; if(token!=null) await setToken(token.toString());} return data; }
  Future<dynamic> me()=>_request('GET','/auth/me');
  Future<void> logout() async { try { await _request('POST','/auth/logout'); } finally { await clearToken(); } }
  Future<List<dynamic>> getCars() async { final data=await _request('GET','/cars'); if(data is List)return data; if(data is Map&&data['cars'] is List)return data['cars']; return []; }

  Future<dynamic> createCar({required String brand,required String model,required int year,required int price,required int km,required String city,required String fuel,required String transmission,required String description,required String plan,required List<XFile> images}) async {
    if(!isLoggedIn)throw const ApiException('يجب تسجيل الدخول أولاً');
    try {
      final uploadRequest=http.MultipartRequest('POST',Uri.parse('$baseUrl/upload/car-images')); uploadRequest.headers.addAll(_headers);
      for(final image in images){uploadRequest.files.add(await http.MultipartFile.fromPath('images',image.path,filename:image.name));}
      final uploadResponse=await uploadRequest.send(); final response=await http.Response.fromStream(uploadResponse); dynamic uploadData;
      if(response.body.trim().isNotEmpty){try{uploadData=jsonDecode(response.body);}catch(_){}}
      if(response.statusCode<200||response.statusCode>=300){String message='تعذر رفع صور السيارة';if(uploadData is Map){final v=uploadData['message']??uploadData['error'];if(v!=null)message=v.toString();}throw ApiException(message,statusCode:response.statusCode);}
      final imageUrls=<String>[]; if(uploadData is Map&&uploadData['images'] is List){for(final item in uploadData['images']){if(item is Map&&item['url']!=null)imageUrls.add(item['url'].toString());}}
      if(imageUrls.isEmpty)throw const ApiException('تم رفع الصور لكن لم يتم استلام روابط الصور');
      return _request('POST','/cars',body:{'brand':brand,'model':model,'year':year,'price':price,'km':km,'city':city,'fuel':fuel,'transmission':transmission,'description':description,'plan':plan,'images':imageUrls});
    } on SocketException { throw const ApiException('لا يوجد اتصال بالسيرفر'); } on ApiException { rethrow; } catch (_) { throw const ApiException('حدث خطأ أثناء نشر السيارة'); }
  }

  Future<dynamic> getAdminData()=>_request('GET','/admin/dashboard');
  Future<dynamic> getPendingRequests()=>_request('GET','/admin/requests/pending');
  Future<dynamic> approveRequest(int id)=>_request('POST','/admin/requests/$id/approve');
  Future<dynamic> rejectRequest(int id)=>_request('POST','/admin/requests/$id/reject');
  Future<dynamic> getPaymentSettings()=>_request('GET','/admin/payment-settings');
  Future<dynamic> updatePaymentSettings({required String phone,required String cardNumber,required String accountName,String? method})=>_request('PUT','/admin/payment-settings',body:{'phone':phone,'card_number':cardNumber,'account_name':accountName,'method':method??'card'});
  Future<dynamic> updatePlanPrices({required int normal,required int featured,required int vip})=>_request('PUT','/admin/plan-prices',body:{'normal':normal,'featured':featured,'vip':vip});
  Future<dynamic> getShowrooms()=>_request('GET','/showrooms');
  Future<dynamic> getShowroom(int id)=>_request('GET','/showrooms/$id');
  Future<dynamic> requestShowroom({required String name,required String phone,required String city})=>_request('POST','/showrooms/request',body:{'name':name,'phone':phone,'city':city});
  Future<dynamic> getParts()=>_request('GET','/parts');
  Future<dynamic> getPartStore(int id)=>_request('GET','/parts/$id');
  Future<dynamic> requestParts({required String name,required String phone,required String city})=>_request('POST','/parts/request',body:{'name':name,'phone':phone,'city':city});
  Future<dynamic> getConversations()=>_request('GET','/messages/conversations');
  Future<dynamic> getMessages(int userId)=>_request('GET','/messages/$userId');
  Future<dynamic> sendMessage({required int receiverId,required String text})=>_request('POST','/messages',body:{'receiver_id':receiverId,'text':text});

  Future<dynamic> createPayment({required int amount,required String method,String? phone,String? cardNumber,String? accountName,String? reference,String? discountCode})=>_request('POST','/payment',body:{'amount':amount,'method':method,'phone':phone,'card_number':cardNumber,'account_name':accountName,'reference':reference,'discount_code':discountCode});
  Future<dynamic> validateDiscount(String code)=>_request('POST','/discounts/validate',body:{'code':code.trim().toUpperCase()});
  Future<dynamic> getDiscountCodes()=>_request('GET','/discounts');
  Future<dynamic> createDiscount({required String code,required double percentage,int? maxUses,String? expiresAt})=>_request('POST','/discounts',body:{'code':code.trim().toUpperCase(),'percentage':percentage,'max_uses':maxUses,'expires_at':expiresAt});
  Future<dynamic> toggleDiscount(int id,bool active)=>_request('PUT','/discounts/$id/toggle',body:{'active':active});
  Future<dynamic> getMyPayments()=>_request('GET','/payment/mine');
  Future<dynamic> getAdminPayments()=>_request('GET','/payment/admin');
  Future<dynamic> approvePayment(int id)=>_request('POST','/payment/admin/$id/approve');
  Future<dynamic> rejectPayment(int id)=>_request('POST','/payment/admin/$id/reject');

  String imageUrl(String path){if(path.startsWith('http://')||path.startsWith('https://'))return path;if(path.startsWith('/'))return baseUrl.replaceFirst('/api','')+path;return baseUrl.replaceFirst('/api','')+'/$path';}
}
