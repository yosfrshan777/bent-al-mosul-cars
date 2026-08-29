import 'package:flutter/material.dart';

/// Local ZYOCAR mark. No filter icon, emoji, or remote icon dependency.
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
        borderRadius: BorderRadius.circular(size * .24),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF151A24), Color(0xFF07090D)]),
        border: Border.all(color: const Color(0xFFB7C5D8).withOpacity(.18)),
        boxShadow: [BoxShadow(color: const Color(0xFFFF176F).withOpacity(.30), blurRadius: size * .32, spreadRadius: 1)],
      ),
      child: Center(
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(colors: [Color(0xFFFF4D99), Color(0xFFFF176F), Color(0xFF1597FF)]).createShader(bounds),
          child: Text('ZY', style: TextStyle(color: Colors.white, fontSize: size * .42, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic, letterSpacing: -size * .06)),
        ),
      ),
    );
    if (!showWordmark) return mark;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      mark,
      const SizedBox(width: 9),
      Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
        Text('CAR MARKET', style: TextStyle(color: Color(0xFF62CFFF), fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 2.2)),
      ]),
    ]);
  }
}
