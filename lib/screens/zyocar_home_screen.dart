import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const pink = Color(0xFFFF176F);
const blue = Color(0xFF149BFF);
const bg = Color(0xFF05070D);
const panel = Color(0xFF0D1420);
const panel2 = Color(0xFF111A28);

class ZyoCarHomeScreen extends StatefulWidget {
  const ZyoCarHomeScreen({super.key, required this.api, this.onOpenCars, this.onOpenShowrooms, this.onOpenParts, this.onAddCar});
  final ApiService api;
  final VoidCallback? onOpenCars;
  final VoidCallback? onOpenShowrooms;
  final VoidCallback? onOpenParts;
  final VoidCallback? onAddCar;

  @override
  State<ZyoCarHomeScreen> createState() => _ZyoCarHomeScreenState();
}

class _ZyoCarHomeScreenState extends State<ZyoCarHomeScreen> {
  List<Car> cars = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    try {
      final data = await widget.api.getCars();
      final parsed = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status.isEmpty || c.status == 'approved' || c.status == 'active').toList();
      if (mounted) {
        setState(() {
          cars = parsed.take(12).toList();
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'تعذر تحميل السيارات حالياً';
        });
      }
    }
  }

  String money(int value) => '\$${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: RefreshIndicator(
            color: pink,
            onRefresh: loadCars,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              children: [
                topBar(),
                const SizedBox(height: 18),
                hero(),
                const SizedBox(height: 14),
                quickActions(),
                const SizedBox(height: 24),
                sectionTitle('تصفح حسب الماركة', widget.onOpenCars),
                const SizedBox(height: 12),
                brands(),
                const SizedBox(height: 24),
                sectionTitle('سيارات مميزة', widget.onOpenCars),
                const SizedBox(height: 12),
                carsView(),
                const SizedBox(height: 22),
                reelsBanner(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: widget.onAddCar,
          backgroundColor: pink,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    );
  }

  Widget topBar() {
    return Row(
      children: [
        iconButton(Icons.notifications_none_rounded, pink),
        const Spacer(),
        Column(
          children: [
            const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
            const Text('CAR MARKET • IRAQ', style: TextStyle(color: Colors.white38, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 2.5)),
          ],
        ),
        const Spacer(),
        iconButton(Icons.search_rounded, blue),
      ],
    );
  }

  Widget iconButton(IconData icon, Color accent) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: accent.withOpacity(.45))),
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget hero() {
    final car = cars.isEmpty ? null : cars.first;
    return Container(
      height: 205,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFF3C1231), Color(0xFF17152A), Color(0xFF091725)]),
        border: Border.all(color: pink.withOpacity(.65)),
      ),
      child: Stack(
        children: [
          Positioned(right: 18, top: 17, child: tag('إعلان مميز', pink)),
          Positioned(
            right: 20,
            top: 55,
            left: 165,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(car == null ? 'اكتشف سيارتك القادمة' : '${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                const Text('بيع وشراء السيارات في العراق', style: TextStyle(color: Colors.white70, fontSize: 11)),
                if (car != null) ...[
                  const SizedBox(height: 10),
                  Text(money(car.price), style: const TextStyle(color: blue, fontSize: 19, fontWeight: FontWeight.w900)),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: widget.onOpenCars,
                  style: ElevatedButton.styleFrom(backgroundColor: pink, foregroundColor: Colors.white),
                  child: const Text('عرض المزيد'),
                ),
              ],
            ),
          ),
          if (car?.image != null && car!.image!.isNotEmpty)
            Positioned(
              left: 0,
              bottom: 0,
              child: SizedBox(width: 175, height: 140, child: Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain)),
            ),
        ],
      ),
    );
  }

  Widget tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget quickActions() {
    return Row(
      children: [
        Expanded(child: quick(Icons.storefront_rounded, 'المعارض', 'معارض السيارات', blue, widget.onOpenShowrooms)),
        const SizedBox(width: 10),
        Expanded(child: quick(Icons.settings_suggest_rounded, 'قطع الغيار', 'محلات وقطع', pink, widget.onOpenParts)),
      ],
    );
  }

  Widget quick(IconData icon, String title, String subtitle, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 112,
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(.35))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget sectionTitle(String title, VoidCallback? onTap) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: blue))),
      ],
    );
  }

  Widget brands() {
    const names = ['تويوتا', 'هيونداي', 'بي إم دبليو', 'مرسيدس', 'كيا', 'نيسان'];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          return Container(
            width: 82,
            decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car_filled_rounded, color: Colors.white70, size: 28),
                const SizedBox(height: 6),
                Text(names[index], textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget carsView() {
    if (loading) return const SizedBox(height: 270, child: Center(child: CircularProgressIndicator(color: pink)));
    if (error != null) return empty(error!, true);
    if (cars.isEmpty) return empty('لا توجد سيارات منشورة حالياً', false);
    return SizedBox(
      height: 285,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => carCard(cars[index]),
      ),
    );
  }

  Widget empty(String text, bool retry) {
    return Container(
      height: 140,
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)),
      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text, style: const TextStyle(color: Colors.white54)), if (retry) TextButton(onPressed: loadCars, child: const Text('إعادة المحاولة'))])),
    );
  }

  Widget carCard(Car car) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 248,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(22), border: Border.all(color: car.isVip ? pink : Colors.white12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 158,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(color: const Color(0xFF09111B)),
                  if (car.image != null && car.image!.isNotEmpty) Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover),
                  Positioned(left: 9, top: 9, child: tag(car.city, Colors.black87)),
                  if (car.isVip) Positioned(right: 9, top: 9, child: tag('VIP', pink)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  Row(children: [Text(money(car.price), style: const TextStyle(color: pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54))]),
                  const SizedBox(height: 6),
                  Text('${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget reelsBanner() {
    return InkWell(
      onTap: widget.onOpenCars,
      child: Container(
        height: 112,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2B1029), Color(0xFF0B1A2A)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: blue.withOpacity(.3))),
        child: const Row(
          children: [
            SizedBox(width: 18),
            Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 58),
            SizedBox(width: 16),
            Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('REELS', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('شاهد السيارات بفيديو قصير', style: TextStyle(color: Colors.white60, fontSize: 11)), SizedBox(height: 4), Text('اكتشف عروض جديدة كل يوم', style: TextStyle(color: pink, fontSize: 9, fontWeight: FontWeight.w800))])),
            SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}
