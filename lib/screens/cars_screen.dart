import 'package:flutter/material.dart';

import '../models/car.dart' hide ApiService, ApiException;
import '../services/api_service.dart';
import '../widgets/car_brand_logo.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _loading = true;
  String? _error;
  List<Car> _cars = [];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      final data = await widget.api.getCars();
      final cars = data.whereType<Map>().map((item) => Car.fromJson(Map<String, dynamic>.from(item))).toList();
      if (!mounted) return;
      setState(() => _cars = cars);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'تعذر تحميل السيارات');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _price(int value) {
    final text = value.toString();
    return '\$${text.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  void _openCar(Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111116),
      isScrollControlled: true,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [CarBrandLogo(brand: car.brand, size: 54), const SizedBox(width: 12), Expanded(child: Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900))) ]),
                const SizedBox(height: 14),
                _detail('السنة', car.year.toString()),
                _detail('السعر', _price(car.price)),
                _detail('الموقع', car.city),
                if (car.description.isNotEmpty) _detail('الوصف', car.description),
                if (car.sellerPhone != null) Padding(padding: const EdgeInsets.only(top: 14), child: ElevatedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.phone_rounded), label: Text(car.sellerPhone!), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detail(String title, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [Text('$title: ', style: const TextStyle(color: Colors.white38)), Expanded(child: Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))) ]),
  );

  Widget _image(Car car) {
    if (car.image != null && car.image!.isNotEmpty) {
      return Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _brandFallback(car));
    }
    return _brandFallback(car);
  }

  Widget _brandFallback(Car car) => Container(
    color: const Color(0xFF0C1421),
    alignment: Alignment.center,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      CarBrandLogo(brand: car.brand, size: 78),
      const SizedBox(height: 8),
      Text(car.brand, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w800)),
      const Text('صورة السيارة غير متوفرة', style: TextStyle(color: Colors.white30, fontSize: 10)),
    ]),
  );

  Widget _card(Car car) => GestureDetector(
    onTap: () => _openCar(car),
    child: Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF292932))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(height: 205, child: Stack(fit: StackFit.expand, children: [
          _image(car),
          Positioned(top: 10, right: 10, child: CarBrandLogo(brand: car.brand, size: 48, background: Colors.black54)),
          if (car.isVip) Positioned(top: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFF176F), borderRadius: BorderRadius.circular(20)), child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)))),
          Positioned(bottom: 10, left: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)), child: Text(_price(car.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))),
        ])),
        Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(spacing: 7, runSpacing: 7, children: [
            _chip(Icons.calendar_month_rounded, car.year.toString()),
            _chip(Icons.location_on_rounded, car.city),
          ]),
        ])),
      ]),
    ),
  );

  Widget _chip(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(color: const Color(0xFF202027), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: const Color(0xFFFF176F)), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.white60, fontSize: 11))]),
  );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF176F)))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, color: Colors.white38, size: 45), const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 10), ElevatedButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]))
              : RefreshIndicator(
                  color: const Color(0xFFFF176F),
                  onRefresh: _loadCars,
                  child: _cars.isEmpty
                      ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [SizedBox(height: 180), Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54)))])
                      : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), itemCount: _cars.length, itemBuilder: (_, i) => _card(_cars[i])),
                ),
    );
  }
}
