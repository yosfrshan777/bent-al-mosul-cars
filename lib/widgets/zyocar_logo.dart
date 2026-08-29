import 'package:flutter/material.dart';

/// ZYOCAR brand mark. This is drawn locally, so it never depends on
/// Flaticon, emoji packs, or a remote icon service.
class ZyoCarLogo extends StatelessWidget {
  const ZyoCarLogo({super.key, this.size = 44, this.showWordmark = true});

  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF08080B),
        borderRadius: BorderRadius.circular(size * .22),
        border: Border.all(color: const Color(0xFFFF176F).withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF176F).withOpacity(.18),
            blurRadius: size * .35,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFFFF176F), Color(0xFFFFFFFF), Color(0xFF1597FF)],
          ).createShader(bounds),
          child: Text(
            'ZY',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * .38,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: -size * .045,
            ),
          ),
        ),
      ),
    );

    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 9),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'ZYOCAR',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            Text(
              'CAR MARKET',
              style: TextStyle(
                color: Color(0xFF62CFFF),
                fontSize: 7,
                fontWeight: FontWeight.w800,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
