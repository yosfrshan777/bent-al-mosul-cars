import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, this.onOpenCars, this.onAddCar, this.onLogin});
  final ApiService api;
  final VoidCallback? onOpenCars;
  final VoidCallback? onAddCar;
  final VoidCallback? onLogin;
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> cars = [];
  bool loading = true;
  String? error;

  @override void initState() { super.initState(); _loadCars(); }

  Future<void> _loadCars() async {
    setState(() { loading = true; error = null; });
    try {
      final result = await widget.api.getCars();
      final parsed = result.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status == 'approved' || c.status == 'active' || c.status.isEmpty).toList();
      if (!mounted) return;
      setState(() { cars = parsed.take(12).toList(); loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { loading = false; error = 'تعذر تحميل السيارات حالياً'; });
    }
  }

  String _price(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFEAF7FF), Color(0xFFFFE8F4), Color(0xFFDDF1FF), Color(0xFFFFEEF8)]),
          ),
          child: Stack(children: [
            const Positioned.fill(child: IgnorePointer(child: _Watermark())),
            SafeArea(child: RefreshIndicator(
              color: _pink,
              onRefresh: _loadCars,
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 32), children: [
                _header(), const SizedBox(height: 12), _search(), const SizedBox(height: 14), _hero(),
                const SizedBox(height: 14), _quickActions(), const SizedBox(height: 22),
                _title('الماركات', icon: Icons.local_fire_department_rounded), const SizedBox(height: 10), _brands(),
                const SizedBox(height: 20), _title('أحدث الإعلانات', icon: Icons.access_time_rounded), const SizedBox(height: 10), _carsSection(),
                const SizedBox(height: 20), _reels(),
              ]),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _header() => Row(children: [
    _circleButton(Icons.notifications_none_rounded, _pink),
    const Spacer(),
    Column(children: [
      ShaderMask(shaderCallback: (r) => const LinearGradient(colors: [_pink, _blue]).createShader(r), child: const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: 2.2))),
      const Text('بيع • شراء • معارض • قطع غيار', style: TextStyle(color: Color(0xFF536579), fontSize: 9, fontWeight: FontWeight.w800)),
    ]),
    const Spacer(),
    _circleButton(Icons.location_on_outlined, _blue),
  ]);

  Widget _circleButton(IconData icon, Color color) => Container(width: 45, height: 45, decoration: BoxDecoration(color: Colors.white.withOpacity(.72), shape: BoxShape.circle, border: Border.all(color: color.withOpacity(.35)), boxShadow: [BoxShadow(color: color.withOpacity(.12), blurRadius: 18)]), child: Icon(icon, color: const Color(0xFF17202D), size: 23));

  Widget _search() => Container(height: 57, padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: Colors.white.withOpacity(.70), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 18, offset: Offset(0, 6))]), child: Row(children: [const Icon(Icons.tune_rounded, color: _blue, size: 25), const SizedBox(width: 12), const Expanded(child: Text('ابحث عن سيارة، ماركة، موديل...', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFF738196), fontSize: 14, fontWeight: FontWeight.w600))), const Icon(Icons.search_rounded, color: Color(0xFF182536), size: 27)]));

  Widget _hero() {
    final car = cars.isNotEmpty ? cars.first : null;
    return Container(height: 235, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(borderRadius: BorderRadius.circular(28), gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFFFFB9D8), Color(0xFFE2D5FF), Color(0xFF8DD7FF)]), boxShadow: const [BoxShadow(color: Color(0x25007AFF), blurRadius: 25, offset: Offset(0, 10))]), child: Stack(children: [
      Positioned(right: -50, top: -55, child: _orb(_pink)), Positioned(left: -50, bottom: -65, child: _orb(_blue)),
      const Positioned(right: 18, top: 16, child: _badge('ZYOCAR', _pink)),
      const Positioned(right: 18, top: 58, child: Text('سيارات تستحقها', style: TextStyle(color: Color(0xFF172536), fontSize: 22, fontWeight: FontWeight.w900))),
      const Positioned(right: 18, top: 91, child: Text('اختار سيارتك من أحدث الإعلانات', style: TextStyle(color: Color(0xFF52657A), fontSize: 11, fontWeight: FontWeight.w700))),
      if (car != null) Positioned(right: 18, top: 122, child: Text(_price(car.price), style: const TextStyle(color: _pink, fontSize: 20, fontWeight: FontWeight.w900))),
      Positioned(left: 0, bottom: 5, child: SizedBox(width: 210, height: 145, child: car?.image != null && car!.image!.isNotEmpty ? Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, size: 105, color: Colors.white70)) : const Icon(Icons.directions_car_filled_rounded, size: 105, color: Colors.white70))),
      Positioned(right: 18, bottom: 15, child: ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, elevation: 6, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text('اكتشف الآن', style: TextStyle(fontWeight: FontWeight.w900)))),
    ]));
  }

  Widget _orb(Color color) => Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(.25), Colors.transparent])));
  Widget _badge(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 14)]), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)));

  Widget _quickActions() => Row(children: [
    Expanded(child: _quick(Icons.storefront_rounded, 'المعارض', 'أفضل المعارض', _pink)), const SizedBox(width: 10),
    Expanded(child: _quick(Icons.build_circle_rounded, 'قطع الغيار', 'قطع أصلية', _blue)),
  ]);

  Widget _quick(IconData icon, String title, String sub, Color color) => Container(height: 105, decoration: BoxDecoration(color: Colors.white.withOpacity(.68), borderRadius: BorderRadius.circular(23), border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 47, height: 47, decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [color, color.withOpacity(.55)]), boxShadow: [BoxShadow(color: color.withOpacity(.25), blurRadius: 12)]), child: Icon(icon, color: Colors.white, size: 25)), const SizedBox(height: 6), Text(title, style: const TextStyle(color: Color(0xFF172536), fontSize: 14, fontWeight: FontWeight.w900)), Text(sub, style: const TextStyle(color: Color(0xFF718096), fontSize: 9, fontWeight: FontWeight.w700))]));

  Widget _title(String text, {IconData? icon}) => Row(children: [if (icon != null) Icon(icon, color: _pink, size: 22), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Color(0xFF172536), fontSize: 20, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: widget.onOpenCars, child: const Text('عرض الكل', style: TextStyle(color: _blue, fontWeight: FontWeight.w900, fontSize: 11)))]);

  Widget _brands() {
    const data = [('مرسيدس', 'MB', _pink), ('BMW', 'BMW', _blue), ('تويوتا', 'T', _pink), ('هيونداي', 'H', _blue), ('كيا', 'K', _pink), ('أودي', 'A', _blue)];
    return SizedBox(height: 108, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: data.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) { final b = data[i]; return SizedBox(width: 76, child: Column(children: [Container(width: 72, height: 72, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(.78), border: Border.all(color: b.$3.withOpacity(.30)), boxShadow: [BoxShadow(color: b.$3.withOpacity(.12), blurRadius: 14)]), child: Center(child: Text(b.$2, style: const TextStyle(color: Color(0xFF202B38), fontWeight: FontWeight.w900, fontSize: 16)))), const SizedBox(height: 6), Text(b.$1, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4B5D70), fontSize: 9, fontWeight: FontWeight.w800))])); }));
  }

  Widget _carsSection() {
    if (loading) return const SizedBox(height: 255, child: Center(child: CircularProgressIndicator(color: _pink)));
    if (error != null) return Container(height: 110, decoration: _box(), child: Center(child: Text(error!, style: const TextStyle(color: Color(0xFF65758A)))));
    if (cars.isEmpty) return Container(height: 110, decoration: _box(), child: const Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Color(0xFF65758A)))));
    return SizedBox(height: 275, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => _carCard(cars[i])));
  }

  BoxDecoration _box() => BoxDecoration(color: Colors.white.withOpacity(.70), borderRadius: BorderRadius.circular(22), border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 16)]);

  Widget _carCard(Car car) => InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))), borderRadius: BorderRadius.circular(22), child: Container(width: 245, clipBehavior: Clip.antiAlias, decoration: _box(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(height: 158, child: Stack(fit: StackFit.expand, children: [car.image == null || car.image!.isEmpty ? const ColoredBox(color: Color(0xFFE9F4FB), child: Icon(Icons.directions_car_filled_rounded, color: Color(0xFF90A8BC), size: 75)) : Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: Color(0xFF90A8BC), size: 75)), Positioned(right: 9, top: 9, child: _badge(car.isVip ? 'VIP' : car.plan, car.isVip ? _pink : _blue)), Positioned(left: 9, top: 9, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(.90), borderRadius: BorderRadius.circular(15)), child: Text(car.city, style: const TextStyle(color: Color(0xFF536579), fontSize: 9, fontWeight: FontWeight.w800))))])), Padding(padding: const EdgeInsets.fromLTRB(12, 9, 12, 11), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF172536), fontSize: 16, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Row(children: [Text(_price(car.price), style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Color(0xFF63758A), fontSize: 11, fontWeight: FontWeight.w800))])]))]));

  Widget _reels() => Container(height: 92, padding: const EdgeInsets.symmetric(horizontal: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFD8E9), Color(0xFFCFEAFF)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white), boxShadow: const [BoxShadow(color: Color(0x15000000), blurRadius: 16)]), child: Row(children: [Container(width: 55, height: 55, decoration: const BoxDecoration(shape: BoxShape.circle, color: _pink), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 31)), const SizedBox(width: 12), const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('ريلز السيارات', style: TextStyle(color: Color(0xFF172536), fontSize: 16, fontWeight: FontWeight.w900)), Text('شوف السيارات بفيديوهات قصيرة', style: TextStyle(color: Color(0xFF65758A), fontSize: 10, fontWeight: FontWeight.w700))]), Icon(Icons.arrow_back_ios_new_rounded, color: _blue, size: 18)]));
}

class _Watermark extends StatelessWidget {
  const _Watermark();
  @override Widget build(BuildContext context) => Center(child: Transform.rotate(angle: -0.12, child: Text('ZYOCAR', style: TextStyle(color: Colors.white.withOpacity(.30), fontSize: 74, fontWeight: FontWeight.w900, letterSpacing: 5))));
}
