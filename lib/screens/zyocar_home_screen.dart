import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF149BFF);
const _bg = Color(0xFF05070D);
const _panel = Color(0xFF0D1420);
const _panel2 = Color(0xFF111A28);

class ZyoCarHomeScreen extends StatefulWidget {
  const ZyoCarHomeScreen({super.key, required this.api, this.onOpenCars, this.onOpenShowrooms, this.onOpenParts, this.onAddCar});
  final ApiService api;
  final VoidCallback? onOpenCars, onOpenShowrooms, onOpenParts, onAddCar;
  @override State<ZyoCarHomeScreen> createState() => _ZyoCarHomeScreenState();
}

class _ZyoCarHomeScreenState extends State<ZyoCarHomeScreen> {
  List<Car> cars = [];
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getCars();
      final list = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status.isEmpty || c.status == 'approved' || c.status == 'active').toList();
      if (mounted) setState(() { cars = list.take(12).toList(); loading = false; });
    } catch (_) { if (mounted) setState(() { loading = false; error = 'تعذر تحميل السيارات حالياً'; }); }
  }

  String _money(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: _bg,
      body: SafeArea(child: RefreshIndicator(color: _pink, backgroundColor: _panel, onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 110), children: [
        _topBar(), const SizedBox(height: 18), _hero(), const SizedBox(height: 14), _quickActions(), const SizedBox(height: 24),
        _sectionTitle('تصفح حسب الماركة', widget.onOpenCars), const SizedBox(height: 12), _brands(), const SizedBox(height: 24),
        _sectionTitle('سيارات مميزة', widget.onOpenCars), const SizedBox(height: 12), _cars(), const SizedBox(height: 22), _reelsBanner(),
      ]))),
      floatingActionButton: FloatingActionButton(onPressed: widget.onAddCar, backgroundColor: _pink, foregroundColor: Colors.white, elevation: 10, child: const Icon(Icons.add_rounded, size: 32)),
    ),
  );

  Widget _topBar() => Row(children: [
    _smallButton(Icons.notifications_none_rounded, _pink), const Spacer(),
    Column(children: [ShaderMask(shaderCallback: (r) => const LinearGradient(colors: [_pink, Colors.white, _blue]).createShader(r), child: const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 2.5))), const Text('CAR MARKET • IRAQ', style: TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 2.5))]),
    const Spacer(), _smallButton(Icons.search_rounded, _blue),
  ]);

  Widget _smallButton(IconData icon, Color accent) => Container(width: 45, height: 45, decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: accent.withOpacity(.45))), child: Icon(icon, color: Colors.white, size: 24));

  Widget _hero() {
    final car = cars.isEmpty ? null : cars.first;
    return Container(height: 205, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF3C1231), Color(0xFF17152A), Color(0xFF091725)]), border: Border.all(color: _pink.withOpacity(.65))), child: Stack(children: [
      Positioned(right: -40, top: -55, child: Container(width: 170, height: 170, decoration: BoxDecoration(shape: BoxShape.circle, color: _pink.withOpacity(.10)))),
      Positioned(right: 18, top: 17, child: _tag('إعلان مميز', _pink)),
      Positioned(right: 20, top: 57, left: 170, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(car == null ? 'اكتشف سيارتك القادمة' : '${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
        const SizedBox(height: 7), const Text('بيع وشراء السيارات في العراق', style: TextStyle(color: Colors.white70, fontSize: 11)),
        if (car != null) ...[const SizedBox(height: 10), Text(_money(car.price), style: const TextStyle(color: _blue, fontSize: 19, fontWeight: FontWeight.w900))],
        const SizedBox(height: 12), ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: _pink, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('عرض المزيد', style: TextStyle(fontWeight: FontWeight.w900))),
      ])),
      if (car?.image != null && car!.image!.isNotEmpty) Positioned(left: 0, bottom: 0, child: SizedBox(width: 180, height: 145, child: Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()))),
    ]));
  }

  Widget _tag(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)));

  Widget _quickActions() => Row(children: [Expanded(child: _quick(Icons.storefront_rounded, 'المعارض', 'معارض السيارات', _blue, widget.onOpenShowrooms)), const SizedBox(width: 10), Expanded(child: _quick(Icons.settings_suggest_rounded, 'قطع الغيار', 'محلات وقطع', _pink, widget.onOpenParts))]);

  Widget _quick(IconData icon, String title, String sub, Color color, VoidCallback? onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(22), child: Container(height: 112, decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(.35))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withOpacity(.16), borderRadius: BorderRadius.circular(15)), child: Icon(icon, color: color, size: 28)), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)), const SizedBox(height: 2), Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 9))])));

  Widget _sectionTitle(String title, VoidCallback? onTap) => Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: _blue, fontWeight: FontWeight.w800)))]);

  Widget _brands() { const brands = ['تويوتا', 'هيونداي', 'بي إم دبليو', 'مرسيدس', 'كيا', 'نيسان']; return SizedBox(height: 88, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: brands.length, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) => Container(width: 82, decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white.withOpacity(.08))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24)), child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white70, size: 20)), const SizedBox(height: 6), Text(brands[i], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800))]))); }

  Widget _cars() { if (loading) return const SizedBox(height: 270, child: Center(child: CircularProgressIndicator(color: _pink))); if (error != null) return _empty(error!, retry: true); if (cars.isEmpty) return _empty('لا توجد سيارات منشورة حالياً'); return SizedBox(height: 285, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => _carCard(cars[i]))); }

  Widget _empty(String text, {bool retry = false}) => Container(height: 140, decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(22)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text, style: const TextStyle(color: Colors.white54)), if (retry) TextButton(onPressed: _load, child: const Text('إعادة المحاولة'))])));

  Widget _carCard(Car car) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))), borderRadius: BorderRadius.circular(22), child: Container(width: 248, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: _panel2, borderRadius: BorderRadius.circular(22), border: Border.all(color: car.isVip ? _pink.withOpacity(.7) : Colors.white.withOpacity(.08))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(height: 158, child: Stack(fit: StackFit.expand, children: [Container(color: const Color(0xFF09111B)), if (car.image != null && car.image!.isNotEmpty) Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()), Positioned(left: 9, top: 9, child: _tag(car.city, Colors.black87)), if (car.isVip) Positioned(right: 9, top: 9, child: _tag('VIP', _pink))])),
    Padding(padding: const EdgeInsets.fromLTRB(13, 10, 13, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 6), Row(children: [Text(_money(car.price), style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700))]), const SizedBox(height: 6), Text('${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10))]))
  ]));

  Widget _reelsBanner() => InkWell(onTap: widget.onOpenCars, borderRadius: BorderRadius.circular(24), child: Container(height: 112, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2B1029), Color(0xFF0B1A2A)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: _blue.withOpacity(.3))), child: Row(children: [const SizedBox(width: 18), Container(width: 76, height: 82, decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 42)), const SizedBox(width: 16), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('REELS', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('شاهد السيارات بفيديو قصير', style: TextStyle(color: Colors.white60, fontSize: 11)), SizedBox(height: 4), Text('اكتشف عروض جديدة كل يوم', style: TextStyle(color: _pink, fontSize: 9, fontWeight: FontWeight.w800))])), const SizedBox(width: 14)])));
}
