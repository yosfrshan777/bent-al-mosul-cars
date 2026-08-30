import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../services/api_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});
  final ApiService api;
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  bool _hidePassword = true;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await widget.api.login(phone: _phone.text.trim(), password: _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول بنجاح')));
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: const Color(0xFFFF176F)),
    filled: true, fillColor: const Color(0xFF15151B),
    labelStyle: const TextStyle(color: Colors.white60),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF292932))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFFF176F), width: 1.5)),
  );

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFF08080B),
      appBar: AppBar(title: const Text('تسجيل الدخول', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('ZYOCAR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 29, fontWeight: FontWeight.w900, letterSpacing: 3)),
          const SizedBox(height: 5),
          const Text('سوق السيارات في العراق', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 16),
          const _LoginAnimationPanel(),
          const SizedBox(height: 22),
          TextFormField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white), decoration: _decoration('رقم الهاتف', Icons.phone_rounded), validator: (v) => v == null || v.trim().length < 8 ? 'أدخل رقم هاتف صحيح' : null),
          const SizedBox(height: 14),
          TextFormField(controller: _password, obscureText: _hidePassword, style: const TextStyle(color: Colors.white), decoration: _decoration('كلمة المرور', Icons.lock_rounded).copyWith(suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white54))), validator: (v) => v == null || v.isEmpty ? 'أدخل كلمة المرور' : null),
          const SizedBox(height: 22),
          SizedBox(height: 55, child: ElevatedButton(onPressed: _loading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('دخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
          const SizedBox(height: 12),
          TextButton(onPressed: _loading ? null : () async { final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(api: widget.api))); if (result != null && mounted) Navigator.pop(context, result); }, child: const Text('ما عندك حساب؟ إنشاء حساب جديد', style: TextStyle(color: Color(0xFFFF4F91), fontWeight: FontWeight.bold))),
        ])),
      )),
    ),
  );

  @override void dispose() { _phone.dispose(); _password.dispose(); super.dispose(); }
}

class _LoginAnimationPanel extends StatefulWidget {
  const _LoginAnimationPanel();
  @override State<_LoginAnimationPanel> createState() => _LoginAnimationPanelState();
}

class _LoginAnimationPanelState extends State<_LoginAnimationPanel> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 3600))..repeat();
  @override void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final t = Curves.easeInOut.transform(_controller.value);
      final x = -1.25 + t * 2.5;
      final bounce = math.sin(_controller.value * math.pi * 10) * 2;
      return Container(
        height: 205,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF17232A), Color(0xFF080B0E)]),
          border: Border.all(color: Colors.white24),
          boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
        child: Stack(children: [
          Positioned.fill(child: CustomPaint(painter: _RoadPainter(animation: _controller.value))),
          Positioned(left: 18, top: 16, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(30)), child: const Text('ZYOCAR • LOGIN', style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)))),
          Align(alignment: Alignment(x, .34), child: Transform.translate(offset: Offset(0, bounce), child: const SizedBox(width: 190, height: 100, child: CustomPaint(painter: _BlackCarPainter())))),
          Positioned(right: 18, bottom: 15, child: Text('سجّل دخولك وابدأ', style: TextStyle(color: Colors.white.withOpacity(.58), fontSize: 11, fontWeight: FontWeight.w600))),
        ]),
      );
    },
  );
}

class _BlackCarPainter extends CustomPainter {
  const _BlackCarPainter();
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()..isAntiAlias = true;
    final body = Path()..moveTo(20, 62)..quadraticBezierTo(34, 54, 50, 51)..lineTo(70, 27)..quadraticBezierTo(83, 15, 111, 15)..lineTo(145, 17)..quadraticBezierTo(164, 21, 174, 40)..lineTo(184, 53)..quadraticBezierTo(188, 61, 181, 69)..lineTo(24, 69)..quadraticBezierTo(15, 67, 20, 62)..close();
    p.shader = const LinearGradient(colors: [Color(0xFF24262A), Color(0xFF050506)]).createShader(Rect.fromLTWH(10, 10, 180, 65));
    canvas.drawPath(body, p); p.shader = null;
    p.color = const Color(0xFF0B0C0F); canvas.drawPath(Path()..moveTo(67, 48)..lineTo(77, 30)..quadraticBezierTo(86, 20, 108, 20)..lineTo(125, 21)..lineTo(139, 46)..close(), p);
    p.color = const Color(0xFF8BD8FF); canvas.drawPath(Path()..moveTo(142, 25)..quadraticBezierTo(157, 30, 164, 43)..lineTo(145, 42)..close(), p);
    p.color = const Color(0xFFFF176F); canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(160, 51, 18, 5), const Radius.circular(3)), p);
    p.color = const Color(0xFFE8F6FF); canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(176, 50, 8, 6), const Radius.circular(3)), p);
    for (final cx in [55.0, 150.0]) { p.color = Colors.black; canvas.drawCircle(Offset(cx, 69), 17, p); p.color = const Color(0xFF4A4D53); canvas.drawCircle(Offset(cx, 69), 10, p); p.color = const Color(0xFF15171A); canvas.drawCircle(Offset(cx, 69), 5, p); }
    p.color = Colors.white24; p.strokeWidth = 2; canvas.drawLine(const Offset(7, 82), Offset(s.width - 5, 82), p);
    p.color = const Color(0x66FF176F); p.strokeWidth = 3; canvas.drawLine(const Offset(12, 76), const Offset(42, 76), p); canvas.drawLine(const Offset(155, 76), const Offset(186, 76), p);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoadPainter extends CustomPainter {
  final double animation;
  const _RoadPainter({required this.animation});
  @override
  void paint(Canvas canvas, Size s) {
    final road = Paint()..color = Colors.black54; canvas.drawRect(Rect.fromLTWH(0, s.height * .68, s.width, s.height * .32), road);
    final lane = Paint()..color = Colors.white24..strokeWidth = 2;
    final shift = animation * 58;
    for (double x = -80 + shift; x < s.width + 80; x += 58) canvas.drawLine(Offset(x, s.height * .84), Offset(x + 28, s.height * .84), lane);
  }
  @override bool shouldRepaint(covariant _RoadPainter oldDelegate) => oldDelegate.animation != animation;
}
