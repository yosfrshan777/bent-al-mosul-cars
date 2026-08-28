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
  String? error;

  String search = '';
  String selectedBrand = 'الكل';
  String selectedTransmission = 'الكل';

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
          .where((car) => car.status == 'approved')
          .toList();

      if (!mounted) return;

      setState(() {
        cars = parsed;
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

  List<Car> get filteredCars {
    return cars.where((car) {
      final q = search.trim().toLowerCase();

      final matchesSearch =
          q.isEmpty ||
          '${car.brand} ${car.model}'
              .toLowerCase()
              .contains(q) ||
          car.city.toLowerCase().contains(q);

      final matchesBrand =
          selectedBrand == 'الكل' ||
          car.brand == selectedBrand;

      final matchesTransmission =
          selectedTransmission == 'الكل' ||
          car.transmission == selectedTransmission;

      return matchesSearch &&
          matchesBrand &&
          matchesTransmission;
    }).toList();
  }

  List<String> get brands {
    final result = <String>{};

    for (final car in cars) {
      if (car.brand.trim().isNotEmpty) {
        result.add(car.brand);
      }
    }

    return [
      'الكل',
      ...result,
    ];
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadCars,
            color: const Color(0xFFFF4F91),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _header(),
                ),
                SliverToBoxAdapter(
                  child: _searchBox(),
                ),
                SliverToBoxAdapter(
                  child: _brands(),
                ),
                SliverToBoxAdapter(
                  child: _filters(),
                ),
                if (loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF4F91),
                      ),
                    ),
                  )
                else if (error != null)
                  SliverFillRemaining(
                    child: _error(),
                  )
                else if (filteredCars.isEmpty)
                  SliverFillRemaining(
                    child: _empty(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      30,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return _carCard(
                            filteredCars[index],
                          );
                        },
                        childCount: filteredCars.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 14,
                        childAspectRatio: .68,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        12,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF4F91),
                  Color(0xFF6C8CFF),
                ],
              ),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 27,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'ZYOCAR',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF171923),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'اكتشف سيارتك القادمة',
                  style: TextStyle(
                    color: Color(0xFF7C8190),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _loadCars,
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF252735),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 20,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              search = value;
            });
          },
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'ابحث عن الماركة أو الموديل...',
            hintStyle: TextStyle(
              color: Color(0xFF9A9EAA),
              fontSize: 13,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Color(0xFFFF4F91),
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _brands() {
    return SizedBox(
      height: 105,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          18,
          16,
          10,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        itemBuilder: (context, index) {
          final brand = brands[index];
          final selected =
              brand == selectedBrand;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedBrand = brand;
              });
            },
            child: Container(
              width: 76,
              margin: const EdgeInsets.only(
                left: 10,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFF4F91)
                          : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.06),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Icon(
                      brand == 'الكل'
                          ? Icons.apps_rounded
                          : Icons.directions_car_rounded,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF555A68),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    brand,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFFFF4F91)
                          : const Color(0xFF686D7A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _filters() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        10,
      ),
      child: Row(
        children: [
          const Text(
            'السيارات',
            style: TextStyle(
              color: Color(0xFF171923),
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          PopupMenuButton<String>(
            initialValue: selectedTransmission,
            onSelected: (value) {
              setState(() {
                selectedTransmission = value;
              });
            },
            itemBuilder: (_) {
              return const [
                PopupMenuItem(
                  value: 'الكل',
                  child: Text('كل الجيرات'),
                ),
                PopupMenuItem(
                  value: 'أوتوماتيك',
                  child: Text('أوتوماتيك'),
                ),
                PopupMenuItem(
                  value: 'عادي',
                  child: Text('عادي'),
                ),
              ];
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(13),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.tune_rounded,
                    size: 18,
                    color: Color(0xFFFF4F91),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'فلترة',
                    style: TextStyle(
                      color: Color(0xFF303340),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carCard(Car car) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: car.image != null &&
                            car.image!.isNotEmpty
                        ? Image.network(
                            widget.api.imageUrl(
                              car.image!,
                            ),
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) {
                              return _placeholder();
                            },
                          )
                        : _placeholder(),
                  ),
                  Positioned(
                    top: 9,
                    right: 9,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(.92),
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                      child: Text(
                        car.planName,
                        style: const TextStyle(
                          color: Color(0xFFFF4F91),
                          fontSize: 10,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 9,
                    right: 9,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black
                            .withOpacity(.55),
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(11),
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
                        color: Color(0xFF171923),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Color(0xFF8A8E9A),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            car.city,
                            maxLines: 1,
                            overflow:
                                TextOverflow.ellipsis,
                            style: const TextStyle(
                              color:
                                  Color(0xFF8A8E9A),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      '${_price(car.price)} د.ع',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFFF4F91),
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE9EBF2),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 55,
          color: Color(0xFFB8BDCA),
        ),
      ),
    );
  }

  Widget _empty() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 65,
            color: Color(0xFFB8BDCA),
          ),
          const SizedBox(height: 12),
          const Text(
            'ما لقينا سيارات مطابقة',
            style: TextStyle(
              color: Color(0xFF555A68),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                search = '';
                selectedBrand = 'الكل';
                selectedTransmission = 'الكل';
              });
            },
            child: const Text('إظهار الكل'),
          ),
        ],
      ),
    );
  }

  Widget _error() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 60,
            color: Color(0xFFB8BDCA),
          ),
          const SizedBox(height: 12),
          const Text(
            'تعذر تحميل السيارات',
            style: TextStyle(
              color: Color(0xFF555A68),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadCars,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
