import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  List<Car> cars = [];
  bool loading = true;
  String query = '';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() => loading = true);

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
        cars = parsed;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  List<Car> get filteredCars {
    if (query.trim().isEmpty) return cars;

    final q = query.toLowerCase();

    return cars.where((car) {
      return car.brand.toLowerCase().contains(q) ||
          car.model.toLowerCase().contains(q) ||
          car.city.toLowerCase().contains(q);
    }).toList();
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
    final visibleCars = filteredCars;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFFFCE7F2),
              Color(0xFFE4F2FF),
              Color(0xFFF6ECFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _header(),
              _searchBox(),
              const SizedBox(height: 12),
              Expanded(
                child: loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFFF3B8D),
                        ),
                      )
                    : visibleCars.isEmpty
                        ? _empty()
                        : RefreshIndicator(
                            color: const Color(0xFFFF3B8D),
                            onRefresh: _loadCars,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                30,
                              ),
                              itemCount: visibleCars.length,
                              itemBuilder: (_, index) {
                                return _carCard(
                                  visibleCars[index],
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF15151D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text(
                'ZY',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
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
                  'السيارات',
                  style: TextStyle(
                    color: Color(0xFF15151D),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'اكتشف سيارتك القادمة',
                  style: TextStyle(
                    color: Color(0xFF777783),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.75),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF25252D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.88),
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 18,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'ابحث عن الماركة أو الموديل أو المدينة',
            hintStyle: TextStyle(
              color: Color(0xFF8B8B96),
              fontSize: 12,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFFFF3B8D),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _carCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.90),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.065),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                height: 205,
                width: double.infinity,
                child: car.image != null &&
                        car.image!.isNotEmpty
                    ? Image.network(
                        widget.api.imageUrl(car.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _placeholder();
                        },
                      )
                    : _placeholder(),
              ),
              Positioned(
                top: 13,
                right: 13,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.72),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    car.isVip
                        ? 'VIP 👑'
                        : car.isFeatured
                            ? 'مميز ⭐'
                            : 'سيارة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF3B8D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '\$${_price(car.price)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${car.brand} ${car.model}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF15151D),
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.favorite_border_rounded,
                      color: Color(0xFFFF3B8D),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    _info(
                      Icons.calendar_month_rounded,
                      '${car.year}',
                    ),
                    const SizedBox(width: 7),
                    _info(
                      Icons.speed_rounded,
                      '${car.km} كم',
                    ),
                    const SizedBox(width: 7),
                    _info(
                      Icons.location_on_outlined,
                      car.city,
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _detail(
                        Icons.settings_rounded,
                        car.transmission.isEmpty
                            ? 'غير محدد'
                            : car.transmission,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _detail(
                        Icons.local_gas_station_rounded,
                        car.fuel.isEmpty
                            ? 'غير محدد'
                            : car.fuel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F6),
          borderRadius: BorderRadius.circular(10),
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
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF666672),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detail(IconData icon, String text) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF7A6CFF),
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF555561),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE8E8EF),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 70,
          color: Color(0xFF9A9AA5),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(25),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.75),
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 55,
              color: Color(0xFF9999A5),
            ),
            SizedBox(height: 12),
            Text(
              'ما لقينا سيارات',
              style: TextStyle(
                color: Color(0xFF555561),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
