import 'package:flutter/material.dart';
import 'widgets/zyocar_logo.dart';

const Color kSplashPink = Color(0xFFFF176F);
const Color kSplashBlue = Color(0xFF1597FF);

class ZyoCarSplashAnimation extends StatefulWidget {
  const ZyoCarSplashAnimation({super.key, required this.onFinished});
  final VoidCallback onFinished;

  @override
  State<ZyoCarSplashAnimation> createState() => _ZyoCarSplashAnimationState();
}

class _ZyoCarSplashAnimationState extends State<ZyoCarSplashAnimation>
    with TickerProviderStateMixin {
  late final AnimationController scene = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  )..forward();

  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    scene.dispose();
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return Scaffold(
      backgroundColor: const Color(0xFF05070B),
      body: AnimatedBuilder(
        animation: Listenable.merge([scene, pulse]),
        builder: (context, _) {
          final t = Curves.easeOutCubic.transform(scene.value);
          final p = .92 + pulse.value * .08;
          final glow = .18 + pulse.value * .18;
          return Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: .78,
                    colors: [
                      kSplashPink.withOpacity(.07),
                      kSplashBlue.withOpacity(.025),
                      const Color(0xFF05070B),
                    ],
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(0, 34 * (1 - t)),
                  child: Transform.scale(
                    scale: (.72 + .28 * t) * p,
                    child: Opacity(
                      opacity: Curves.easeOut.transform(scene.value),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 150 + 28 * t,
                            height: 150 + 28 * t,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: kSplashPink.withOpacity(glow), blurRadius: 55, spreadRadius: 4),
                                BoxShadow(color: kSplashBlue.withOpacity(glow * .55), blurRadius: 70, spreadRadius: 2),
                              ],
                            ),
                          ),
                          Container(
                            width: 128,
                            height: 128,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(.10), width: 1.2),
                            ),
                          ),
                          const ZyoCarLogo(size: 104, showWordmark: false),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: height * .18,
                child: Column(
                  children: [
                    Opacity(
                      opacity: (t - .35).clamp(0.0, 1.0),
                      child: const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 4)),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: (t - .55).clamp(0.0, 1.0),
                      child: const Text('سوق السيارات في العراق', style: TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: (t - .72).clamp(0.0, 1.0),
                      child: Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), gradient: const LinearGradient(colors: [kSplashPink, kSplashBlue])),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
