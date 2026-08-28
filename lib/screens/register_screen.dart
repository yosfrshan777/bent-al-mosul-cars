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

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFF4F91),
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF979BA6),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF20232F),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
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
    if (car.image == null || car.image!.isEmpty) {
      return Container(
        color: const Color(0xFFE8EAF0),
        child: const Center(
          child: Icon(
            Icons.directions_car_filled_rounded,
            size: 90,
            color: Color(0xFFB8BDC9),
          ),
        ),
      );
    }

    return Image.network(
      api.imageUrl(car.image!),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xFFE8EAF0),
          child: const Center(
            child: Icon(
              Icons.directions_car_filled_rounded,
              size: 90,
              color: Color(0xFFB8BDC9),
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
        backgroundColor: const Color(0xFFF7F8FC),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              backgroundColor: const Color(0xFF15151B),
              foregroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _image(),

                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(.75),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
                      right: 18,
                      left: 18,
                      bottom: 20,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${car.brand} ${car.model}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
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
                              color: const Color(0xFFFF4F91),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text(
                              car.planName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.favorite_border_rounded,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_rounded,
                  ),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                35,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.04),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'السعر',
                          style: TextStyle(
                            color: Color(0xFF8B8F9B),
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_formatPrice(car.price)} د.ع',
                          style: const TextStyle(
                            color: Color(0xFFFF4F91),
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'معلومات السيارة',
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.9,
                    children: [
                      _infoItem(
                        icon: Icons.calendar_month_rounded,
                        title: 'سنة الصنع',
                        value: '${car.year}',
                      ),
                      _infoItem(
                        icon: Icons.speed_rounded,
                        title: 'المسافة',
                        value: '${_formatPrice(car.km)} كم',
                      ),
                      _infoItem(
                        icon: Icons.local_gas_station_rounded,
                        title: 'الوقود',
                        value: car.fuel,
                      ),
                      _infoItem(
                        icon: Icons.settings_rounded,
                        title: 'ناقل الحركة',
                        value: car.transmission,
                      ),
                      _infoItem(
                        icon: Icons.location_on_rounded,
                        title: 'الموقع',
                        value: car.city,
                      ),
                      _infoItem(
                        icon: Icons.confirmation_number_outlined,
                        title: 'رقم الإعلان',
                        value: car.publicNo ??
                            '#${car.id}',
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'الوصف',
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(19),
                    ),
                    child: Text(
                      car.description.isEmpty
                          ? 'لا يوجد وصف مضاف لهذا الإعلان.'
                          : car.description,
                      style: const TextStyle(
                        color: Color(0xFF656976),
                        fontSize: 13,
                        height: 1.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'البائع',
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(19),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEFF5),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: Color(0xFFFF4F91),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                car.sellerName ??
                                    'صاحب الإعلان',
                                style: const TextStyle(
                                  color: Color(0xFF20232F),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                car.sellerPhone ??
                                    'رقم الهاتف غير متوفر',
                                style: const TextStyle(
                                  color: Color(0xFF8B8F9B),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (car.sellerPhone != null)
                          Container(
                            width: 43,
                            height: 43,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF4F91),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.phone_rounded,
                      ),
                      label: const Text(
                        'تواصل مع البائع',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFF4F91),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
