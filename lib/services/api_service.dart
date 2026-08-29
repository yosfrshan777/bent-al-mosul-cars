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

  try {
    // 1️⃣ رفع الصور أولاً
    final uploadRequest = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload/car-images'),
    );

    uploadRequest.headers.addAll(_headers);

    for (final image in images) {
      uploadRequest.files.add(
        await http.MultipartFile.fromPath(
          'images',
          image.path,
          filename: image.name,
        ),
      );
    }

    final uploadStream = await uploadRequest.send();

    final uploadResponse =
        await http.Response.fromStream(uploadStream);

    dynamic uploadData;

    if (uploadResponse.body.trim().isNotEmpty) {
      try {
        uploadData = jsonDecode(uploadResponse.body);
      } catch (_) {}
    }

    if (uploadResponse.statusCode < 200 ||
        uploadResponse.statusCode >= 300) {
      String message = 'تعذر رفع صور السيارة';

      if (uploadData is Map) {
        final value =
            uploadData['message'] ?? uploadData['error'];

        if (value != null) {
          message = value.toString();
        }
      }

      throw ApiException(
        message,
        statusCode: uploadResponse.statusCode,
      );
    }

    // 2️⃣ استخراج روابط الصور
    final List<String> imageUrls = [];

    if (uploadData is Map &&
        uploadData['images'] is List) {
      for (final item in uploadData['images']) {
        if (item is Map && item['url'] != null) {
          imageUrls.add(
            item['url'].toString(),
          );
        }
      }
    }

    if (imageUrls.isEmpty) {
      throw const ApiException(
        'تم رفع الصور لكن لم يتم استلام روابط الصور',
      );
    }

    // 3️⃣ إنشاء إعلان السيارة
    final data = await _request(
      'POST',
      '/cars',
      body: {
        'brand': brand,
        'model': model,
        'year': year,
        'price': price,
        'km': km,
        'city': city,
        'fuel': fuel,
        'transmission': transmission,
        'description': description,
        'plan': plan,
        'images': imageUrls,
      },
    );

    return data;
  } on SocketException {
    throw const ApiException(
      'لا يوجد اتصال بالسيرفر',
    );
  } on ApiException {
    rethrow;
  } catch (_) {
    throw const ApiException(
      'حدث خطأ أثناء نشر السيارة',
    );
  }
}
