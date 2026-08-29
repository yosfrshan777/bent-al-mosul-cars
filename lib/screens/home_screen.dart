import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const Color _pink = Color(0xFFFF176F);
const Color _blue = Color(0xFF1597FF);
const Color _bg = Color(0xFF060810);
const Color _card = Color(0xFF101724);
const Color _card2 = Color(0xFF151C2A);

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
    this.onOpenCars,
    this.onAddCar,
    this.onLogin,
  });

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
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = await widget.api.getCars();
      final parsed = result
          .whereType<Map>()
          .map((e) => Car.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.status == 'approved' || c.status == 'active' || c.status.isEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        cars = parsed.take(12).toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'تعذر تحميل السيارات حالياً';
      });
    }
  }

  String _price(int value) {
    final text = value.toString();
    return '\$${text.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: RefreshIndicator(
            color: _pink,
            backgroundColor: _card,
            onRefresh: _loadCars,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 30),
              children: [
                _header(),
                const SizedBox(height: 16),
                _hero(),
                const SizedBox(height: 14),
                _quickActions(),
                const SizedBox(height: 22),
                _sectionTitle('تصفح حسب الماركة', showAll: true),
                const SizedBox(height: 10),
                _brands(),
                const SizedBox(height: 22),
                _sectionTitle('سيارات مميزة', showAll: true),
                const SizedBox(height: 10),
                _carsSection(),
                const SizedBox(height: 18),
                _reelsBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _topButton(Icons.notifications_none_rounded, _pink),
        const Spacer(),
        Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(colors: [_pink, Colors.white, _blue]).createShader(bounds),
              child: const Text(
                'ZYOCAR',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 2.5),
              ),
            ),
            const Text('CAR MARKET', style: TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 3)),
          ],
        ),
        const Spacer(),
        _topButton(Icons.search_rounded, _blue),
      ],
    );
  }

  Widget _topButton(IconData icon, Color glow) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: glow.withOpacity(.38)),
        boxShadow: [BoxShadow(color: glow.withOpacity(.12), blurRadius: 16)],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _hero() {
    final featured = cars.isNotEmpty ? cars.first : null;
    return Container(
      height: 205,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF42132F), Color(0xFF17182A), Color(0xFF071827)],
        ),
        border: Border.all(color: _pink.withOpacity(.55)),
        boxShadow: [BoxShadow(color: _pink.withOpacity(.14), blurRadius: 28)],
      ),
      child: Stack(
        children: [
          Positioned(right: -45, top: -65, child: _glowCircle(_pink)),
          Positioned(left: -45, bottom: -70, child: _glowCircle(_blue)),
          Positioned(
            right: 17,
            top: 15,
            child: _pill('إعلان مميز', _pink),
          ),
          Positioned(
            right: 18,
            top: 54,
            left: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  featured == null ? 'ZYOCAR' : '${featured.brand} ${featured.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text('سيارات مختارة • جودة تستحقها', style: TextStyle(color: Colors.white70, fontSize: 10)),
                if (featured != null) ...[
                  const SizedBox(height: 10),
                  Text(_price(featured.price), style: const TextStyle(color: Color(0xFF62CFFF), fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ],
            ),
          ),
          Positioned(
            left: 8,
            bottom: 10,
            child: SizedBox(
              width: 185,
              height: 125,
              child: featured?.image != null && featured!.image!.isNotEmpty
                  ? Image.network(widget.api.imageUrl(featured.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => _carIcon())
                  : _carIcon(),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 15,
            child: ElevatedButton(
              onPressed: widget.onOpenCars,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 8,
                shadowColor: _blue.withOpacity(.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: const Text('اكتشف الآن', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glowCircle(Color color) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(.25), Colors.transparent])),
    );
  }

  Widget _pill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: color.withOpacity(.4), blurRadius: 14)]),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _carIcon() => const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 100);

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(child: _quickCard(Icons.storefront_rounded, 'المعارض', 'معارض السيارات', _blue)),
        const SizedBox(width: 10),
        Expanded(child: _quickCard(Icons.build_circle_rounded, 'قطع الغيار', 'محلات وقطع', _pink)),
      ],
    );
  }

  Widget _quickCard(IconData icon, String title, String subtitle, Color color) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => _message(title),
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [_card2, _card]),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(.25)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withOpacity(.25)]),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 7),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 8)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {bool showAll = false}) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        if (showAll)
          TextButton(
            onPressed: widget.onOpenCars,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(60, 30)),
            child: const Text('عرض الكل', style: TextStyle(color: _blue, fontSize: 12, fontWeight: FontWeight.w800)),
          ),
      ],
    );
  }

  Widget _brands() {
    const brands = [
      ('تويوتا', 'TOYOTA', _pink),
      ('هيونداي', 'H', _blue),
      ('بي إم دبليو', 'BMW', _blue),
      ('مرسيدس', 'MB', _pink),
      ('كيا', 'KIA', _blue),
      ('أودي', 'AUDI', _pink),
    ];
    return SizedBox(
      height: 126,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _brandCircle(brands[i].$1, brands[i].$2, brands[i].$3),
      ),
    );
  }

  Widget _brandCircle(String name, String mark, Color glow) {
    return InkWell(
      borderRadius: BorderRadius.circular(52),
      onTap: () => _message(name),
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF111B2A), Color(0xFF0B111C)]),
                border: Border.all(color: glow.withOpacity(.32), width: 1.4),
                boxShadow: [BoxShadow(color: glow.withOpacity(.10), blurRadius: 18)],
              ),
              child: Center(
                child: Text(mark, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 7),
            Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _carsSection() {
    if (loading) return const SizedBox(height: 275, child: Center(child: CircularProgressIndicator(color: _pink)));
    if (error != null) {
      return Container(
        height: 130,
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(error!, style: const TextStyle(color: Colors.white70)), TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة'))]),
      );
    }
    if (cars.isEmpty) return Container(height: 130, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))));

    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _carCard(cars[i]),
      ),
    );
  }

  Widget _carCard(Car car) {
    return InkWell(
      borderRadius: BorderRadius.circular(23),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))),
      child: Container(
        width: 250,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [_card2, _card]),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: car.isVip ? _pink.withOpacity(.7) : Colors.white.withOpacity(.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 155,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.image == null || car.image!.isEmpty
                      ? const ColoredBox(color: Color(0xFF0C1421), child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75))
                      : Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75)),
                  Positioned(left: 9, top: 9, child: _pill(car.city, Colors.black87)),
                  if (car.isVip) Positioned(right: 9, top: 9, child: _pill('VIP', _pink)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(children: [Text(_price(car.price), style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 6),
                  Row(children: [const Icon(Icons.speed_rounded, color: Colors.white38, size: 14), const SizedBox(width: 4), Text('${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10)), const Spacer(), const Icon(Icons.favorite_border_rounded, color: _pink, size: 19)]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reelsBanner() {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: widget.onOpenCars,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF2A102A), Color(0xFF101B2C)]),
          border: Border.all(color: _blue.withOpacity(.28)),
        ),
        child: Stack(
          children: [
            Positioned(right: 17, top: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [const Text('REELS', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)), const SizedBox(height: 4), const Text('شوف السيارات بفيديو قصير', style: TextStyle(color: Colors.white54, fontSize: 10))])),
            Positioned(left: 16, top: 15, child: Container(width: 85, height: 90, decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18), border: Border.all(color: _pink.withOpacity(.35))), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 38))),
            Positioned(left: 114, bottom: 16, child: _pill('شاهد الآن', _pink)),
          ],
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text('فتح قسم $text')));
  }
}
