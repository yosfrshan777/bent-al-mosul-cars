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
  State<CarsScreen> createState() =>
      _CarsScreenState();
}

class _CarsScreenState extends State<CarsScreen> {
  bool _loading = true;
  String? _error;

  List<Car> _cars = [];

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
      final data = await widget.api.getCars();

      final cars = data
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
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = 'تعذر تحميل السيارات';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _price(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      if (i > 0 &&
          (text.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(text[i]);
    }

    return '\$$buffer';
  }

  void _openCar(Car car) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111116),
      isScrollControlled: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detail(
                    'السنة',
                    car.year.toString(),
                  ),
                  _detail(
                    'السعر',
                    _price(car.price),
                  ),
                  _detail(
                    'الممشى',
                    '${car.km} كم',
                  ),
                  _detail(
                    'الموقع',
                    car.city,
                  ),
                  _detail(
                    'الوقود',
                    car.fuel,
                  ),
                  _detail(
                    'القير',
                    car.transmission,
                  ),
                  if (car.description.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 10,
                      ),
                      child: Text(
                        car.description,
                        style: const TextStyle(
                          color: Colors.white60,
                          height: 1.5,
                        ),
                      ),
                    ),
                  if (car.sellerPhone != null)
                    Padding(
                      padding:
                          const EdgeInsets.only(
                        top: 16,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.phone_rounded,
                        ),
                        label: Text(
                          car.sellerPhone!,
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFFF176F,
                          ),
                          foregroundColor:
                              Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detail(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 7,
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white38,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carCard(Car car) {
    return GestureDetector(
      onTap: () => _openCar(car),
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 14,
        ),
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
              CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  car.image == null ||
                          car.image!.isEmpty
                      ? Container(
                          color:
                              const Color(
                            0xFF202027,
                          ),
                          child: const Icon(
                            Icons
                                .directions_car_rounded,
                            color:
                                Colors.white24,
                            size: 70,
                          ),
                        )
                      : Image.network(
                          widget.api.imageUrl(
                            car.image!,
                          ),
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) {
                            return Container(
                              color:
                                  const Color(
                                0xFF202027,
                              ),
                              child: const Icon(
                                Icons
                                    .directions_car_rounded,
                                color:
                                    Colors.white24,
                                size: 70,
                              ),
                            );
                          },
                        ),

                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        if (car.isVip)
                          Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFFFF176F,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                20,
                              ),
                            ),
                            child:
                                const Text(
                              'VIP',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight
                                        .w900,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.black
                            .withValues(
                          alpha: .7,
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),
                      ),
                      child: Text(
                        _price(car.price),
                        style:
                            const TextStyle(
                          color: Colors.white,
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
              padding:
                  const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${car.brand} ${car.model}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _chip(
                        Icons
                            .calendar_month_rounded,
                        car.year.toString(),
                      ),
                      _chip(
                        Icons
                            .location_on_rounded,
                        car.city,
                      ),
                      _chip(
                        Icons
                            .speed_rounded,
                        '${car.km} كم',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    IconData icon,
    String text,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF202027),
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color:
                const Color(0xFFFF176F),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(
                color: Color(0xFFFF176F),
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons
                            .cloud_off_rounded,
                        color:
                            Colors.white38,
                        size: 45,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        _error!,
                        style:
                            const TextStyle(
                          color:
                              Colors.white70,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        onPressed:
                            _loadCars,
                        child:
                            const Text(
                          'إعادة المحاولة',
                        ),
                      ),
                    ],
                  ),
                )
              : _cars.isEmpty
                  ? RefreshIndicator(
                      color: const Color(
                        0xFFFF176F,
                      ),
                      onRefresh:
                          _loadCars,
                      child:
                          ListView(
                        physics:
                            const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 160,
                          ),
                          Icon(
                            Icons
                                .directions_car_outlined,
                            color:
                                Colors.white24,
                            size: 60,
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Center(
                            child: Text(
                              'ماكو سيارات منشورة حالياً',
                              style:
                                  TextStyle(
                                color:
                                    Colors.white54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      color: const Color(
                        0xFFFF176F,
                      ),
                      onRefresh:
                          _loadCars,
                      child:
                          ListView.builder(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount:
                            _cars.length,
                        itemBuilder:
                            (_, index) {
                          return _carCard(
                            _cars[index],
                          );
                        },
                      ),
                    ),
    );
  }
}
