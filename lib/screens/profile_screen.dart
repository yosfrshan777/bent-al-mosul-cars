import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'admin_screen.dart';
import 'payment_barcode_screen.dart';
import 'ai_scanner_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.api});
  final ApiService api;
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  Map<String, dynamic>? user;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { try { final d = await widget.api.me(); if (!mounted) return; if (d is Map && d['user'] is Map) setState(() => user = Map<String, dynamic>.from(d['user'])); } catch (_) {} finally { if (mounted) setState(() => loading = false); } }
  bool get isAdmin { final r = user?['role']?.toString(); return r == 'admin' || r == 'owner'; }
  String name() => user?['name']?.toString() ?? 'مستخدم ZYOCAR';
  String phone() => user?['phone']?.toString() ?? '';
  String role() { switch (user?['role']?.toString()) { case 'owner': return 'المالك'; case 'admin': return 'مدير'; case 'showroom': return 'صاحب معرض'; case 'parts': return 'صاحب قطع غيار'; case 'seller': return 'بائع'; default: return 'مستخدم'; } }
  Future<void> login() async { final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api))); if (r != null) await _load(); }
  Future<void> logout() async { try { await widget.api.logout(); } catch (_) { await widget.api.clearToken(); } if (!mounted) return; setState(() => user = null); _msg('تم تسجيل الخروج'); }
  void _msg(String s) { if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s))); }
  Widget item({required IconData icon, required String title, required VoidCallback onTap, String? subtitle}) => Container(margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF292932))), child: ListTile(onTap: onTap, leading: Container(width: 43, height: 43, decoration: BoxDecoration(color: const Color(0xFF28141F), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: const Color(0xFFFF176F))), title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), subtitle: subtitle == null ? null : Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)), trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white30)));

  @override Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(title: const Text('حسابي', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF176F)))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF321222), Color(0xFF15151B)]),
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: const Color(0xFF3A2631)),
                    ),
                    child: Row(
                      children: [
                        Container(width: 65, height: 65, decoration: const BoxDecoration(color: Color(0xFFFF176F), shape: BoxShape.circle), child: const Icon(Icons.person_rounded, color: Colors.white, size: 34)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name(), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                              if (phone().isNotEmpty) Padding(padding: const EdgeInsets.only(top: 4), child: Text(phone(), style: const TextStyle(color: Colors.white54))),
                              const SizedBox(height: 5),
                              Text(role(), style: const TextStyle(color: Color(0xFFFF4F91), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (user != null) item(icon: Icons.auto_awesome_rounded, title: 'فحص السيارة بالذكاء الاصطناعي', subtitle: 'تعرف على الماركة والموديل من الصورة', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AiScannerScreen(api: widget.api)))),
                  if (user != null) item(icon: Icons.qr_code_2_rounded, title: 'باركود الدفع', subtitle: 'امسح الباركود لدفع رسوم ZYOCAR', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentBarcodeScreen(api: widget.api)))),
                  if (user == null) item(icon: Icons.login_rounded, title: 'تسجيل الدخول', subtitle: 'ادخل إلى حسابك', onTap: login),
                  if (user == null) item(icon: Icons.person_add_rounded, title: 'إنشاء حساب', subtitle: 'أنشئ حساب ZYOCAR جديد', onTap: login),
                  if (user != null) item(icon: Icons.directions_car_rounded, title: 'إعلاناتي', subtitle: 'السيارات التي أضفتها', onTap: () => _msg('إعلاناتك مرتبطة بالسيرفر')),
                  if (user != null) item(icon: Icons.favorite_rounded, title: 'المفضلة', subtitle: 'السيارات المحفوظة', onTap: () => _msg('المفضلة قيد الربط')),
                  if (isAdmin) item(icon: Icons.admin_panel_settings_rounded, title: 'لوحة الإدارة', subtitle: 'إدارة ZYOCAR', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AdminScreen(api: widget.api)))),
                  if (user != null) item(icon: Icons.logout_rounded, title: 'تسجيل الخروج', onTap: logout),
                  const SizedBox(height: 25),
                  const Center(child: Text('ZYOCAR', style: TextStyle(color: Colors.white24, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2))),
                ],
              ),
      ),
    );
  }
}
