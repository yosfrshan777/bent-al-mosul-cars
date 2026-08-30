import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});
  final ApiService api;
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  late final AnimationController _walkController;
  bool _loading = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _walkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await widget.api.login(
        phone: _phone.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل الدخول بنجاح')),
      );
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFFFF176F)),
        filled: true,
        fillColor: const Color(0xFF15151B),
        labelStyle: const TextStyle(color: Colors.white60),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF292932)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFF176F), width: 1.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'ZYOCAR',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 3),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'سوق السيارات في العراق',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  const _LoginAnimationPanel(),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('رقم الهاتف', Icons.phone_rounded),
                    validator: (v) => v == null || v.trim().length < 8 ? 'أدخل رقم هاتف صحيح' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: _hidePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('كلمة المرور', Icons.lock_rounded).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white54),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'أدخل كلمة المرور' : null,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF176F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('دخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegisterScreen(api: widget.api)),
                            );
                            if (result != null && mounted) Navigator.pop(context, result);
                          },
                    child: const Text(
                      'ما عندك حساب؟ إنشاء حساب جديد',
                      style: TextStyle(color: Color(0xFFFF4F91), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _walkController.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }
}

class _LoginAnimationPanel extends StatefulWidget {
  const _LoginAnimationPanel();
  @override
  State<_LoginAnimationPanel> createState() => _LoginAnimationPanelState();
}

class _LoginAnimationPanelState extends State<_LoginAnimationPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..repeat();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(controller.value);
        final x = -0.82 + t * 1.64;
        final step = math.sin(controller.value * math.pi * 8) * 0.14;
        return Container(
          height: 205,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF172A31), Color(0xFF0D151A)],
            ),
            border: Border.all(color: Colors.white.withOpacity(.16)),
            boxShadow: [
              BoxShadow(color: Color(0xFFFF176F), blurRadius: 28, spreadRadius: -18),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _RoadPainter()),
              ),
              Positioned(
                left: 18,
                top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.22),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(.08)),
                  ),
                  child: const Text('ZYOCAR • LOGIN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                ),
              ),
              Align(
                alignment: Alignment(x, .28),
                child: Transform.translate(
                  offset: Offset(0, step),
                  child: const _WalkingPerson(),
                ),
              ),
              Positioned(
                right: 18,
                bottom: 15,
                child: Text('سجّل دخولك وابدأ', style: TextStyle(color: Colors.white.withOpacity(.58), fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WalkingPerson extends StatelessWidget {
  const _WalkingPerson();
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 72,
        height: 100,
        child: CustomPaint(painter: _WalkingPersonPainter()),
      );
}

class _WalkingPersonPainter extends CustomPainter {
  const _WalkingPersonPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = true;
    final cx = size.width / 2;
    p.color = const Color(0xFFFFC86B);
    canvas.drawCircle(Offset(cx, 15), 9, p);
    p.color = const Color(0xFFE8E8EA);
    final body = RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, 45), width: 24, height: 42), const Radius.circular(8));
    canvas.drawRRect(body, p);
    p.color = const Color(0xFF171A20);
    p.strokeWidth = 7;
    p.strokeCap = StrokeCap.round;
    final arm = math.sin(DateTime.now().millisecondsSinceEpoch / 130) * 7;
    canvas.drawLine(Offset(cx - 9, 43), Offset(cx - 20, 62 + arm), p);
    canvas.drawLine(Offset(cx + 9, 43), Offset(cx + 20, 62 - arm), p);
    final leg = math.sin(DateTime.now().millisecondsSinceEpoch / 130) * 10;
    canvas.drawLine(Offset(cx - 6, 65), Offset(cx - 15 + leg, 89), p);
    canvas.drawLine(Offset(cx + 6, 65), Offset(cx + 15 - leg, 89), p);
    p.color = const Color(0xFFFF176F);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(cx - 27, 46, 16, 12), const Radius.circular(2)), p);
    p.color = Colors.white24;
    p.strokeWidth = 3;
    canvas.drawLine(Offset(cx - 24, 94), Offset(cx + 25, 94), p);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _RoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()..color = Colors.black.withOpacity(.18);
    canvas.drawRect(Rect.fromLTWH(0, size.height * .68, size.width, size.height * .32), road);
    final lane = Paint()..color = Colors.white.withOpacity(.15)..strokeWidth = 2;
    for (double x = -30; x < size.width + 30; x += 58) {
      canvas.drawLine(Offset(x, size.height * .83), Offset(x + 25, size.height * .83), lane);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
