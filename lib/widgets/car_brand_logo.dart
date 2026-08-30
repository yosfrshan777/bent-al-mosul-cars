import 'package:flutter/material.dart';

/// Brand presentation intentionally uses text only.
/// ZYOCAR does not load third-party vehicle logos.
class CarBrandLogo extends StatelessWidget {
  const CarBrandLogo({
    super.key,
    required this.brand,
    this.size = 42,
    this.background = const Color(0xFF0D1522),
    this.showName = false,
  });

  final String brand;
  final double size;
  final Color background;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    final clean = brand.trim().isEmpty ? 'سيارة' : brand.trim();
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * .22),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: size * .10),
      child: Text(
        clean,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: size * .22,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    if (!showName) return box;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(height: 5),
        Text(
          clean,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
