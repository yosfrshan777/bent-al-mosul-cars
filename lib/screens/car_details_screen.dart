import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({super.key, required this.car, required this.api});

  final Car car;
  final ApiService api;

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  Widget _info(IconData icon, String title, String value) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFF292932))),
        child: Row(children: [
          Icon(icon, color: const Color(0xFFFF176F), size: 22),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            const SizedBox(height: 3),
            Text(value.isEmpty ? 'غير محدد' : value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ])),
        ]),
      );

  Widget _image() {
    if (car.image == null || car.image!.isEmpty) {
      return Container(color: const Color(0xFF202027), child: const Center(child: Icon(Icons.directions_car_filled_rounded, color: Color(0xFFFF176F), size: 90)));
    }
    return Image.network(api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF202027), child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.white38, size: 60))));
  }

  String _read(dynamic data, List<String> keys) {
    if (data is Map) {
      for (final key in keys) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty) return value.toString();
      }
      final results = data['Results'];
      if (results is List && results.isNotEmpty && results.first is Map) return _read(results.first, keys);
    }
    return '';
  }

  int _recallCount(dynamic data) {
    if (data is Map && data['results'] is List) return (data['results'] as List).length;
    if (data is Map && data['Results'] is List) return (data['Results'] as List).length;
    return 0;
  }

  Widget _nhtsaSection(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: api.getNhtsaVehicle(make: car.brand, model: car.model, year: car.year),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF101722), borderRadius: BorderRadius.circular(18)), child: const Row(children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1597FF))), SizedBox(width: 12), Text('جاري جلب بيانات السلامة...', style: TextStyle(color: Colors.white70))]));
        }
        if (snapshot.hasError || snapshot.data is! Map) return const SizedBox.shrink();
        final d = Map<String, dynamic>.from(snapshot.data as Map);
        final ratings = d['ratings'];
        final recalls = d['recalls'];
        final overall = _read(ratings, ['OverallRating', 'OverallRatingStars']);
        final frontal = _read(ratings, ['OverallFrontCrashRating', 'FrontCrashRating']);
        final side = _read(ratings, ['OverallSideCrashRating', 'SideCrashRating']);
        final rollover = _read(ratings, ['RolloverRating', 'Rollover']);
        final count = _recallCount(recalls);
        final variant = _read(d['variants'], ['VehicleDescription', 'Description']);
        final hasData = d['ratings_available'] == true || d['recalls_available'] == true;
        if (!hasData) return const SizedBox.shrink();

        Widget metric(String title, String value, IconData icon) => Expanded(child: Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(13)), child: Column(children: [Icon(icon, color: const Color(0xFF1597FF), size: 20), const SizedBox(height: 5), Text(value.isEmpty ? '-' : value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)), const SizedBox(height: 3), Text(title, style: const TextStyle(color: Colors.white38, fontSize: 9))])));

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF0D1C2B), Color(0xFF111722)]), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF1597FF).withOpacity(.35))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [const Icon(Icons.verified_user_rounded, color: Color(0xFF1597FF)), const SizedBox(width: 8), const Expanded(child: Text('السلامة والاستدعاءات', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900))), Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFF1597FF).withOpacity(.14), borderRadius: BorderRadius.circular(12)), child: const Text('NHTSA', style: TextStyle(color: Color(0xFF1597FF), fontSize: 10, fontWeight: FontWeight.w900)))]),
            if (variant.isNotEmpty) ...[const SizedBox(height: 8), Text(variant, style: const TextStyle(color: Colors.white54, fontSize: 10))],
            const SizedBox(height: 12),
            Row(children: [metric('التقييم العام', overall, Icons.star_rounded), const SizedBox(width: 7), metric('أمامي', frontal, Icons.car_crash_rounded), const SizedBox(width: 7), metric('جانبي', side, Icons.car_repair_rounded)]),
            const SizedBox(height: 7),
            Row(children: [metric('انقلاب', rollover, Icons.rotate_right_rounded), const SizedBox(width: 7), metric('الاستدعاءات', '$count', Icons.warning_amber_rounded), const Spacer()]),
            const SizedBox(height: 9),
            const Text('المعلومات مأخوذة من بيانات NHTSA الأمريكية وقد لا تمثل حالة السيارة في العراق أو سجلها المحلي.', style: TextStyle(color: Colors.white38, fontSize: 9, height: 1.5)),
          ]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(title: const Text('تفاصيل السيارة', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
        body: SafeArea(child: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
          SizedBox(height: 270, width: double.infinity, child: _image()),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [Expanded(child: Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900))), if (car.isVip) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF176F), borderRadius: BorderRadius.circular(20)), child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))]),
            const SizedBox(height: 10),
            Text('\$${_formatPrice(car.price)}', style: const TextStyle(color: Color(0xFFFF176F), fontSize: 25, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Row(children: [Expanded(child: _info(Icons.calendar_today_rounded, 'السنة', '${car.year}')), const SizedBox(width: 10), Expanded(child: _info(Icons.speed_rounded, 'الكيلومترات', '${car.km}'))]),
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _info(Icons.location_on_outlined, 'الموقع', car.city)), const SizedBox(width: 10), Expanded(child: _info(Icons.local_gas_station_rounded, 'الوقود', car.fuel))]),
            const SizedBox(height: 10),
            _info(Icons.settings_rounded, 'ناقل الحركة', car.transmission),
            const SizedBox(height: 20),
            _nhtsaSection(context),
            const SizedBox(height: 20),
            if (car.description.isNotEmpty) ...[const Text('الوصف', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8), Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(15)), child: Text(car.description, style: const TextStyle(color: Colors.white70, height: 1.7)))],
            const SizedBox(height: 20),
            if (car.sellerName != null || car.sellerPhone != null) ...[const Text('معلومات البائع', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 10), if (car.sellerName != null) _info(Icons.person_rounded, 'البائع', car.sellerName!), if (car.sellerPhone != null) Padding(padding: const EdgeInsets.only(top: 10), child: _info(Icons.phone_rounded, 'رقم الهاتف', car.sellerPhone!))],
            const SizedBox(height: 20),
            SizedBox(height: 54, child: ElevatedButton.icon(onPressed: () { if (car.sellerPhone == null || car.sellerPhone!.isEmpty) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رقم البائع غير متوفر'))); return; } ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('رقم البائع: ${car.sellerPhone}'))); }, icon: const Icon(Icons.phone_rounded), label: const Text('التواصل مع البائع', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))),
          ])),
        ])),
      ),
    );
  }
}
