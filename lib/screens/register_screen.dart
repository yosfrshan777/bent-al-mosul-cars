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
  List<Car> cars = [];
  bool loading = true;
  String? error;

  String search = '';
  String selectedCity = 'الكل';

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
    final query = search.trim().toLowerCase();

    return cars.where((car) {
      final matchesCity =
          selectedCity == 'الكل' ||
          car.city == selectedCity;

      final matchesSearch =
          query.isEmpty ||
          '${car.brand} ${car.model}'
              .toLowerCase()
              .contains(query) ||
          car.city.toLowerCase().contains(query);

      return matchesCity && matchesSearch;
    }).toList();
  }

  List<String> get cities {
    final values = cars
        .map((car) => car.city)
        .where((city) => city.trim().isNotEmpty)
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

  Widget _image(Car car) {
    if (car.image == null || car.image!.isEmpty) {
      return Container(
        color: const Color(0xFFE9EAF0),
        child: const Icon(
          Icons.directions_car_filled_rounded,
          size: 65,
          color: Color(0xFFB9BDC7),
        ),
      );
    }

    return Image.network(
      widget.api.imageUrl(car.image!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFE9EAF0),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            size: 65,
            color: Color(0xFFB9BDC7),
          ),
        );
      },
    );
  }

  Widget _carCard(Car car) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 175,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _image(car),

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
                        color: car.isVip
                            ? const Color(0xFFFF176F)
                            : Colors.black87,
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        car.planName,
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
            ),

            Padding(
              padding: const EdgeInsets.all(13),
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
                      color: Color(0xFF20232F),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_month_rounded,
                        size: 14,
                        color: Color(0xFFFF4F91),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${car.year}',
                        style: const TextStyle(
                          color: Color(0xFF777B87),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFFFF4F91),
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          car.city,
                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF777B87),
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
                      fontSize: 17,
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

  Widget _searchBox() {
    return TextField(
      textDirection: TextDirection.rtl,
      onChanged: (value) {
        setState(() {
          search = value;
        });
      },
      style: const TextStyle(
        color: Color(0xFF20232F),
      ),
      decoration: InputDecoration(
        hintText: 'ابحث عن سيارة أو مدينة...',
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: Color(0xFFFF4F91),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _cityFilter() {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cities.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final city = cities[index];
          final selected =
              selectedCity == city;

          return ChoiceChip(
            label: Text(city),
            selected: selected,
            onSelected: (_) {
              setState(() {
                selectedCity = city;
              });
            },
            selectedColor:
                const Color(0xFFFF4F91),
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color(0xFF555966),
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }

  Widget _content() {
    if (loading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFFF4F91),
          ),
        ),
      );
    }

    if (error != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 50,
                color: Color(0xFF999EAA),
              ),
              const SizedBox(height: 12),
              Text(
                error!,
                style: const TextStyle(
                  color: Color(0xFF666A76),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _loadCars,
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      );
    }

    final list = filteredCars;

    if (list.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 65,
                color: Color(0xFFB8BDC8),
              ),
              SizedBox(height: 12),
              Text(
                'لا توجد سيارات مطابقة',
                style: TextStyle(
                  color: Color(0xFF666A76),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: RefreshIndicator(
        color: const Color(0xFFFF4F91),
        onRefresh: _loadCars,
        child: GridView.builder(
          padding: const EdgeInsets.only(
            top: 15,
            bottom: 30,
          ),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11,
            mainAxisSpacing: 11,
            childAspectRatio: .72,
          ),
          itemCount: list.length,
          itemBuilder: (_, index) {
            return _carCard(list[index]);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          title: const Text(
            'السيارات',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          backgroundColor:
              const Color(0xFFF7F8FC),
          foregroundColor:
              const Color(0xFF20232F),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            5,
            16,
            0,
          ),
          child: Column(
            children: [
              _searchBox(),

              const SizedBox(height: 12),

              _cityFilter(),

              const SizedBox(height: 5),

              _content(),
            ],
          ),
        ),
      ),
    );
  }
}
