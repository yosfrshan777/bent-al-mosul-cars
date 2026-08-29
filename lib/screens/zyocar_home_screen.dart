import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);
const _bg = Color(0xFF060810);
const _card = Color(0xFF101724);

class ZyoCarHomeScreen extends StatefulWidget {
  const ZyoCarHomeScreen({super.key, required this.api, this.onOpenCars, this.onOpenShowrooms, this.onOpenParts, this.onAddCar});
  final ApiService api;
  final VoidCallback? onOpenCars;
  final VoidCallback? onOpenShowrooms;
  final VoidCallback? onOpenParts;
  final VoidCallback? onAddCar;
  @override State<ZyoCarHomeScreen> createState() => _ZyoCarHomeScreenState();
}

class _ZyoCarHomeScreenState extends State<ZyoCarHomeScreen> {
  List<Car> cars = [];
  bool loading = true;
  String? error;
  @override void initState() { super.initState(); _loadCars(); }
  Future<void> _loadCars() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.getCars();
      final parsed = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status == 'approved' || c.status == 'active' || c.status.isEmpty).toList();
      if (!mounted) return;
      setState(() { cars = parsed.take(12).toList(); loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { loading = false; error = e is ApiException ? e.message : 'تعذر تحميل السيارات حالياً'; });
    }
  }
  String _price(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    backgroundColor: _bg,
    body: SafeArea(child: RefreshIndicator(color: _pink, onRefresh: _loadCars, child: ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 30), children: [
      _header(), const SizedBox(height: 16), _hero(), const SizedBox(height: 14), _quickActions(), const SizedBox(height: 22),
      _title('سيارات مميزة'), const SizedBox(height: 10), _cars(), const SizedBox(height: 18), _reels(),
    ]))),
    floatingActionButton: FloatingActionButton(onPressed: widget.onAddCar, backgroundColor: _pink, foregroundColor: Colors.white, child: const Icon(Icons.add_rounded)),
  ));

  Widget _header() => Row(children: [
    _button(Icons.notifications_none_rounded, _pink), const Spacer(),
    Column(children: [ShaderMask(shaderCallback: (b) => const LinearGradient(colors: [_pink, Colors.white, _blue]).createShader(b), child: const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.5))), const Text('CAR MARKET', style: TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 3))]),
    const Spacer(), _button(Icons.search_rounded, _blue),
  ]);
  Widget _button(IconData icon, Color color) => Container(width: 44, height: 44, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(.38))), child: Icon(icon, color: Colors.white));

  Widget _hero() {
    final car = cars.isEmpty ? null : cars.first;
    return Container(height: 205, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(colors: [Color(0xFF42132F), Color(0xFF17182A), Color(0xFF071827)]), border: Border.all(color: _pink.withOpacity(.55))), child: Stack(children: [
      Positioned(right: 17, top: 15, child: _pill('إعلان مميز', _pink)),
      Positioned(right: 18, top: 54, left: 145, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(car == null ? 'ZYOCAR' : '${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 5), const Text('سيارات مختارة • جودة تستحقها', style: TextStyle(color: Colors.white70, fontSize: 10)), if (car != null) ...[const SizedBox(height: 10), Text(_price(car.price), style: const TextStyle(color: Color(0xFF62CFFF), fontSize: 18, fontWeight: FontWeight.w900))]])),
      Positioned(left: 8, bottom: 10, child: SizedBox(width: 185, height: 125, child: car?.image != null && car!.image!.isNotEmpty ? Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => _carIcon()) : _carIcon())),
      Positioned(left: 16, bottom: 15, child: ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white), child: const Text('اكتشف الآن'))),
    ]));
  }
  Widget _carIcon() => const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 95);
  Widget _pill(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)));

  Widget _quickActions() => Row(children: [
    Expanded(child: _quick(Icons.storefront_rounded, 'المعارض', 'معارض السيارات', _blue, widget.onOpenShowrooms)),
    const SizedBox(width: 10),
    Expanded(child: _quick(Icons.build_circle_rounded, 'قطع الغيار', 'محلات وقطع', _pink, widget.onOpenParts)),
  ]);
  Widget _quick(IconData icon, String title, String subtitle, Color color, VoidCallback? onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(height: 112, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: Colors.white)), const SizedBox(height: 7), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 8))])));

  Widget _title(String text) => Row(children: [Text(text, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: widget.onOpenCars, child: const Text('عرض الكل', style: TextStyle(color: _blue)))]);

  Widget _cars() {
    if (loading) return const SizedBox(height: 275, child: Center(child: CircularProgressIndicator(color: _pink)));
    if (error != null) return Container(height: 130, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(error!, style: const TextStyle(color: Colors.white70)), TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]));
    if (cars.isEmpty) return Container(height: 130, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))));
    return SizedBox(height: 285, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => _carCard(cars[i])));
  }
  Widget _carCard(Car car) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))), borderRadius: BorderRadius.circular(23), child: Container(width: 250, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF151C2A), borderRadius: BorderRadius.circular(23), border: Border.all(color: car.isVip ? _pink.withOpacity(.7) : Colors.white.withOpacity(.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: 155, child: Stack(fit: StackFit.expand, children: [car.image == null || car.image!.isEmpty ? const ColoredBox(color: Color(0xFF0C1421), child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75)) : Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75)), Positioned(left: 9, top: 9, child: _pill(car.city, Colors.black87)), if (car.isVip) Positioned(right: 9, top: 9, child: _pill('VIP', _pink))])),
    Padding(padding: const EdgeInsets.fromLTRB(13, 10, 13, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 5), Row(children: [Text(_price(car.price), style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54))]), const SizedBox(height: 6), Text('${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10))]))
  ]));

  Widget _reels() => InkWell(onTap: widget.onOpenCars, child: Container(height: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF2A102A), Color(0xFF101B2C)]), border: Border.all(color: _blue.withOpacity(.28))), child: Stack(children: [const Positioned(right: 17, top: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text('REELS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('شوف السيارات بفيديو قصير', style: TextStyle(color: Colors.white54, fontSize: 10))])), Positioned(left: 16, top: 15, child: Container(width: 85, height: 90, decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 38)))]));
}
