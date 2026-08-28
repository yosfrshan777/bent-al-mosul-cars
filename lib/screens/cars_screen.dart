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

  String _selectedBrand = 'الكل';
  String _selectedCity = 'الكل';

  final List<String> _brands = [
    'الكل',
    'BMW',
    'Toyota',
    'Mercedes',
    'Lexus',
    'Kia',
    'Hyundai',
    'Nissan',
    'Honda',
    'Ford',
  ];

  final List<String> _cities = [
    'الكل',
    'الموصل',
    'بغداد',
    'أربيل',
    'دهوك',
    'كركوك',
    'السليمانية',
    'البصرة',
    'نينوى',
  ];

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
          .toList();

      if (!mounted) return;

      setState(() {
        _cars = cars;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _error = 'تعذر تحميل السيارات حالياً';
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

      final matchesBrand =
          _selectedBrand == 'الكل' ||
          car.brand.toLowerCase() ==
              _selectedBrand.toLowerCase();

      final matchesCity =
          _selectedCity == 'الكل' ||
          car.city == _selectedCity;

      return matchesSearch &&
          matchesBrand &&
          matchesCity;
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

  void _openDetails(Car car) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarDetailsScreen(
          car: car,
          api: widget.api,
        ),
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث عن ماركة، موديل أو مدينة',
          hintStyle: const TextStyle(
            color: Color(0xFF999EAA),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFFF4F91),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _filterButton({
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFFFF4F91),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  color: Color(0xFF292C38),
                  fontSize: 13,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _carCard(Car car) {
    return GestureDetector(
      onTap: () => _openDetails(car),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
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
            SizedBox(
              height: 175,
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

                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.65),
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                      child: Text(
                        car.planName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withOpacity(.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border_rounded,
                        color: Color(0xFFFF4F91),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
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
                      color: Color(0xFF20232F),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: _smallInfo(
                          Icons.calendar_month_rounded,
                          '${car.year}',
                        ),
                      ),
                      Expanded(
                        child: _smallInfo(
                          Icons.location_on_outlined,
                          car.city,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '${_formatPrice(car.price)} د.ع',
                    style: const TextStyle(
                      color: Color(0xFFFF4F91),
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

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFFFF4F91),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF858996),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: const Color(0xFFE9EBF2),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 65,
          color: Color(0xFFB9BFCC),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cars = _filteredCars;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FC),
          foregroundColor: const Color(0xFF171923),
          title: const Text(
            'السيارات',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          actions: [
            IconButton(
              onPressed: _loadCars,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          color: const Color(0xFFFF4F91),
          onRefresh: _loadCars,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              5,
              16,
              30,
            ),
            children: [
              _searchBox(),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _filterButton(
                      value: _selectedBrand,
                      items: _brands,
                      onChanged: (value) {
                        setState(() {
                          _selectedBrand = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _filterButton(
                      value: _selectedCity,
                      items: _cities,
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Row(
                children: [
                  const Text(
                    'كل السيارات',
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${cars.length} إعلان',
                    style: const TextStyle(
                      color: Color(0xFF8A8E9B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF4F91),
                    ),
                  ),
                )
              else if (_error != null)
                _errorWidget()
              else if (cars.isEmpty)
                _emptyWidget()
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  itemCount: cars.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: .68,
                  ),
                  itemBuilder: (_, index) {
                    return _carCard(cars[index]);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyWidget() {
    return Container(
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 55,
            color: Color(0xFFB7BBC7),
          ),
          SizedBox(height: 12),
          Text(
            'ما لقينا سيارات بهذا البحث',
            style: TextStyle(
              color: Color(0xFF303341),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            size: 50,
            color: Color(0xFF999EAA),
          ),
          const SizedBox(height: 10),
          Text(
            _error!,
            style: const TextStyle(
              color: Color(0xFF555966),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadCars,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
