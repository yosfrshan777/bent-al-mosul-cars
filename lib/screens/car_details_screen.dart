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

  String _formatPrice(int value) {
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

  Widget _info(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF176F),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value.isEmpty ? 'غير محدد' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    if (car.image == null ||
        car.image!.isEmpty) {
      return Container(
        height: 280,
        color: const Color(0xFF202027),
        child: const Center(
          child: Icon(
            Icons.directions_car_filled_rounded,
            color: Color(0xFFFF176F),
            size: 90,
          ),
        ),
      );
    }

    return Image.network(
      api.imageUrl(car.image!),
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          height: 280,
          color: const Color(0xFF202027),
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: Colors.white38,
              size: 65,
            ),
          ),
        );
      },
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
            'تفاصيل السيارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: ListView(
          padding: const EdgeInsets.only(
            bottom: 30,
          ),
          children: [
            _image(),

            Padding(
              padding: const EdgeInsets.all(16),
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
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),
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
                                BorderRadius.circular(
                              10,
                            ),
                          ),
                          child: const Text(
                            'VIP',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight:
                                  FontWeight.bold,
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
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'معلومات السيارة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _info(
                    Icons.calendar_today_rounded,
                    'سنة الصنع',
                    '${car.year}',
                  ),

                  const SizedBox(height: 9),

                  _info(
                    Icons.speed_rounded,
                    'المسافة',
                    '${_formatPrice(car.km)} كم',
                  ),

                  const SizedBox(height: 9),

                  _info(
                    Icons.location_on_outlined,
                    'الموقع',
                    car.city,
                  ),

                  const SizedBox(height: 9),

                  _info(
                    Icons.local_gas_station_rounded,
                    'نوع الوقود',
                    car.fuel,
                  ),

                  const SizedBox(height: 9),

                  _info(
                    Icons.settings_rounded,
                    'ناقل الحركة',
                    car.transmission,
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'الوصف',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding:
                        const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF15151B),
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: Text(
                      car.description.isEmpty
                          ? 'لا يوجد وصف'
                          : car.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (car.sellerName != null ||
                      car.sellerPhone != null) ...[
                    const Text(
                      'معلومات البائع',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF15151B),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          if (car.sellerName != null)
                            _info(
                              Icons.person_rounded,
                              'الاسم',
                              car.sellerName!,
                            ),
                          if (car.sellerPhone != null) ...[
                            const SizedBox(height: 9),
                            _info(
                              Icons.phone_rounded,
                              'رقم الهاتف',
                              car.sellerPhone!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed:
                          car.sellerPhone == null
                              ? null
                              : () {
                                  ScaffoldMessenger
                                      .of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يمكن الاتصال بالبائع من خلال الرقم الظاهر أعلاه',
                                      ),
                                    ),
                                  );
                                },
                      icon: const Icon(
                        Icons.phone_rounded,
                      ),
                      label: const Text(
                        'تواصل مع البائع',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFFF176F,
                        ),
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                      ),
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
}
