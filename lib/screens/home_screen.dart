import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';

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

      if (!mounted) return;

      setState(() {
        cars = result.take(6).toList();
        loading = false;
      });
    } catch (e) {
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

  Widget _buildCarCard(Car car) {
    return Container(
      width: 285,
      margin: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF292933),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 175,
              width: double.infinity,
              child: car.image != null &&
                      car.image!.isNotEmpty
                  ? Image.network(
                      widget.api.imageUrl(car.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return _imagePlaceholder();
                      },
                    )
                  : _imagePlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _infoChip(
                        Icons.calendar_today_rounded,
                        '${car.year}',
                      ),
                      const SizedBox(width: 6),
                      _infoChip(
                        Icons.location_on_outlined,
                        car.city,
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  Text(
                    '${_formatPrice(car.price)} د.ع',
                    style: const TextStyle(
                      color: Color(0xFFFF176F),
                      fontSize: 19,
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

  Widget _infoChip(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF202027),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: const Color(0xFFFF176F),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFF202027),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 70,
          color: Color(0xFFFF176F),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
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
          color: Color(0xFF3A2631),
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
              borderRadius:
                  BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.directions_car_filled_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'بنت الموصل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'للسيارات',
            style: TextStyle(
              color: Color(0xFFFF176F),
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'منصة عراقية حديثة لبيع وشراء السيارات وقطع الغيار.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.7,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: widget.onOpenCars,
                icon: const Icon(
                  Icons.search_rounded,
                ),
                label: const Text(
                  'تصفح السيارات',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF176F),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onAddCar,
                icon: const Icon(
                  Icons.add_rounded,
                ),
                label: const Text(
                  'أضف سيارتك',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF44444E),
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 13,
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            icon: Icons.directions_car_filled_rounded,
            title: 'السيارات',
            subtitle: 'تصفح الإعلانات',
            onTap: widget.onOpenCars,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _actionCard(
            icon: Icons.add_circle_outline_rounded,
            title: 'بيع سيارتك',
            subtitle: 'أضف إعلان جديد',
            onTap: widget.onAddCar,
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFF15151B),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
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
              const SizedBox(width: 10),
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
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLatestCars() {
    if (loading) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF176F),
          ),
        ),
      );
    }

    if (error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white54,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              error!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadCars,
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      );
    }

    if (cars.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius:
              BorderRadius.circular(18),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.directions_car_outlined,
              color: Colors.white38,
              size: 50,
            ),
            SizedBox(height: 10),
            Text(
              'لا توجد سيارات مضافة حالياً',
              style: TextStyle(
                color: Colors.white60,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 325,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return _buildCarCard(cars[index]);
        },
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
          backgroundColor:
              const Color(0xFF15151B),
          onRefresh: _loadCars,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              35,
            ),
            children: [
              _buildHero(),
              const SizedBox(height: 16),
              _buildQuickActions(),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'أحدث السيارات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
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
              const SizedBox(height: 10),
              _buildLatestCars(),
            ],
          ),
        ),
      ),
    );
  }
}
