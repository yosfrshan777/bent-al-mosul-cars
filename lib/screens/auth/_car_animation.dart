import 'dart:math' as math;
import 'package:flutter/material.dart';

class MovingBlackCar extends StatefulWidget {
  const MovingBlackCar({super.key});

  @override
  State<MovingBlackCar> createState() => _MovingBlackCarState();
}

class _MovingBlackCarState extends State<MovingBlackCar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final x = -1.15 + t * 2.3;
        final bounce = math.sin(_controller.value * math.pi * 4) * 1.2;
        return Container(
          height: 205,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF101820), Color(0xFF07090D)],
            ),
            border: Border.all(color: Colors.white24),
            boxShadow: const [
              BoxShadow(color: Color(0x55FF176F), blurRadius: 26, spreadRadius: -14),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _CarRoadPainter(t))),
              Positioned(
                left: 18,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'ZYOCAR • LOGIN',
                    style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5),
                  ),
                ),
              ),
              Align(
                alignment: Alignment(x, .27),
                child: Transform.translate(
                  offset: Offset(0, bounce),
                  child: const _BlackCar(),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 15,
                child: Text(
                  'سجّل دخولك وابدأ',
                  style: TextStyle(color: Colors.white.withOpacity(.58), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlackCar extends StatelessWidget {
  const _BlackCar();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 170,
        height: 92,
        child: CustomPaint(painter: _BlackCarPainter()),
      );
}

class _BlackCarPainter extends CustomPainter {
  const _BlackCarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = true;
    final w = size.width;
    final h = size.height;
    p.color = Colors.black.withOpacity(.55);
    canvas.drawOval(Rect.fromLTWH(16, h - 17, w - 32, 13), p);

    final body = Path()
      ..moveTo(13, h * .64)
      ..quadraticBezierTo(20, h * .43, 48, h * .40)
      ..lineTo(67, h * .18)
      ..quadraticBezierTo(74, h * .10, 92, h * .10)
      ..lineTo(119, h * .10)
      ..quadraticBezierTo(134, h * .12, 145, h * .30)
      ..lineTo(157, h * .44)
      ..quadraticBezierTo(165, h * .50, 166, h * .65)
      ..lineTo(164, h * .72)
      ..lineTo(13, h * .72)
      ..close();
    p.shader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF343943), Color(0xFF050608)],
    ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(body, p);
    p.shader = null;

    p.color = const Color(0xFF101820);
    final windows = Path()
      ..moveTo(58, h * .38)
      ..lineTo(73, h * .19)
      ..quadraticBezierTo(78, h * .15, 91, h * .15)
      ..lineTo(101, h * .15)
      ..lineTo(106, h * .38)
      ..close()
      ..moveTo(110, h * .15)
      ..lineTo(119, h * .16)
      ..quadraticBezierTo(130, h * .19, 137, h * .36)
      ..lineTo(110, h * .38)
      ..close();
    canvas.drawPath(windows, p);

    p.color = const Color(0xFFFF176F);
    p.strokeWidth = 2.2;
    p.style = PaintingStyle.stroke;
    canvas.drawLine(27, h * .54, 148, h * .54, p);
    p.style = PaintingStyle.fill;

    p.color = Colors.white;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(145, h * .49, 13, 7), const Radius.circular(3)), p);
    p.color = const Color(0xFFB9E9FF);
    canvas.drawCircle(151, h * .525, 3, p);

    for (final x in [45.0, 132.0]) {
      p.color = const Color(0xFF050506);
      canvas.drawCircle(Offset(x, h * .73), 17, p);
      p.color = const Color(0xFF20242B);
      canvas.drawCircle(Offset(x, h * .73), 11, p);
      p.color = const Color(0xFF70757D);
      canvas.drawCircle(Offset(x, h * .73), 4, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CarRoadPainter extends CustomPainter {
  const _CarRoadPainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final roadTop = size.height * .70;
    final road = Paint()..color = Colors.black.withOpacity(.28);
    canvas.drawRect(Rect.fromLTWH(0, roadTop, size.width, size.height - roadTop), road);
    final lane = Paint()..color = Colors.white.withOpacity(.14)..strokeWidth = 2;
    final offset = (t * 58) % 58;
    for (double x = -70 + offset; x < size.width + 70; x += 58) {
      canvas.drawLine(Offset(x, size.height * .86), Offset(x + 27, size.height * .86), lane);
    }
    final glow = Paint()..color = const Color(0x44FF176F)..strokeWidth = 3;
    for (double x = -100 + t * 120; x < size.width + 100; x += 95) {
      canvas.drawLine(Offset(x, roadTop + 8), Offset(x + 48, roadTop + 8), glow);
    }
  }

  @override
  bool shouldRepaint(covariant _CarRoadPainter oldDelegate) => oldDelegate.t != t;
}
