import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';

class CarsScreen extends StatefulWidget {
  const CarsScreen({
    super.key,
    required this.api,
    this.onCarTap,
  });

  final ApiService api;
  final void Function(Car car)? onCarTap;

  @override
  State<CarsScreen> createState() => _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  final TextEditingController searchController =
      TextEditingController();

  List<Car> cars = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCars();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCars() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await widget.api.getCars(
        search: searchController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        cars = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'تعذر تحميل السيارات';
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

  Widget _image(Car car) {
    if (car.image == null || car.image!.isEmpty) {
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

    return Image.network(
      widget.api.imageUrl(car.image!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFF202027),
          child: const Icon(
            Icons.directions_car_filled_rounded,
            color: Color(0xFFFF176F),
            size: 55,
          ),
        );
      },
    );
  }

  Widget _badge(Car car) {
    if (car.isVip) {
      return _planBadge(
        'VIP',
        const Color(0xFFFF176F),
      );
    }

    if (car.isFeatured) {
      return _planBadge(
        'مميز',
        const Color(0xFFFF9F1C),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _planBadge(
    String text,
    Color color,
  ) {
    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 11,
          vertical: 7,
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _carCard(Car car) {
    return Material(
      color: const Color(0xFF15151B),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => widget.onCarTap?.call(car),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: _image(car),
                ),
                _badge(car),
              ],
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
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _detail(
                          Icons.calendar_month_rounded,
                          '${car.year}',
                        ),
                      ),
                      Expanded(
                        child: _detail(
                          Icons.location_on_outlined,
                          car.city,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Expanded(
                        child: _detail(
                          Icons.speed_rounded,
                          '${car.km} كم',
                        ),
                      ),
                      Expanded(
                        child: _detail(
                          Icons.local_gas_station_outlined,
                          car.fuel.isEmpty
                              ? 'غير محدد'
                              : car.fuel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${_price(car.price)} د.ع',
                    style: const TextStyle(
                      color: Color(0xFFFF176F),
                      fontSize: 20,
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

  Widget _detail(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFFFF176F),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: TextField(
        controller: searchController,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _loadCars(),
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: 'ابحث عن سيارة أو موديل...',
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFFFF176F),
          ),
          suffixIcon: IconButton(
            onPressed: () {
              searchController.clear();
              _loadCars();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white54,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFFF176F),
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white38,
              size: 55,
            ),
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed: _loadCars,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFF176F),
              ),
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      );
    }

    if (cars.isEmpty) {
      return RefreshIndicator(
        color: const Color(0xFFFF176F),
        onRefresh: _loadCars,
        child: ListView(
          children: const [
            SizedBox(height: 150),
            Center(
              child: Icon(
                Icons.directions_car_outlined,
                color: Colors.white30,
                size: 70,
              ),
            ),
            SizedBox(height: 15),
            Center(
              child: Text(
                'لا توجد سيارات مطابقة للبحث',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
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
        padding: const EdgeInsets.only(
          top: 15,
          bottom: 30,
        ),
        gridDelegate:
            const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420,
          mainAxisExtent: 390,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: cars.length,
        itemBuilder: (context, index) {
          return _carCard(cars[index]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111116),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'السيارات',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          14,
          14,
          14,
          0,
        ),
        child: Column(
          children: [
            _searchBox(),
            const SizedBox(height: 8),
            Expanded(
              child: _body(),
            ),
          ],
        ),
      ),
    );
  }
}
