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

      final loadedCars = result
          .whereType<Map>()
          .map(
            (item) => Car.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        cars = loadedCars;
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

  List<String> get brands {
    final result = <String>{};

    for (final car in cars) {
      if (car.brand.trim().isNotEmpty) {
        result.add(car.brand);
      }
    }

    return ['الكل', ...result];
  }

  List<Car> get filteredCars {
    final query = search.trim().toLowerCase();

    return cars.where((car) {
      final matchesBrand =
          selectedBrand == 'الكل' ||
          car.brand == selectedBrand;

      final text =
          '${car.brand} ${car.model} ${car.city} ${car.year}'
              .toLowerCase();

      final matchesSearch =
          query.isEmpty || text.contains(query);

      return matchesBrand && matchesSearch;
    }).toList();
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

  Widget _brandButton(String brand) {
    final selected = selectedBrand == brand;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBrand = brand;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: selected
              ? const LinearGradient(
                  colors: [
                    Color(0xFFFF176F),
                    Color(0xFF8B5CF6),
                  ],
                )
              : null,
          color: selected
              ? null
              : const Color(0xFF15151B),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : const Color(0xFF292933),
          ),
        ),
        child: Text(
          brand,
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                selected ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _carCard(Car car) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF292933),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 220,
            child: Stack(
              fit: StackFit.expand,
              children: [
                car.image != null && car.image!.isNotEmpty
                    ? Image.network(
                        widget.api.imageUrl(car.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _placeholder();
                        },
                      )
                    : _placeholder(),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.65),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      car.planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF176F),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${car.year}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${car.brand} ${car.model}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _chip(
                      Icons.speed_rounded,
                      '${car.km} كم',
                    ),
                    _chip(
                      Icons.settings_rounded,
                      car.transmission,
                    ),
                    _chip(
                      Icons.local_gas_station_rounded,
                      car.fuel,
                    ),
                    _chip(
                      Icons.location_on_rounded,
                      car.city,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatPrice(car.price)} د.ع',
                      style: const TextStyle(
                        color: Color(0xFFFF176F),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    if (car.sellerPhone != null &&
                        car.sellerPhone!.isNotEmpty)
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.phone_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFF176F),
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

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF202027),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFFFF176F),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          size: 75,
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 60,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 65,
            color: Colors.white30,
          ),
          SizedBox(height: 14),
          Text(
            'ماكو سيارات مطابقة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'جرّب تغيير البحث أو الماركة',
            style: TextStyle(
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleCars = filteredCars;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF08080B),
          title: const Text(
            'السيارات',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _loadCars,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFFF176F),
                  ),
                )
              : error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cloud_off_rounded,
                            color: Colors.white54,
                            size: 55,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            error!,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _loadCars,
                            child: const Text(
                              'إعادة المحاولة',
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(0xFFFF176F),
                      backgroundColor:
                          const Color(0xFF15151B),
                      onRefresh: _loadCars,
                      child: ListView(
                        padding:
                            const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          30,
                        ),
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFF15151B),
                              borderRadius:
                                  BorderRadius.circular(18),
                              border: Border.all(
                                color:
                                    const Color(0xFF292933),
                              ),
                            ),
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  search = value;
                                });
                              },
                              textDirection:
                                  TextDirection.rtl,
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                              decoration:
                                  const InputDecoration(
                                icon: Icon(
                                  Icons.search_rounded,
                                  color:
                                      Color(0xFFFF176F),
                                ),
                                hintText:
                                    'ابحث عن سيارة، ماركة، مدينة...',
                                hintStyle: TextStyle(
                                  color: Colors.white38,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 18),

                          SizedBox(
                            height: 48,
                            child: ListView(
                              scrollDirection:
                                  Axis.horizontal,
                              children: brands
                                  .map(_brandButton)
                                  .toList(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'كل السيارات',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              Text(
                                '${visibleCars.length} إعلان',
                                style: const TextStyle(
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          if (visibleCars.isEmpty)
                            _emptyState()
                          else
                            ...visibleCars.map(
                              _carCard,
                            ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }
}
