import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

const Color _pink = Color(0xFFFF176F);
const Color _pink2 = Color(0xFFFF4FA0);
const Color _blue = Color(0xFF1597FF);
const Color _blue2 = Color(0xFF55C7FF);
const Color _bg = Color(0xFF060810);
const Color _surface = Color(0xFF0C111C);
const Color _surface2 = Color(0xFF111827);

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
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }

    try {
      final result = await widget.api.getCars();
      final parsed = result
          .whereType<Map>()
          .map((item) => Car.fromJson(Map<String, dynamic>.from(item)))
          .where((c) => c.status == 'approved' || c.status == 'active' || c.status.isEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        cars = parsed.take(12).toList();
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'تعذر تحميل السيارات حالياً';
        });
      }
    }
  }

  String _price(int value) {
    final text = value.toString();
    final formatted = text.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '\$$formatted';
  }

  Widget _glass({
    required Widget child,
    BorderRadius radius = const BorderRadius.all(Radius.circular(22)),
    Color? borderColor,
    EdgeInsets padding = const EdgeInsets.all(14),
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.white.withOpacity(.075),
                _surface.withOpacity(.94),
              ],
            ),
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(.09),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.35),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        _iconButton(Icons.notifications_none_rounded, _pink),
        const Spacer(),
        Column(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [_pink2, _blue2],
              ).createShader(bounds),
              child: const Text(
                'ZYOCAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.2,
                ),
              ),
            ),
            const Text(
              'CAR MARKET',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 7,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ],
        ),
        const Spacer(),
        _iconButton(Icons.search_rounded, _blue),
      ],
    );
  }

  Widget _iconButton(IconData icon, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(.10),
            blurRadius: 14,
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _hero() {
    final featured = cars.isNotEmpty ? cars.first : null;

    return Container(
      height: 214,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF4E1439), Color(0xFF15172A), Color(0xFF081727)],
        ),
        border: Border.all(color: _pink.withOpacity(.65)),
        boxShadow: [
          BoxShadow(
            color: _pink.withOpacity(.13),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -35,
            bottom: -55,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_blue.withOpacity(.24), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: -25,
            top: -45,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [_pink.withOpacity(.25), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            right: 17,
            top: 17,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: _pink,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(color: _pink.withOpacity(.45), blurRadius: 16),
                ],
              ),
              child: const Text(
                'إعلان مميز',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 56,
            left: 145,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  featured == null ? 'ZYOCAR' : '${featured.brand} ${featured.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'سيارات مختارة • جودة تستحقها',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 11),
                if (featured != null)
                  Text(
                    _price(featured.price),
                    style: const TextStyle(
                      color: _blue2,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            left: 12,
            bottom: 8,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..setEntry(3, 2, .001)..rotateY(-.035),
              child: featured?.image != null && featured!.image!.isNotEmpty
                  ? Container(
                      width: 180,
                      height: 125,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: _blue.withOpacity(.18),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Image.network(
                        widget.api.imageUrl(featured.image!),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.directions_car_filled_rounded,
                          color: Colors.white,
                          size: 100,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 110,
                    ),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: ElevatedButton(
              onPressed: widget.onOpenCars,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 10,
                shadowColor: _blue.withOpacity(.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('اكتشف الآن'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: _glass(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          borderColor: color.withOpacity(.30),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(.95), color.withOpacity(.25)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(.25), blurRadius: 16),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 25),
              ),
              const SizedBox(height: 9),
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 9)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title, {VoidCallback? onTap}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (onTap != null)
          TextButton(
            onPressed: onTap,
            child: const Text(
              'عرض الكل',
              style: TextStyle(color: _pink, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _brand({required String name, required IconData icon}) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_surface2, _surface],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 12, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _carCard(Car car) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CarDetailsScreen(car: car, api: widget.api)),
      ),
      child: Container(
        width: 252,
        margin: const EdgeInsets.only(left: 13, bottom: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [_surface2, _surface],
          ),
          borderRadius: BorderRadius.circular(23),
          border: Border.all(
            color: car.isVip ? _pink.withOpacity(.75) : Colors.white.withOpacity(.09),
          ),
          boxShadow: [
            BoxShadow(
              color: car.isVip ? _pink.withOpacity(.12) : Colors.black.withOpacity(.35),
              blurRadius: 20,
              offset: const Offset(0, 11),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 155,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.image == null || car.image!.isEmpty
                      ? Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF172033), Color(0xFF090D15)],
                            ),
                          ),
                          child: const Icon(Icons.directions_car_filled_rounded, color: _blue2, size: 78),
                        )
                      : Image.network(
                          widget.api.imageUrl(car.image!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.directions_car_filled_rounded, color: _blue2, size: 78),
                        ),
                  Positioned(
                    left: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.60),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        car.city,
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (car.isVip)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [_pink, _pink2]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: _pink.withOpacity(.4), blurRadius: 12)],
                        ),
                        child: const Text('VIP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 11, 13, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(_price(car.price), style: const TextStyle(color: _pink2, fontSize: 17, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      Text('${car.year}', style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text('${car.km.toString()} كم', style: const TextStyle(color: Colors.white38, fontSize: 10)),
                      const Spacer(),
                      const Icon(Icons.favorite_border_rounded, color: _pink2, size: 19),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _carsSection() {
    if (loading) {
      return const SizedBox(
        height: 285,
        child: Center(child: CircularProgressIndicator(color: _pink)),
      );
    }

    if (error != null) {
      return _glass(
        child: Column(
          children: [
            Text(error!, style: const TextStyle(color: Colors.white70)),
            TextButton(onPressed: _loadCars, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }

    if (cars.isEmpty) {
      return _glass(
        child: const SizedBox(
          height: 140,
          child: Center(child: Text('ماكو سيارات منشورة حالياً', style: TextStyle(color: Colors.white54))),
        ),
      );
    }

    return SizedBox(
      height: 288,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        itemBuilder: (_, i) => _carCard(cars[i]),
      ),
    );
  }

  Widget _reelsPreview() {
    return GestureDetector(
      onTap: widget.onOpenCars,
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(23),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF29102B), Color(0xFF101A2B)],
          ),
          border: Border.all(color: _blue.withOpacity(.35)),
          boxShadow: [BoxShadow(color: _blue.withOpacity(.08), blurRadius: 20)],
        ),
        child: Stack(
          children: [
            Positioned(right: 18, top: 16, child: Container(width: 62, height: 62, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [_pink.withOpacity(.7), Colors.transparent])))),
            const Positioned(right: 18, top: 24, child: Text('REELS', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: 2))),
            const Positioned(right: 18, top: 54, child: Text('شوف السيارات بفيديو قصير', style: TextStyle(color: Colors.white60, fontSize: 10))),
            Positioned(left: 17, top: 18, child: Container(width: 82, height: 91, decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(18), border: Border.all(color: _pink.withOpacity(.45))), child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 38))),
            Positioned(left: 111, bottom: 17, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: _pink, borderRadius: BorderRadius.circular(13), boxShadow: [BoxShadow(color: _pink.withOpacity(.35), blurRadius: 14)]), child: const Text('شاهد الآن', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10)))),
          ],
        ),
      ),
    );
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
            backgroundColor: _surface,
            onRefresh: _loadCars,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 35),
              children: [
                _header(),
                const SizedBox(height: 17),
                _hero(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _quickAction(
                      icon: Icons.storefront_rounded,
                      title: 'المعارض',
                      subtitle: 'معارض السيارات',
                      color: _blue,
                      onTap: () => _message('المعارض متصلة بالسيرفر'),
                    ),
                    const SizedBox(width: 10),
                    _quickAction(
                      icon: Icons.build_circle_rounded,
                      title: 'قطع الغيار',
                      subtitle: 'محلات وقطع',
                      color: _pink,
                      onTap: () => _message('قطع الغيار متصلة بالسيرفر'),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _sectionTitle('تصفح حسب الماركة'),
                SizedBox(
                  height: 83,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      _BrandStatic(name: 'تويوتا', icon: Icons.directions_car_filled_rounded),
                      _BrandStatic(name: 'هيونداي', icon: Icons.directions_car_filled_rounded),
                      _BrandStatic(name: 'بي إم دبليو', icon: Icons.directions_car_filled_rounded),
                      _BrandStatic(name: 'مرسيدس', icon: Icons.directions_car_filled_rounded),
                      _BrandStatic(name: 'كيا', icon: Icons.directions_car_filled_rounded),
                      _BrandStatic(name: 'أودي', icon: Icons.directions_car_filled_rounded),
                    ],
                  ),
                ),
                const SizedBox(height: 19),
                _sectionTitle('سيارات مميزة', onTap: widget.onOpenCars),
                _carsSection(),
                const SizedBox(height: 17),
                _reelsPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }
}

class _BrandStatic extends StatelessWidget {
  const _BrandStatic({required this.name, required this.icon});

  final String name;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_surface2, _surface],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.35), blurRadius: 12, offset: const Offset(0, 7)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 25),
          const SizedBox(height: 6),
          Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
