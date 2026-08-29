import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.api});
  final ApiService api;
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false, _hidePassword = true;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final result = await widget.api.login(username: _username.text.trim(), phone: _phone.text.trim(), password: _password.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول بنجاح')));
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء تسجيل الدخول')));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, color: const Color(0xFFFF176F)), filled: true, fillColor: const Color(0xFF15151B),
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
      body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 25),
        Center(child: Container(width: 85, height: 85, decoration: BoxDecoration(color: const Color(0xFFFF176F), borderRadius: BorderRadius.circular(25)), child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 43))),
        const SizedBox(height: 20),
        const Text('ZYOCAR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 6),
        const Text('أدخل بيانات حسابك للدخول', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
        const SizedBox(height: 32),
        TextFormField(controller: _username, style: const TextStyle(color: Colors.white), decoration: _decoration('اسم المستخدم', Icons.person_rounded), validator: (v) => v == null || v.trim().isEmpty ? 'أدخل اسم المستخدم' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _phone, keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, style: const TextStyle(color: Colors.white), decoration: _decoration('رقم الهاتف', Icons.phone_rounded), validator: (v) => v == null || v.trim().length < 8 ? 'أدخل رقم هاتف صحيح' : null),
        const SizedBox(height: 14),
        TextFormField(controller: _password, obscureText: _hidePassword, style: const TextStyle(color: Colors.white), decoration: _decoration('كلمة المرور', Icons.lock_rounded).copyWith(suffixIcon: IconButton(onPressed: () => setState(() => _hidePassword = !_hidePassword), icon: Icon(_hidePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded, color: Colors.white54))), validator: (v) => v == null || v.isEmpty ? 'أدخل كلمة المرور' : null),
        const SizedBox(height: 25),
        SizedBox(height: 55, child: ElevatedButton(onPressed: _loading ? null : _login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('دخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
        const SizedBox(height: 15),
        TextButton(onPressed: _loading ? null : () async { final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen(api: widget.api))); if (result != null && mounted) Navigator.pop(context, result); }, child: const Text('ما عندك حساب؟ إنشاء حساب جديد', style: TextStyle(color: Color(0xFFFF4F91), fontWeight: FontWeight.bold))),
      ]))),
    ),
  );

  @override void dispose() { _username.dispose(); _phone.dispose(); _password.dispose(); super.dispose(); }
}
