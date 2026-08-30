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
  const ZyoCarHomeScreen({super.key, required this.api, this.onOpenCars, this.onOpenShowrooms, this.onAddCar});
  final ApiService api;
  final VoidCallback? onOpenCars;
  final VoidCallback? onOpenShowrooms;
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
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 110),
              children: [
                topBar(),
                const SizedBox(height: 14),
                hero(),
                const SizedBox(height: 14),
                showroomCard(),
                const SizedBox(height: 24),
                sectionTitle('تصفح السيارات', widget.onOpenCars),
                const SizedBox(height: 10),
                brands(),
                const SizedBox(height: 24),
                sectionTitle('إعلانات مميزة', widget.onOpenCars),
                const SizedBox(height: 10),
                carsView(),
                const SizedBox(height: 20),
                reelsBanner(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topBar() => Row(
        children: [
          actionButton(Icons.notifications_none_rounded, pink),
          const Spacer(),
          const ZyoCarLogo(size: 45, showWordmark: true),
          const Spacer(),
          actionButton(Icons.search_rounded, blue),
        ],
      );

  Widget actionButton(IconData icon, Color accent) => Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: panel,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: accent.withOpacity(.42)),
          boxShadow: [BoxShadow(color: accent.withOpacity(.10), blurRadius: 16)],
        ),
        child: Icon(icon, color: accent),
      );

  Widget hero() {
    final car = cars.isEmpty ? null : cars.first;
    return Container(
      height: 225,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF511333), Color(0xFF19172B), Color(0xFF071827)],
        ),
        border: Border.all(color: pink.withOpacity(.62)),
        boxShadow: [BoxShadow(color: pink.withOpacity(.13), blurRadius: 30)],
      ),
      child: Stack(children: [
        Positioned(right: -55, top: -70, child: glow(pink)),
        Positioned(left: -55, bottom: -70, child: glow(blue)),
        Positioned(right: 17, top: 16, child: pill('إعلان مميز', pink)),
        Positioned(right: 18, top: 57, left: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(car == null ? 'اكتشف سيارتك القادمة' : '${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 7),
          const Text('بيع وشراء السيارات في العراق', style: TextStyle(color: Colors.white70, fontSize: 12)),
          if (car != null) ...[
            const SizedBox(height: 9),
            Text(money(car.price), style: const TextStyle(color: Color(0xFF63D1FF), fontSize: 19, fontWeight: FontWeight.w900)),
          ],
          const SizedBox(height: 12),
          ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: pink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('اكتشف الآن', style: TextStyle(fontWeight: FontWeight.w900))),
        ])),
        if (car?.image != null && car!.image!.isNotEmpty)
          Positioned(left: -4, bottom: 0, child: SizedBox(width: 185, height: 145, child: Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: Colors.white54, size: 80)))),
      ]),
    );
  }

  Widget glow(Color color) => Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(.24), Colors.transparent])));

  Widget pill(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 14)]),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
      );

  Widget showroomCard() => InkWell(
        onTap: widget.onOpenShowrooms,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 112,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF101D30), Color(0xFF111522)]),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: blue.withOpacity(.34)),
          ),
          child: Row(children: [
            Container(width: 58, height: 58, decoration: BoxDecoration(color: blue.withOpacity(.14), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.storefront_rounded, color: blue, size: 31)),
            const SizedBox(width: 13),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('المعارض', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('تصفح معارض السيارات المعتمدة في العراق', textAlign: TextAlign.right, style: TextStyle(color: Colors.white54, fontSize: 10)),
            ])),
            const Icon(Icons.chevron_left_rounded, color: Colors.white38, size: 28),
          ]),
        ),
      );

  Widget sectionTitle(String title, VoidCallback? onTap) => Row(children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const Spacer(),
        TextButton(onPressed: onTap, child: const Text('عرض الكل', style: TextStyle(color: blue, fontWeight: FontWeight.w800))),
      ]);

  Widget brands() {
    const names = ['تويوتا', 'هيونداي', 'بي إم دبليو', 'مرسيدس', 'كيا', 'نيسان', 'أودي', 'فورد'];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (_, i) => Container(
          width: 84,
          padding: const EdgeInsets.symmetric(horizontal: 7),
          decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(19), border: Border.all(color: Colors.white.withOpacity(.08))),
          child: Center(child: Text(names[i], maxLines: 2, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w900))),
        ),
      ),
    );
  }

  Widget carsView() {
    if (loading) return const SizedBox(height: 275, child: Center(child: CircularProgressIndicator(color: pink)));
    if (error != null) return empty(error!, true);
    if (cars.isEmpty) return empty('لا توجد سيارات منشورة حالياً', false);
    return SizedBox(height: 276, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => carCard(cars[i])));
  }

  Widget empty(String text, bool retry) => Container(height: 135, decoration: BoxDecoration(color: panel, borderRadius: BorderRadius.circular(22)), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(text, style: const TextStyle(color: Colors.white54)), if (retry) TextButton(onPressed: loadCars, child: const Text('إعادة المحاولة'))])));

  Widget carCard(Car car) => InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))),
        borderRadius: BorderRadius.circular(23),
        child: Container(
          width: 250,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(color: panel2, borderRadius: BorderRadius.circular(23), border: Border.all(color: car.isVip ? pink.withOpacity(.75) : Colors.white.withOpacity(.09))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 155, child: Stack(fit: StackFit.expand, children: [
              Container(color: const Color(0xFF09111B)),
              if (car.image != null && car.image!.isNotEmpty) Image.network(widget.api.imageUrl(car.image!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: Colors.white38, size: 72)),
              Positioned(left: 9, top: 9, child: pill(car.city.isEmpty ? 'العراق' : car.city, Colors.black87)),
              if (car.isVip) Positioned(right: 9, top: 9, child: pill('VIP', pink)),
            ])),
            Padding(padding: const EdgeInsets.fromLTRB(13, 10, 13, 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              const SizedBox(height: 7),
              Row(children: [Text(money(car.price), style: const TextStyle(color: pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w700))]),
              const SizedBox(height: 7),
              const Text('السعر بالدولار • العراق', style: TextStyle(color: Colors.white38, fontSize: 9)),
            ])),
          ]),
        ),
      );

  Widget reelsBanner() => InkWell(
        onTap: widget.onOpenCars,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 108,
          padding: const EdgeInsets.symmetric(horizontal: 17),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2C102A), Color(0xFF0B1A2A)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: blue.withOpacity(.28))),
          child: Row(children: [
            Container(width: 57, height: 57, decoration: BoxDecoration(color: pink.withOpacity(.16), shape: BoxShape.circle), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34)),
            const SizedBox(width: 15),
            const Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('REELS', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
              SizedBox(height: 4),
              Text('شاهد سيارات العراق بفيديو قصير', style: TextStyle(color: Colors.white60, fontSize: 10)),
              SizedBox(height: 3),
              Text('عروض جديدة كل يوم', style: TextStyle(color: pink, fontSize: 9, fontWeight: FontWeight.w800)),
            ])),
          ]),
        ),
      );
}
