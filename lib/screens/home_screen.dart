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

  final List<Map<String, dynamic>> brands = [
    {'name': 'Toyota', 'icon': Icons.directions_car_rounded},
    {'name': 'BMW', 'icon': Icons.sports_motorsports_rounded},
    {'name': 'Mercedes', 'icon': Icons.auto_awesome_rounded},
    {'name': 'Kia', 'icon': Icons.directions_car_filled_rounded},
    {'name': 'Hyundai', 'icon': Icons.car_repair_rounded},
    {'name': 'Nissan', 'icon': Icons.speed_rounded},
    {'name': 'Ford', 'icon': Icons.directions_car_rounded},
    {'name': 'Lexus', 'icon': Icons.star_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    try {
      final result = await widget.api.getCars();

      final parsed = result
          .whereType<Map>()
          .map(
            (item) => Car.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        cars = parsed.take(10).toList();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  String _price(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFCE7F2),
              Color(0xFFE4F2FF),
              Color(0xFFF5E9FF),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFFF3B8D),
            onRefresh: _loadCars,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
              children: [
                _topBar(),
                const SizedBox(height: 18),
                _search(),
                const SizedBox(height: 18),
                _specialSections(),
                const SizedBox(height: 24),
                _brandsTitle(),
                const SizedBox(height: 12),
                _brands(),
                const SizedBox(height: 24),
                _movingAd(),
                const SizedBox(height: 28),
                _sectionTitle(
                  'سيارات مميزة',
                  'عرض الكل',
                  widget.onOpenCars,
                ),
                const SizedBox(height: 12),
                _cars(),
                const SizedBox(height: 26),
                _sectionTitle(
                  'أحدث السيارات',
                  'كل السيارات',
                  widget.onOpenCars,
                ),
                const SizedBox(height: 12),
                _latestCars(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.88),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF3B8D).withOpacity(.22),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'ZY',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ZYO Car',
                style: TextStyle(
                  color: Color(0xFF111117),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'سياراتك تبدأ من هنا',
                style: TextStyle(
                  color: Color(0xFF656575),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _circleButton(Icons.notifications_none_rounded),
      ],
    );
  }

  Widget _circleButton(IconData icon) {
    return Container(
      width: 45,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
      ),
      child: Icon(
        icon,
        color: const Color(0xFF171720),
        size: 22,
      ),
    );
  }

  Widget _search() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.88),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 17),
          const Icon(
            Icons.search_rounded,
            color: Color(0xFFFF3B8D),
            size: 25,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'ابحث عن سيارة، ماركة أو موديل',
              style: TextStyle(
                color: Color(0xFF777783),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(7),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF3B8D),
                  Color(0xFF7A6CFF),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specialSections() {
    return Row(
      children: [
        Expanded(
          child: _specialCard(
            title: 'المعارض',
            subtitle: 'استكشف المعارض',
            icon: Icons.storefront_rounded,
            first: const Color(0xFFFF3B8D),
            second: const Color(0xFFFF79B1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _specialCard(
            title: 'قطع الغيار',
            subtitle: 'محلات وقطع',
            icon: Icons.build_circle_rounded,
            first: const Color(0xFF4A8CFF),
            second: const Color(0xFF71C8FF),
          ),
        ),
      ],
    );
  }

  Widget _specialCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color first,
    required Color second,
  }) {
    return Container(
      height: 128,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [first, second],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: first.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -15,
            bottom: -20,
            child: Icon(
              icon,
              size: 105,
              color: Colors.white.withOpacity(.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 43,
                  height: 43,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.23),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(.82),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _brandsTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'تصفح الماركات',
          style: TextStyle(
            color: Color(0xFF111117),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: widget.onOpenCars,
          child: const Text(
            'الكل',
            style: TextStyle(
              color: Color(0xFFFF3B8D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _brands() {
    return SizedBox(
      height: 105,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 11),
        itemBuilder: (_, index) {
          final brand = brands[index];

          return Container(
            width: 82,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.78),
              borderRadius: BorderRadius.circular(21),
              border: Border.all(
                color: Colors.white,
                width: 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.045),
                  blurRadius: 13,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF171720),
                        Color(0xFF343444),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    brand['icon'] as IconData,
                    color: Colors.white,
                    size: 23,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  brand['name'] as String,
                  style: const TextStyle(
                    color: Color(0xFF25252D),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _movingAd() {
    return Container(
      height: 116,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF111117),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF536DFF).withOpacity(.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -45,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF3B8D).withOpacity(.16),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4A8CFF).withOpacity(.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF3B8D),
                        Color(0xFF6E6BFF),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
                const SizedBox(width: 15),
                const Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إعلان مميز',
                        style: TextStyle(
                          color: Color(0xFFFF5FA4),
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'معرض ZYO Car',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'اكتشف أحدث السيارات الآن',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white70,
                  size: 17,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String action,
    VoidCallback? onTap,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111117),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            action,
            style: const TextStyle(
              color: Color(0xFFFF3B8D),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _cars() {
    if (loading) {
      return const SizedBox(
        height: 265,
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF3B8D),
          ),
        ),
      );
    }

    if (cars.isEmpty) {
      return _emptyCars();
    }

    return SizedBox(
      height: 292,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        separatorBuilder: (_, __) => const SizedBox(width: 13),
        itemBuilder: (_, index) => _carCard(cars[index]),
      ),
    );
  }

  Widget _latestCars() {
    if (loading || cars.isEmpty) {
      return _emptyCars();
    }

    return Column(
      children: cars.take(4).map(_wideCarCard).toList(),
    );
  }

  Widget _carCard(Car car) {
    return Container(
      width: 285,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.88),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.07),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 165,
                width: double.infinity,
                child: car.image != null && car.image!.isNotEmpty
                    ? Image.network(
                        widget.api.imageUrl(car.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _carPlaceholder(),
                      )
                    : _carPlaceholder(),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.72),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    car.isVip ? 'VIP 👑' : 'مميز ⭐',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF15151D),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _smallInfo(
                      Icons.calendar_month_rounded,
                      '${car.year}',
                    ),
                    const SizedBox(width: 7),
                    _smallInfo(
                      Icons.location_on_outlined,
                      car.city,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '\$${_price(car.price)}',
                  style: const TextStyle(
                    color: Color(0xFFFF3B8D),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideCarCard(Car car) {
    return Container(
      height: 112,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.86),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.055),
            blurRadius: 15,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(17),
            child: SizedBox(
              width: 120,
              height: double.infinity,
              child: car.image != null && car.image!.isNotEmpty
                  ? Image.network(
                      widget.api.imageUrl(car.image!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _carPlaceholder(),
                    )
                  : _carPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF15151D),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${car.year} • ${car.city}',
                  style: const TextStyle(
                    color: Color(0xFF777783),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${_price(car.price)}',
                  style: const TextStyle(
                    color: Color(0xFFFF3B8D),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFFB5B5BE),
            size: 15,
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F5),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: const Color(0xFFFF3B8D),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF666672),
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _carPlaceholder() {
    return Container(
      color: const Color(0xFFE8E8EF),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          color: Color(0xFF8B8B99),
          size: 55,
        ),
      ),
    );
  }

  Widget _emptyCars() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.72),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            color: Color(0xFF9B9BA6),
            size: 42,
          ),
          SizedBox(height: 8),
          Text(
            'لا توجد سيارات حالياً',
            style: TextStyle(
              color: Color(0xFF666672),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
