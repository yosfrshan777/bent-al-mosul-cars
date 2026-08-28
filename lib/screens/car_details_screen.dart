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

  Widget _info(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF292933),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFF176F).withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF176F),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 4),
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

  void _callSeller(BuildContext context) {
    if (car.sellerPhone == null ||
        car.sellerPhone!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('رقم البائع غير متوفر'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF15151B),
          title: const Text(
            'التواصل مع البائع',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            car.sellerPhone!,
            style: const TextStyle(
              color: Color(0xFFFF176F),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = car.image;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF08080B),
          title: const Text(
            'تفاصيل السيارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 290,
                child: image != null && image.isNotEmpty
                    ? Image.network(
                        api.imageUrl(image),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return Container(
                            color: const Color(0xFF202027),
                            child: const Icon(
                              Icons.directions_car_rounded,
                              color: Color(0xFFFF176F),
                              size: 90,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFF202027),
                        child: const Icon(
                          Icons.directions_car_rounded,
                          color: Color(0xFFFF176F),
                          size: 90,
                        ),
                      ),
              ),

              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${car.brand} ${car.model}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF176F),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Text(
                            car.planName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${_formatPrice(car.price)} د.ع',
                      style: const TextStyle(
                        color: Color(0xFFFF176F),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 22),

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
                      'سنة الصنع',
                      '${car.year}',
                      Icons.calendar_month_rounded,
                    ),

                    const SizedBox(height: 10),

                    _info(
                      'المسافة',
                      '${car.km} كم',
                      Icons.speed_rounded,
                    ),

                    const SizedBox(height: 10),

                    _info(
                      'ناقل الحركة',
                      car.transmission,
                      Icons.settings_rounded,
                    ),

                    const SizedBox(height: 10),

                    _info(
                      'الوقود',
                      car.fuel,
                      Icons.local_gas_station_rounded,
                    ),

                    const SizedBox(height: 10),

                    _info(
                      'الموقع',
                      car.city,
                      Icons.location_on_rounded,
                    ),

                    if (car.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 24),
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
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF15151B),
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        child: Text(
                          car.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            height: 1.8,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    if (car.sellerName != null &&
                        car.sellerName!.isNotEmpty)
                      Text(
                        'البائع: ${car.sellerName}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    const SizedBox(height: 14),

                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _callSeller(context),
                        icon: const Icon(
                          Icons.phone_rounded,
                        ),
                        label: const Text(
                          'التواصل مع البائع',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFF176F),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
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
      ),
    );
  }
}
