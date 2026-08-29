import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);
const _bg = Color(0xFF07090F);
const _card = Color(0xFF10141D);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, this.onOpenCars, this.onAddCar, this.onLogin});
  final ApiService api;
  final VoidCallback? onOpenCars;
  final VoidCallback? onAddCar;
  final VoidCallback? onLogin;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Car> cars = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final result = await widget.api.getCars();
      final parsed = result.whereType<Map>().map((item) => Car.fromJson(Map<String, dynamic>.from(item))).where((c) => c.status == 'approved' || c.status == 'active' || c.status.isEmpty).toList();
      if (!mounted) return;
      setState(() { cars = parsed.take(10).toList(); loading = false; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر تحميل السيارات حالياً'; });
    }
  }

  String _price(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  Widget _header() {
    return Row(
      children: [
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF171B26), borderRadius: BorderRadius.circular(13), border: Border.all(color: _pink.withOpacity(.55))), child: const Icon(Icons.notifications_none_rounded, color: Colors.white)),
        const Spacer(),
        const Column(children: [
          Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900, letterSpacing: 2)),
          Text('CAR MARKET', style: TextStyle(color: _blue, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 2)),
        ]),
        const Spacer(),
        Container(width: 42, height: 42, decoration: BoxDecoration(color: const Color(0xFF171B26), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.search_rounded, color: Colors.white)),
      ],
    );
  }

  Widget _hero() {
    return Container(
      height: 185,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF4B1538), Color(0xFF10141D)]),
        border: Border.all(color: _pink.withOpacity(.65)),
        boxShadow: [BoxShadow(color: _pink.withOpacity(.10), blurRadius: 25)],
      ),
      child: Stack(children: [
        Positioned(right: 18, top: 18, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(20)), child: const Text('إعلان', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)))),
        const Positioned(right: 18, top: 55, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('BMW M5 2024', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          SizedBox(height: 4),
          Text('امتلك الفخامة', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ])),
        Positioned(left: 18, bottom: 20, child: ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: _blue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('عرض المزيد'))),
        Positioned(left: 135, bottom: 18, child: Transform.rotate(angle: -.04, child: const Icon(Icons.directions_car_filled_rounded, size: 105, color: _pink))),
        Positioned(left: 75, bottom: 18, child: Icon(Icons.auto_awesome_rounded, size: 32, color: _blue.withOpacity(.75))),
      ]),
    );
  }

  Widget _category({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Expanded(child: Material(color: _card, borderRadius: BorderRadius.circular(20), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(height: 116, padding: const EdgeInsets.all(13), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.35))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 35), const SizedBox(height: 8), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 3), Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 10))])))));
  }

  Widget _sectionTitle(String title, VoidCallback? onTap) {
    return Row(children: [Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900))), TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: _pink)))]);
  }

  Widget _carCard(Car car) {
    return GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))), child: Container(width: 250, margin: const EdgeInsets.only(left: 12), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: car.isVip ? _pink.withOpacity(.75) : const Color(0xFF252B38))), clipBehavior: Clip.antiAlias, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(height: 155, width: double.infinity, child: Stack(fit: StackFit.expand, children: [
        car.image == null || car.image!.isEmpty ? const Center(child: Icon(Icons.directions_car_filled_rounded, color: _pink, size: 70)) : Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.directions_car_filled_rounded, color: _pink, size: 70))),
        if (car.isVip) Positioned(top: 9, right: 9, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5), decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(15)), child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)))),
      ])),
      Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)), const SizedBox(height: 7), Text(_price(car.price), style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text('${car.year} • ${car.city}', style: const TextStyle(color: Colors.white54, fontSize: 11))]))
    ]));
  }

  Widget _latest() {
    if (loading) return const SizedBox(height: 250, child: Center(child: CircularProgressIndicator(color: _pink)));
    if (error != null) return Container(padding: const EdgeInsets.all(25), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)), child: Column(children: [Text(error!, style: const TextStyle(color: Colors.white70)), TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]));
    if (cars.isEmpty) return Container(height: 180, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18)), child: const Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))));
    return SizedBox(height: 280, child: ListView.builder(scrollDirection: Axis.horizontal, itemCount: cars.length, itemBuilder: (_, i) => _carCard(cars[i])));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: _bg, body: SafeArea(child: RefreshIndicator(color: _pink, backgroundColor: _card, onRefresh: _loadCars, child: ListView(padding: const EdgeInsets.fromLTRB(16, 10, 16, 35), children: [
      _header(),
      const SizedBox(height: 18),
      _hero(),
      const SizedBox(height: 15),
      Row(children: [
        _category(icon: Icons.storefront_rounded, title: 'المعارض', subtitle: 'معارض السيارات', color: _blue, onTap: () => _message('المعارض متصلة بالسيرفر')),
        const SizedBox(width: 10),
        _category(icon: Icons.build_circle_rounded, title: 'قطع الغيار', subtitle: 'قطع غيار السيارات', color: _pink, onTap: () => _message('قطع الغيار متصلة بالسيرفر')),
      ]),
      const SizedBox(height: 24),
      _sectionTitle('تصنف حسب الماركة', widget.onOpenCars),
      SizedBox(height: 58, child: ListView(scrollDirection: Axis.horizontal, children: const [
        _BrandChip('تويوتا', Icons.directions_car_filled_rounded), _BrandChip('هيونداي', Icons.directions_car_filled_rounded), _BrandChip('بي إم دبليو', Icons.directions_car_filled_rounded), _BrandChip('مرسيدس', Icons.directions_car_filled_rounded), _BrandChip('كيا', Icons.directions_car_filled_rounded),
      ])),
      const SizedBox(height: 18),
      _sectionTitle('سيارات مميزة', widget.onOpenCars),
      _latest(),
    ]))));
  }

  void _message(String text) => ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
}

class _BrandChip extends StatelessWidget {
  const _BrandChip(this.name, this.icon);
  final String name;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(left: 9), padding: const EdgeInsets.symmetric(horizontal: 13), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFF273040))), child: Row(children: [Icon(icon, color: Colors.white70, size: 23), const SizedBox(width: 7), Text(name, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold))]));
}
