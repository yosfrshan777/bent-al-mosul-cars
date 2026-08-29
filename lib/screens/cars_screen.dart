import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import '../widgets/car_brand_logo.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({super.key, required this.api});
  final ApiService api;
  @override State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool loading = true;
  String? error;
  List<Car> cars = [];

  @override void initState() { super.initState(); _loadCars(); }

  Future<void> _loadCars() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.getCars();
      if (!mounted) return;
      setState(() => cars = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).toList());
    } on ApiException catch (e) { if (mounted) setState(() => error = e.message); }
    catch (_) { if (mounted) setState(() => error = 'تعذر تحميل السيارات'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  String _price(int value) {
    final formatted = value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '\$$formatted';
  }

  Widget _image(Car car) {
    if (car.image != null && car.image!.isNotEmpty) {
      return Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _fallback(car));
    }
    return _fallback(car);
  }

  Widget _fallback(Car car) {
    return Container(
      color: const Color(0xFF0C1421),
      alignment: Alignment.center,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CarBrandLogo(brand: car.brand, size: 70),
        const SizedBox(height: 6),
        Text(car.brand, style: const TextStyle(color: Colors.white70)),
      ]),
    );
  }

  Widget _card(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: car.isVip ? const Color(0xFFFF176F) : Colors.white12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: 205,
          child: Stack(fit: StackFit.expand, children: [
            _image(car),
            Positioned(top: 10, right: 10, child: CarBrandLogo(brand: car.brand, size: 48, background: Colors.black54)),
            if (car.isVip)
              Positioned(top: 10, left: 10, child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFF176F), borderRadius: BorderRadius.circular(20)),
                child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              )),
            Positioned(bottom: 10, left: 10, child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
              child: Text(_price(car.price), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            )),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('${car.year} • ${car.city}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ]),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF07090F),
        appBar: AppBar(title: const Text('السيارات', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF176F)))
            : error != null
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!, style: const TextStyle(color: Colors.white70)), TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]))
                : RefreshIndicator(
                    color: const Color(0xFFFF176F),
                    onRefresh: _loadCars,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (cars.isEmpty)
                          const Padding(padding: EdgeInsets.only(top: 100), child: Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))))
                        else
                          ...cars.map(_card),
                      ],
                    ),
                  ),
      ),
    );
  }
}
