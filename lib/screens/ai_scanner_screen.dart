import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AiScannerScreen extends StatefulWidget {
  const AiScannerScreen({super.key, required this.api});
  final ApiService api;
  @override State<AiScannerScreen> createState() => _AiScannerScreenState();
}

class _AiScannerScreenState extends State<AiScannerScreen> {
  final picker = ImagePicker();
  XFile? image;
  Map<String, dynamic>? result;
  bool loading = false;

  Future<void> pick(ImageSource source) async {
    try {
      final x = await picker.pickImage(source: source, imageQuality: 88, maxWidth: 1800, maxHeight: 1800);
      if (x == null) return;
      setState(() { image = x; result = null; });
    } catch (_) { _msg('تعذر اختيار الصورة'); }
  }

  Future<void> analyze() async {
    if (image == null) return _msg('اختر صورة السيارة أولاً');
    setState(() => loading = true);
    try {
      final d = await widget.api.analyzeCarImage(image!);
      if (!mounted) return;
      setState(() => result = d is Map && d['analysis'] is Map ? Map<String, dynamic>.from(d['analysis']) : null);
      if (result == null) _msg('لم يرجع الذكاء الاصطناعي بيانات مفيدة');
    } on ApiException catch (e) { _msg(e.message); }
    catch (_) { _msg('تعذر تحليل الصورة'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05070D),
        appBar: AppBar(title: const Text('فحص السيارة بالذكاء الاصطناعي', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
        body: ListView(padding: const EdgeInsets.all(16), children: [
          Container(height: 330, clipBehavior: Clip.antiAlias, decoration: BoxDecoration(color: const Color(0xFF0D1420), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFF1597FF).withOpacity(.35))), child: image == null ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.directions_car_filled_rounded, color: Colors.white24, size: 72), SizedBox(height: 12), Text('صوّر السيارة أو اختر صورة', style: TextStyle(color: Colors.white54))])) : Image.file(File(image!.path), fit: BoxFit.cover)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: loading ? null : () => pick(ImageSource.camera), icon: const Icon(Icons.camera_alt_rounded), label: const Text('الكاميرا'))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton.icon(onPressed: loading ? null : () => pick(ImageSource.gallery), icon: const Icon(Icons.photo_library_rounded), label: const Text('المعرض'))),
          ]),
          const SizedBox(height: 12),
          SizedBox(height: 54, child: FilledButton.icon(onPressed: loading ? null : analyze, icon: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome_rounded), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF176F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17))), label: Text(loading ? 'جاري التحليل...' : 'حلل السيارة'))),
          if (result != null) ...[
            const SizedBox(height: 24),
            const Text('نتيجة التحليل', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            _resultCard('الماركة', result!['brand']),
            _resultCard('الموديل', result!['model']),
            _resultCard('السنة', result!['year']),
            _resultCard('اللون', result!['color']),
            _resultCard('نوع الهيكل', result!['body_type']),
            _resultCard('الوقود', result!['fuel']),
            _resultCard('القير', result!['transmission']),
            _resultCard('دقة التحليل', result!['confidence']),
          ],
        ]),
      ),
    );
  }

  Widget _resultCard(String title, dynamic value) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13), decoration: BoxDecoration(color: const Color(0xFF111722), borderRadius: BorderRadius.circular(15)), child: Row(children: [Text(title, style: const TextStyle(color: Colors.white54)), const Spacer(), Text(value == null ? 'غير معروف' : value.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))]));
}
