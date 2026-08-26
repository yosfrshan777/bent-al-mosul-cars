import 'package:flutter/material.dart';

import '../models/car.dart';

class CarCard extends StatelessWidget {
  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Car car;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(
            bottom: 14,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF15151B),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF292932),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              _imageSection(),
              _detailsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _carImage(),

          Positioned(
            top: 12,
            right: 12,
            child: _planBadge(),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: Material(
              color: Colors.black
                  .withOpacity(.55),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder:
                    const CircleBorder(),
                onTap: onFavorite,
                child: Padding(
                  padding:
                      const EdgeInsets.all(9),
                  child: Icon(
                    isFavorite
                        ? Icons
                            .favorite_rounded
                        : Icons
                            .favorite_border_rounded,
                    color: isFavorite
                        ? const Color(
                            0xFFFF176F,
                          )
                        : Colors.white,
                    size: 21,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(.65),
                borderRadius:
                    BorderRadius.circular(9),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${car.images.length}',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _carImage() {
    if (car.images.isEmpty) {
      return Container(
        color: const Color(0xFF202027),
        child: const Center(
          child: Icon(
            Icons.directions_car_rounded,
            color: Colors.white24,
            size: 70,
          ),
        ),
      );
    }

    return Image.network(
      car.images.first,
      fit: BoxFit.cover,
      errorBuilder:
          (context, error, stackTrace) {
        return Container(
          color: const Color(0xFF202027),
          child: const Center(
            child: Icon(
              Icons
                  .image_not_supported_outlined,
              color: Colors.white24,
              size: 55,
            ),
          ),
        );
      },
      loadingBuilder:
          (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return Container(
          color: const Color(0xFF202027),
          child: const Center(
            child:
                CircularProgressIndicator(
              color: Color(0xFFFF176F),
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _planBadge() {
    final isVip = car.plan == 'VIP';
    final isPremium = car.plan == 'مميز';

    String text = 'عادي';

    if (isVip) {
      text = 'VIP';
    } else if (isPremium) {
      text = 'مميز';
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isVip
              ? const [
                  Color(0xFFFFB000),
                  Color(0xFFFF176F),
                ]
              : const [
                  Color(0xFFFF176F),
                  Color(0xFFE0005C),
                ],
        ),
        borderRadius:
            BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF176F)
                .withOpacity(.25),
            blurRadius: 10,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _detailsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        15,
        14,
        15,
        15,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  car.title,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                car.year.toString(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              _info(
                Icons.location_on_outlined,
                car.city,
              ),
              const SizedBox(width: 12),
              _info(
                Icons.speed_outlined,
                '${car.formattedKm} كم',
              ),
            ],
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              _info(
                Icons.local_gas_station_outlined,
                car.fuel,
              ),
              const SizedBox(width: 12),
              _info(
                Icons.settings_outlined,
                car.transmission,
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(
            color: Color(0xFF292932),
            height: 1,
          ),

          const SizedBox(height: 13),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'السعر',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${car.formattedPrice} د.ع',
                      style: const TextStyle(
                        color:
                            Color(0xFFFF176F),
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFFF176F),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      'التفاصيل',
                      style:
                          TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons
                          .arrow_back_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _info(
    IconData icon,
    String text,
  ) {
    return Flexible(
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white38,
            size: 16,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
