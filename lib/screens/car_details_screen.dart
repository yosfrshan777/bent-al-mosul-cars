import 'package:flutter/material.dart';

import '../models/car.dart';

class CarDetailsScreen extends StatefulWidget {
  const CarDetailsScreen({
    super.key,
    required this.car,
    this.onContact,
    this.onFavorite,
  });

  final Car car;
  final VoidCallback? onContact;
  final VoidCallback? onFavorite;

  @override
  State<CarDetailsScreen> createState() =>
      _CarDetailsScreenState();
}

class _CarDetailsScreenState
    extends State<CarDetailsScreen> {
  int currentImage = 0;
  bool favorite = false;

  @override
  Widget build(BuildContext context) {
    final car = widget.car;

    return Scaffold(
      backgroundColor: const Color(0xFF08080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111116),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'تفاصيل السيارة',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                favorite = !favorite;
              });

              widget.onFavorite?.call();
            },
            icon: Icon(
              favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: favorite
                  ? const Color(0xFFFF176F)
                  : Colors.white,
            ),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 30,
          ),
          children: [
            _imageGallery(),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _titleSection(),
                  const SizedBox(height: 15),
                  _specifications(),
                  const SizedBox(height: 15),
                  _description(),
                  const SizedBox(height: 15),
                  _location(),
                  const SizedBox(height: 20),
                  _contactButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageGallery() {
    final images = widget.car.images;

    if (images.isEmpty) {
      return Container(
        height: 270,
        color: const Color(0xFF18181F),
        child: const Center(
          child: Icon(
            Icons.directions_car_rounded,
            color: Colors.white24,
            size: 85,
          ),
        ),
      );
    }

    return SizedBox(
      height: 290,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                currentImage = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF18181F),
                    child: const Center(
                      child: Icon(
                        Icons
                            .image_not_supported_outlined,
                        color: Colors.white24,
                        size: 65,
                      ),
                    ),
                  );
                },
              );
            },
          ),

          Positioned(
            top: 14,
            right: 14,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(.65),
                borderRadius:
                    BorderRadius.circular(10),
              ),
              child: Text(
                '${currentImage + 1} / ${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: List.generate(
                images.length > 8
                    ? 8
                    : images.length,
                (index) {
                  final selected =
                      index == currentImage;

                  return AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 180,
                    ),
                    margin:
                        const EdgeInsets.symmetric(
                      horizontal: 3,
                    ),
                    width: selected ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(
                              0xFFFF176F,
                            )
                          : Colors.white54,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _titleSection() {
    final car = widget.car;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _planBadge(),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            '${car.year} • ${car.city}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${car.formattedPrice} د.ع',
            style: const TextStyle(
              color: Color(0xFFFF176F),
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _planBadge() {
    final plan = widget.car.plan;

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF321222),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0xFFFF176F),
        ),
      ),
      child: Text(
        plan,
        style: const TextStyle(
          color: Color(0xFFFF176F),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _specifications() {
    final car = widget.car;

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'مواصفات السيارة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _spec(
                Icons.calendar_today_outlined,
                'سنة الصنع',
                car.year.toString(),
              ),
              _spec(
                Icons.speed_outlined,
                'الممشى',
                '${car.formattedKm} كم',
              ),
              _spec(
                Icons.local_gas_station_outlined,
                'الوقود',
                car.fuel,
              ),
              _spec(
                Icons.settings_outlined,
                'ناقل الحركة',
                car.transmission,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _spec(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D11),
        borderRadius:
            BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFFF176F),
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
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

  Widget _description() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'الوصف',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.car.description.isEmpty
                ? 'لا يوجد وصف مضاف لهذه السيارة.'
                : widget.car.description,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 13,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _location() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF321222),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFFFF176F),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'موقع السيارة',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                widget.car.city,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: widget.onContact,
        icon: const Icon(
          Icons.phone_in_talk_rounded,
        ),
        label: const Text(
          'تواصل مع صاحب السيارة',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFFFF176F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
