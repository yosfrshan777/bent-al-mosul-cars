import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);
const _bg = Color(0xFF05070D);
const _panel = Color(0xFF0E1522);

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
      final parsed = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status.isEmpty || c.status == 'approved' || c.status == 'active').toList();
      if (!mounted) return;
      setState(() => cars = parsed);
    } on ApiException catch (e) {
      if (mounted) setState(() => error = e.message);
    } catch (_) {
      if (mounted) setState(() => error = 'تعذر تحميل السيارات');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _price(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Widget _image(Car car) {
    final image = car.image;
    if (image == null || image.isEmpty) {
      return const ColoredBox(color: Color(0xFF0B1420), child: Icon(Icons.directions_car_filled_rounded, color: Colors.white38, size: 72));
    }
    return Image.network(widget.api.imageUrl(image), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0B1420), child: Icon(Icons.directions_car_filled_rounded, color: Colors.white38, size: 72)));
  }

  Widget _card(Car car) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: car.isVip ? _pink.withOpacity(.72) : Colors.white.withOpacity(.08))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 210, child: Stack(fit: StackFit.expand, children: [
            _image(car),
            Positioned(top: 10, right: 10, child: _chip(car.city.isEmpty ? 'العراق' : car.city, Colors.black87)),
            if (car.isVip) Positioned(top: 10, left: 10, child: _chip('VIP', _pink)),
            Positioned(bottom: 10, left: 10, child: _chip(_price(car.price), Colors.black87)),
          ])),
          Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('${car.brand} ${car.model}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Row(children: [Text('${car.year}', style: const TextStyle(color: _blue, fontWeight: FontWeight.w800)), const SizedBox(width: 12), Text(car.city.isEmpty ? 'العراق' : car.city, style: const TextStyle(color: Colors.white54, fontSize: 12)), const Spacer(), const Text('دولار', style: TextStyle(color: Colors.white38, fontSize: 11))]),
          ])),
        ]),
      );

  Widget _chip(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)));

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: _bg,
          appBar: AppBar(backgroundColor: _bg, title: const Text('السيارات', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true, actions: [IconButton(onPressed: loading ? null : _loadCars, icon: const Icon(Icons.refresh_rounded, color: _blue))]),
          body: loading
              ? const Center(child: CircularProgressIndicator(color: _pink))
              : error != null
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(error!, style: const TextStyle(color: Colors.white70)), TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]))
                  : RefreshIndicator(color: _pink, onRefresh: _loadCars, child: cars.isEmpty ? ListView(children: const [SizedBox(height: 180), Center(child: Text('لا توجد سيارات منشورة حالياً', style: TextStyle(color: Colors.white54)))]) : ListView.builder(padding: const EdgeInsets.all(14), itemCount: cars.length, itemBuilder: (_, i) => _card(cars[i]))),
        ),
      );
}
