import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';
import 'car_details_screen.dart';

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
  final TextEditingController _searchController =
      TextEditingController();

  List<Car> _cars = [];
  bool _loading = true;
  String? _error;

  String _city = 'الكل';
  String _fuel = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  Future<void> _loadCars() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await widget.api.getCars();

      final cars = result
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
        _cars = cars;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'تعذر تحميل السيارات';
      });
    }
  }

  List<Car> get _filteredCars {
    final query =
        _searchController.text.trim().toLowerCase();

    return _cars.where((car) {
      final matchesSearch =
          query.isEmpty ||
          car.brand.toLowerCase().contains(query) ||
          car.model.toLowerCase().contains(query) ||
          car.city.toLowerCase().contains(query);

      final matchesCity =
          _city == 'الكل' || car.city == _city;

      final matchesFuel =
          _fuel == 'الكل' || car.fuel == _fuel;

      return matchesSearch &&
          matchesCity &&
          matchesFuel;
    }).toList();
  }

  List<String> get _cities {
    final values = _cars
        .map((car) => car.city)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return ['الكل', ...values];
  }

  List<String> get _fuels {
    final values = _cars
        .map((car) => car.fuel)
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList();

    values.sort();

    return ['الكل', ...values];
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

  Widget _searchBox() {
    return TextField(
      controller: _searchController,
      onChanged: (_) {
        setState(() {});
      },
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث عن الماركة أو الموديل...',
        hintStyle: const TextStyle(
          color: Colors.white38,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFFF176F),
        ),
        suffixIcon:
            _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white54,
                    ),
                  ),
        filled: true,
        fillColor: const Color(0xFF15151B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xFF292932),
          ),
        ),
      ),
    );
  }

  Widget _filter({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        value: items.contains(value)
            ? value
            : 'الكل',
        dropdownColor: const Color(0xFF15151B),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFF15151B),
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
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
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF292932),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.image != null &&
                          car.image!.isNotEmpty
                      ? Image.network(
                          widget.api.imageUrl(
                            car.image!,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) =>
                                  _placeholder(),
                        )
                      : _placeholder(),

                  if (car.isVip)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              const Color(0xFFFF176F),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'VIP',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
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
                      fontSize: 16,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color:
                            Color(0xFFFF176F),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color:
                            Color(0xFFFF176F),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          car.city,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${_formatPrice(car.price)} د.ع',
                    style: const TextStyle(
                      color: Color(0xFFFF176F),
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w900,
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
          size: 55,
        ),
      ),
    );
  }

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF176F),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white38,
              size: 55,
            ),
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadCars,
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      );
    }

    final cars = _filteredCars;

    if (cars.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFFF176F),
        onRefresh: _loadCars,
        child: ListView(
          children: const [
            SizedBox(height: 130),
            Icon(
              Icons.search_off_rounded,
              color: Colors.white24,
              size: 65,
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                'لا توجد سيارات مطابقة',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFFFF176F),
      onRefresh: _loadCars,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          25,
        ),
        itemCount: cars.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: .70,
        ),
        itemBuilder: (_, index) {
          return _carCard(cars[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'السيارات',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed:
                  _loading ? null : _loadCars,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                8,
              ),
              child: Column(
                children: [
                  _searchBox(),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _filter(
                        value: _city,
                        items: _cities,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _city = value;
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      _filter(
                        value: _fuel,
                        items: _fuels,
                        onChanged: (value) {
                          if (value == null) return;
                          setState(() {
                            _fuel = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Expanded(
              child: _body(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
