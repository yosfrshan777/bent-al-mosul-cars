import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

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
          .map(
            (item) => Car.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .where(
            (car) =>
                car.status == 'approved' ||
                car.status == 'active' ||
                car.status.isEmpty,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        cars = parsed.take(8).toList();
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

  String _formatPrice(int price) {
    final text = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  Widget _hero() {
    return Container(
      padding: const EdgeInsets.all(23),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF321222),
            Color(0xFF17171D),
            Color(0xFF101014),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF3A2631),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFFF176F),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'بنت الموصل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            'للسيارات',
            style: TextStyle(
              color: Color(0xFFFF176F),
              fontSize: 27,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'منصة عراقية لبيع وشراء السيارات وقطع الغيار.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onOpenCars,
                icon: const Icon(Icons.search_rounded),
                label: const Text('تصفح السيارات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF176F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onAddCar,
                icon: const Icon(Icons.add_rounded),
                label: const Text('أضف سيارتك'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF44444E),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: const Color(0xFF28141F),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF176F),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _carCard(Car car) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CarDetailsScreen(
              car: car,
              api: widget.api,
            ),
          ),
        );
      },
      child: Container(
        width: 285,
        margin: const EdgeInsets.only(left: 13),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(
            color: const Color(0xFF292932),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 175,
              width: double.infinity,
              child: car.image != null &&
                      car.image!.isNotEmpty
                  ? Image.network(
                      widget.api.imageUrl(car.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Color(0xFFFF176F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFFFF176F),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          car.city,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Text(
                    '${_formatPrice(car.price)} د.ع',
                    style: const TextStyle(
                      color: Color(0xFFFF176F),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFF202027),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          color: Color(0xFFFF176F),
          size: 65,
        ),
      ),
    );
  }

  Widget _latestCars() {
    if (loading) {
      return const SizedBox(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF176F),
          ),
        ),
      );
    }

    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white38,
              size: 45,
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            TextButton(
              onPressed: _loadCars,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (cars.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              color: Colors.white30,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'لا توجد سيارات مضافة حالياً',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        itemBuilder: (_, index) =>
            _carCard(cars[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080B),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFFF176F),
          backgroundColor: const Color(0xFF15151B),
          onRefresh: _loadCars,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              35,
            ),
            children: [
              _hero(),

              const SizedBox(height: 15),

              Row(
                children: [
                  _action(
                    icon: Icons.directions_car_rounded,
                    title: 'السيارات',
                    subtitle: 'تصفح الإعلانات',
                    onTap: widget.onOpenCars,
                  ),
                  const SizedBox(width: 10),
                  _action(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'بيع سيارتك',
                    subtitle: 'أضف إعلان جديد',
                    onTap: widget.onAddCar,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'أحدث السيارات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onOpenCars,
                    child: const Text(
                      'عرض الكل',
                      style: TextStyle(
                        color: Color(0xFFFF176F),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _latestCars(),
            ],
          ),
        ),
      ),
    );
  }
}
