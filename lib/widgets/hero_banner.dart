import 'package:flutter/material.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({
    super.key,
    this.onSellCar,
    this.onBrowseCars,
  });

  final VoidCallback? onSellCar;
  final VoidCallback? onBrowseCars;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 230,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color(0xFF3A1026),
              Color(0xFF17131B),
              Color(0xFF101014),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF3A2934),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: -45,
              bottom: -55,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF176F)
                      .withOpacity(.08),
                ),
              ),
            ),

            Positioned(
              left: 15,
              bottom: 15,
              child: Transform.rotate(
                angle: -0.08,
                child: Icon(
                  Icons.directions_car_filled_rounded,
                  size: 105,
                  color: Colors.white
                      .withOpacity(.055),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 11,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF176F)
                          .withOpacity(.13),
                      borderRadius:
                          BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(
                          0xFFFF176F,
                        ).withOpacity(.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .verified_rounded,
                          color:
                              Color(0xFFFF176F),
                          size: 15,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'سوق السيارات العراقي',
                          style: TextStyle(
                            color:
                                Color(0xFFFF6B9F),
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'سيارتك القادمة\nتبدأ من هنا',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 9),

                  const Text(
                    'بيع سيارتك أو ابحث عن سيارتك المناسبة بسهولة.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: onSellCar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFF176F),
                          foregroundColor:
                              Colors.white,
                          elevation: 0,
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 17,
                            vertical: 12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child: const Text(
                          'بيع سيارتك',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                      ),

                      const SizedBox(width: 9),

                      OutlinedButton(
                        onPressed: onBrowseCars,
                        style:
                            OutlinedButton.styleFrom(
                          foregroundColor:
                              Colors.white,
                          side: const BorderSide(
                            color: Color(
                              0xFF4A4650,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 17,
                            vertical: 12,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(
                              12,
                            ),
                          ),
                        ),
                        child: const Text(
                          'تصفح السيارات',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
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
}
