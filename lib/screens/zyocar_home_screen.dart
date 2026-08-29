import 'package:flutter/material.dart';
import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);
const _bg = Color(0xFF060810);
const _surface = Color(0xFF101724);

class ZyoCarHomeScreen extends StatefulWidget {
  const ZyoCarHomeScreen({super.key, required this.api, this.onOpenCars, this.onOpenShowrooms, this.onOpenParts, this.onAddCar});
  final ApiService api;
  final VoidCallback? onOpenCars, onOpenShowrooms, onOpenParts, onAddCar;
  @override State<ZyoCarHomeScreen> createState() => _ZyoCarHomeScreenState();
}

class _ZyoCarHomeScreenState extends State<ZyoCarHomeScreen> {
  List<Car> cars = [];
  bool loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await widget.api.getCars();
      final list = data.whereType<Map>().map((e) => Car.fromJson(Map<String, dynamic>.from(e))).toList();
      if (mounted) setState(() { cars = list.take(12).toList(); loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        body: RefreshIndicator(
          color: _pink,
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 100),
            children: [
              Row(children: [
                const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900)),
                const Spacer(),
                IconButton(onPressed: widget.onOpenCars, icon: const Icon(Icons.search_rounded, color: _blue)),
              ]),
              const SizedBox(height: 12),
              _hero(),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _action(Icons.storefront_rounded, 'المعارض', widget.onOpenShowrooms, _blue)),
                const SizedBox(width: 10),
                Expanded(child: _action(Icons.build_rounded, 'قطع الغيار', widget.onOpenParts, _pink)),
              ]),
              const SizedBox(height: 22),
              const Text('سيارات مميزة', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              _cars(),
              const SizedBox(height: 20),
              InkWell(
                onTap: widget.onOpenCars,
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22)),
                  child: const Center(child: Text('▶  شاهد السيارات بالفيديو REELS', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(onPressed: widget.onAddCar, backgroundColor: _pink, child: const Icon(Icons.add_rounded)),
      ),
    );
  }

  Widget _hero() => Container(
    height: 190,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF42132F), Color(0xFF101B2C)]), borderRadius: BorderRadius.circular(26)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('اكتشف سيارتك القادمة', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8),
      const Text('بيع وشراء السيارات في العراق', style: TextStyle(color: Colors.white70)),
      const SizedBox(height: 18),
      ElevatedButton(onPressed: widget.onOpenCars, style: ElevatedButton.styleFrom(backgroundColor: _pink), child: const Text('تصفح السيارات')),
    ]),
  );

  Widget _action(IconData icon, String title, VoidCallback? onTap, Color color) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: Container(height: 105, decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withOpacity(.3))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 38), const SizedBox(height: 7), Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900))])),
  );

  Widget _cars() {
    if (loading) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator(color: _pink)));
    if (cars.isEmpty) return const SizedBox(height: 120, child: Center(child: Text('لا توجد سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))));
    return SizedBox(height: 270, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: cars.length, separatorBuilder: (_, __) => const SizedBox(width: 12), itemBuilder: (_, i) => _car(cars[i])));
  }

  Widget _car(Car car) => InkWell(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api))),
    child: Container(
      width: 245,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: car.isVip ? _pink : Colors.white12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: car.image == null || car.image!.isEmpty ? const Center(child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75)) : Image.network(widget.api.imageUrl(car.image!), width: double.infinity, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 75)))),
        Text('${car.brand} ${car.model}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
        const SizedBox(height: 5),
        Row(children: [Text('\$${car.price}', style: const TextStyle(color: _pink, fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${car.year}', style: const TextStyle(color: Colors.white54))]),
        Text('${car.city} • ${car.km} كم', style: const TextStyle(color: Colors.white38, fontSize: 10)),
      ]),
    ),
  );
}
