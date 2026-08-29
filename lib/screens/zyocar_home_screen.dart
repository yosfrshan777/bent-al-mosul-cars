import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import '../widgets/car_brand_logo.dart';
import '../widgets/zyocar_logo.dart';
import 'car_details_screen.dart';

const pink = Color(0xFFFF176F);
const blue = Color(0xFF1597FF);
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
    if (mounted) setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.getCars();
      final parsed = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).where((c) => c.status.isEmpty || c.status == 'approved' || c.status == 'active').toList();
      if (!mounted) return;
      setState(() { cars = parsed.take(12).toList(); loading = false; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر تحميل السيارات حالياً'; });
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
                const SizedBox(height: 10),
                brands(),
                const SizedBox(height: 24),
                sectionTitle('سيارات مميزة', widget.onOpenCars),
                const SizedBox(height: 10),
                carsView(),
                const SizedBox(height: 22),
                reelsBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topBar() {
    return Row(
      children: [
        actionButton(Icons.notifications_none_rounded, pink),
        const Spacer(),
        const ZyoCarLogo(size: 44, showWordmark: true),
        const Spacer(),
        actionButton(Icons.search_rounded, blue),
      ],
    );
  }

  Widget actionButton(IconData icon, Color accent) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(15), border: Border.all(color: accent.withOpacity(.45))),
      child: Icon(icon, color: accent),
    );
  }

  Widget hero() {
    final car = cars.isEmpty ? null : cars.first;
    return Container(
      height: 214,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF4A1237), Color(0xFF17152A), Color(0xFF081725)]),
        border: Border.all(color: pink.withOpacity(.65)),
      ),
      child: Stack(
        children: [
          Positioned(right: 18, top: 17, child: tag('إعلان مميز', pink)),
          Positioned(right: 20, top: 54, left: 155, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(car == null ? 'اكتشف سيارتك القادمة' : '${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 7),
            const Text('بيع وشراء السيارات في العراق', style: TextStyle(color: Colors.white70, fontSize: 11)),
            if (car != null) ...[const SizedBox(height: 10), Text(money(car.price), style: const TextStyle(color: blue, fontSize: 19, fontWeight: FontWeight.w900))],
            const SizedBox(height: 12),
            ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: pink, foregroundColor: Colors.white), child: const Text('عرض المزيد')),
          ])),
          if (car?.image != null && car!.image!.isNotEmpty)
            Positioned(left: 0, bottom: 0, child: SizedBox(width: 175, height: 140, child: Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()))),
        ],
      ),
    );
  }

  Widget tag(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)), child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)));

  Widget quickActions() {
    return Row(children: [
      Expanded(child: quick(Icons.storefront_rounded, 'المعارض', 'معارض السيارات', blue, widget.onOpenShowrooms)),
      const SizedBox(width: 10),
      Expanded(child: quick(Icons.build_circle_rounded, 'قطع الغيار', 'محلات وقطع', pink, widget.onOpenParts)),
    ]);
  }

  Widget quick(IconData icon, String title, String subtitle, Color color, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        height: 112,
        decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22), border: Border.all(color: color.withOpacity(.35))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color, size: 30)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
          const SizedBox(height: 3),
          Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ]),
      ),
    );
  }

  Widget sectionTitle(String title, VoidCallback? onTap) => Row(children: [Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const Spacer(), TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: blue)))]);

  Widget brands() {
    const names = ['تويوتا', 'هيونداي', 'بي إم دبليو', 'مرسيدس', 'كيا', 'نيسان', 'أودي', 'فورد'];
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, index) => SizedBox(width: 82, child: CarBrandLogo(brand: names[index], size: 55, background: panel, showName: true)),
      ),
    );
  }

  Widget carsView() {
    if (loading) return const SizedBox(height: 270, child: Center(child: CircularProgressIndicator(color: pink)));
    if (error != null) return empty(error!, true);
    if (cars.isEmpty) return empty('لا توجد سيارات منشورة حالياً', false);
    return SizedBox(height: 285, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, index) => carCard(cars[index])));
  }

  Widget empty(String text, bool retry) => Container(height: 140, decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text, style: const TextStyle(color: Colors.white54)), if (retry) TextButton(onPressed: loadCars, child: const Text('إعادة المحاولة'))])));

  Widget carCard(Car car) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 248,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(22), border: Border.all(color: car.isVip ? pink : Colors.white12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(height: 158, child: Stack(fit: StackFit.expand, children: [
            Container(color: const Color(0xFF09111B)),
            if (car.image != null && car.image!.isNotEmpty) Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
            Positioned(left: 9, top: 9, child: tag(car.city, Colors.black87)),
            if (car.isVip) Positioned(right: 9, top: 9, child: tag('VIP', pink)),
          ])),
          Padding(padding: const EdgeInsets.all(13), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 6),
            Row(children: [Text(money(car.price), style: const TextStyle(color: pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54))]),
            const SizedBox(height: 6),
            Text('${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10)),
          ])),
        ]),
      ),
    );
  }

  Widget reelsBanner() {
    return InkWell(
      onTap: widget.onOpenCars,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 112,
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2B1029), Color(0xFF0B1A2A)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: blue.withOpacity(.3))),
        child: Row(children: [
          const SizedBox(width: 18),
          Container(width: 58, height: 58, decoration: BoxDecoration(color: pink.withOpacity(.18), shape: BoxShape.circle), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34)),
          const SizedBox(width: 16),
          const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [Text('REELS', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)), SizedBox(height: 5), Text('شاهد السيارات بفيديو قصير', style: TextStyle(color: Colors.white60, fontSize: 11)), SizedBox(height: 4), Text('اكتشف عروض جديدة كل يوم', style: TextStyle(color: pink, fontSize: 9, fontWeight: FontWeight.w800))])),
          const SizedBox(width: 14),
        ]),
      ),
    );
  }
}
