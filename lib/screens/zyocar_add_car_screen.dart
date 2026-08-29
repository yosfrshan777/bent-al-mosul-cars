import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class ZyoCarAddCarScreen extends StatefulWidget {
  const ZyoCarAddCarScreen({super.key, required this.api});
  final ApiService api;
  @override State<ZyoCarAddCarScreen> createState() => _ZyoCarAddCarScreenState();
}

class _ZyoCarAddCarScreenState extends State<ZyoCarAddCarScreen> {
  final _form = GlobalKey<FormState>();
  final _type = TextEditingController();
  final _model = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();
  final _phone = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];
  late final List<int> years;
  int? year;
  String plan = 'عادي';
  bool loading = false;
  static const plans = {'عادي': 5000, 'مميز': 15000, 'VIP': 25000};

  @override void initState() { super.initState(); final now = DateTime.now().year; years = List.generate(now - 1999, (i) => now - i); }
  @override void dispose() { _type.dispose(); _model.dispose(); _price.dispose(); _description.dispose(); _phone.dispose(); super.dispose(); }
  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  InputDecoration _dec(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF15151B), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFF176F), width: 2)));

  Future<void> _pick() async {
    if (_images.length >= 8) return _msg('الحد الأقصى 8 صور');
    try { final xs = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 2000, maxHeight: 2000); if (mounted) setState(() => _images.addAll(xs.take(8 - _images.length))); }
    catch (_) { _msg('تعذر اختيار الصور'); }
  }
  Future<void> _camera() async {
    if (_images.length >= 8) return _msg('الحد الأقصى 8 صور');
    try { final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2000, maxHeight: 2000); if (x != null && mounted) setState(() => _images.add(x)); }
    catch (_) { _msg('تعذر فتح الكاميرا'); }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_form.currentState!.validate()) return;
    final price = int.tryParse(_price.text.replaceAll(',', '').trim());
    if (price == null || price <= 0) return _msg('أدخل السعر بالدولار');
    if (_images.isEmpty) return _msg('أضف صورة واحدة على الأقل');
    setState(() => loading = true);
    try {
      await widget.api.createCar(
        brand: _type.text.trim(), model: _model.text.trim(), year: year!, price: price,
        km: 0, city: 'غير محدد', fuel: 'غير محدد', transmission: 'غير محدد',
        description: _description.text.trim(), plan: plan, phone: _phone.text.trim(),
        bodyType: 'سيارة', images: List<XFile>.from(_images),
      );
      if (!mounted) return;
      _msg('تم إرسال الإعلان للمراجعة');
      Navigator.pop(context, true);
    } on ApiException catch (e) { _msg(e.message); }
    catch (_) { _msg('حدث خطأ أثناء نشر السيارة'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    backgroundColor: const Color(0xFF08080B),
    appBar: AppBar(title: const Text('نشر سيارة', style: TextStyle(fontWeight: FontWeight.w900))),
    body: Form(key: _form, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('صور السيارة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6), const Text('صورة واحدة على الأقل مطلوبة', style: TextStyle(color: Colors.white54)), const SizedBox(height: 10),
      if (_images.isEmpty) GestureDetector(onTap: _pick, child: Container(height: 160, decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFF292932))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Color(0xFFFF176F), size: 48), SizedBox(height: 8), Text('أضف صورة السيارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])))
      else GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _images.length < 8 ? _images.length + 1 : _images.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10), itemBuilder: (_, i) {
        if (i == _images.length) return InkWell(onTap: _pick, child: Container(decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.add_rounded, color: Color(0xFFFF176F), size: 45)));
        return Stack(fit: StackFit.expand, children: [ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(_images[i].path), fit: BoxFit.cover)), Positioned(top: 4, left: 4, child: CircleAvatar(backgroundColor: Colors.red, child: IconButton(onPressed: () => setState(() => _images.removeAt(i)), icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 18))))]);
      }),
      const SizedBox(height: 10), Row(children: [Expanded(child: OutlinedButton.icon(onPressed: _images.length >= 8 ? null : _pick, icon: const Icon(Icons.photo_library_rounded), label: const Text('المعرض'))), const SizedBox(width: 10), Expanded(child: OutlinedButton.icon(onPressed: _images.length >= 8 ? null : _camera, icon: const Icon(Icons.camera_alt_rounded), label: const Text('الكاميرا')))]),
      const SizedBox(height: 20),
      TextFormField(controller: _type, style: const TextStyle(color: Colors.white), decoration: _dec('نوع السيارة'), validator: (v) => v == null || v.trim().isEmpty ? 'اكتب نوع السيارة' : null), const SizedBox(height: 12),
      TextFormField(controller: _model, style: const TextStyle(color: Colors.white), decoration: _dec('الموديل'), validator: (v) => v == null || v.trim().isEmpty ? 'اكتب الموديل' : null), const SizedBox(height: 12),
      DropdownButtonFormField<String>(value: year?.toString(), dropdownColor: const Color(0xFF15151B), decoration: _dec('سنة الصنع'), items: years.map((e) => DropdownMenuItem(value: e.toString(), child: Text('$e', style: const TextStyle(color: Colors.white)))).toList(), onChanged: (v) => setState(() => year = int.tryParse(v ?? '')), validator: (v) => v == null ? 'اختر سنة الصنع' : null), const SizedBox(height: 12),
      TextFormField(controller: _price, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: _dec('السعر بالدولار الأمريكي'), validator: (v) { final p = int.tryParse((v ?? '').replaceAll(',', '').trim()); return p == null || p <= 0 ? 'أدخل السعر بالدولار' : null; }), const SizedBox(height: 12),
      TextFormField(controller: _description, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: _dec('وصف السيارة')), const SizedBox(height: 12),
      TextFormField(controller: _phone, keyboardType: TextInputType.phone, style: const TextStyle(color: Colors.white), decoration: _dec('رقم الهاتف'), validator: (v) => v == null || v.trim().isEmpty ? 'أدخل رقم الهاتف' : null), const SizedBox(height: 18),
      const Text('اختر باقة النشر', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 8),
      ...plans.entries.map((e) => GestureDetector(onTap: () => setState(() => plan = e.key), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: plan == e.key ? const Color(0xFF24131D) : const Color(0xFF15151B), borderRadius: BorderRadius.circular(16), border: Border.all(color: plan == e.key ? const Color(0xFFFF176F) : const Color(0xFF292932), width: plan == e.key ? 2 : 1)), child: Row(children: [Icon(plan == e.key ? Icons.radio_button_checked : Icons.radio_button_off, color: plan == e.key ? const Color(0xFFFF176F) : Colors.white38), const SizedBox(width: 12), Expanded(child: Text(e.key, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900))), Text('${e.value} د.ع', style: const TextStyle(color: Color(0xFFFF176F), fontWeight: FontWeight.w900))])))),
      const SizedBox(height: 6), SizedBox(height: 56, child: ElevatedButton(onPressed: loading ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white), child: loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('نشر السيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))), const SizedBox(height: 25),
    ])),),
  ));
}
