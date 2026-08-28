import 'package:flutter/material.dart';

import '../models/car.dart';
import '../services/api_service.dart';

class CarDetailsScreen extends StatelessWidget {
  const CarDetailsScreen({
    super.key,
    required this.car,
    required this.api,
  });

  final Car car;
  final ApiService api;

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
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              backgroundColor: const Color(0xFF171923),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: car.image != null &&
                        car.image!.isNotEmpty
                    ? Image.network(
                        api.imageUrl(car.image!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return _imagePlaceholder();
                        },
                      )
                    : _imagePlaceholder(),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${car.brand} ${car.model}',
                            style: const TextStyle(
                              color: Color(0xFF171923),
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFFFEFF5),
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: Text(
                            car.planName,
                            style: const TextStyle(
                              color: Color(0xFFFF4F91),
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${_price(car.price)} د.ع',
                      style: const TextStyle(
                        color: Color(0xFFFF4F91),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 20),

                    _specifications(),

                    const SizedBox(height: 20),

                    _description(),

                    const SizedBox(height: 20),

                    _seller(),

                    const SizedBox(height: 25),

                    if (car.sellerPhone != null &&
                        car.sellerPhone!.isNotEmpty)
                      SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone_rounded,
                          ),
                          label: Text(
                            'اتصل بالبائع ${car.sellerPhone}',
                          ),
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFF4F91),
                            foregroundColor:
                                Colors.white,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                17,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 35),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _specifications() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            Icons.calendar_month_rounded,
            'السنة',
            '${car.year}',
          ),
          _divider(),
          _row(
            Icons.speed_rounded,
            'الكيلومترات',
            '${_price(car.km)} كم',
          ),
          _divider(),
          _row(
            Icons.location_on_outlined,
            'الموقع',
            car.city,
          ),
          _divider(),
          _row(
            Icons.local_gas_station_outlined,
            'الوقود',
            car.fuel,
          ),
          _divider(),
          _row(
            Icons.settings_rounded,
            'ناقل الحركة',
            car.transmission,
          ),
        ],
      ),
    );
  }

  Widget _row(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF5),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF4F91),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF858997),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF252735),
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      height: 1,
      color: Color(0xFFEDEEF3),
    );
  }

  Widget _description() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'وصف السيارة',
            style: TextStyle(
              color: Color(0xFF171923),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            car.description.isEmpty
                ? 'لا يوجد وصف مضاف لهذه السيارة.'
                : car.description,
            style: const TextStyle(
              color: Color(0xFF707482),
              height: 1.7,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _seller() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF4F91),
                  Color(0xFF718DFF),
                ],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'البائع',
                  style: TextStyle(
                    color: Color(0xFF9094A0),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  car.sellerName?.isNotEmpty == true
                      ? car.sellerName!
                      : 'بائع السيارة',
                  style: const TextStyle(
                    color: Color(0xFF252735),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (car.sellerPhone != null)
            const Icon(
              Icons.phone_rounded,
              color: Color(0xFFFF4F91),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE7E9F0),
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          size: 75,
          color: Color(0xFFB8BDCA),
        ),
      ),
    );
  }
}
