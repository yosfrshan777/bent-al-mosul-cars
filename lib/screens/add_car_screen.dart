import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, required this.api});
  final ApiService api;
  @override State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final formKey = GlobalKey<FormState>();
  final type = TextEditingController();
  final model = TextEditingController();
  final price = TextEditingController();
  final phone = TextEditingController();
  final description = TextEditingController();
  final picker = ImagePicker();
  final years = List<int>.generate(47, (i) => 2026 - i);
  int? year;
  String plan = 'عادي';
  List<XFile> images = [];
  bool loading = false;

  InputDecoration dec(String label) => InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54), filled: true, fillColor: const Color(0xFF111722), border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(17)), borderSide: BorderSide(color: Colors.white12)), enabledBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(17)), borderSide: BorderSide(color: Colors.white12)), focusedBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(17)), borderSide: BorderSide(color: Color(0xFFFF176F), width: 1.4)));
  Widget input(TextEditingController c, String label, {TextInputType? type, bool required = false, int maxLines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, keyboardType: type, maxLines: maxLines, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), decoration: dec(label), validator: required ? (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null : null));
  Widget yearPicker() => Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<int>(value: year, dropdownColor: const Color(0xFF101722), isExpanded: true, decoration: dec('سنة الصنع'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), items: years.map((y) => DropdownMenuItem(value: y, child: Text('$y'))).toList(), onChanged: (v) => setState(() => year = v), validator: (v) => v == null ? 'اختر سنة الصنع' : null));

  Future<void> chooseImages() async {
    try {
      final picked = await picker.pickMultiImage(imageQuality: 88, maxWidth: 1800, maxHeight: 1800);
      if (picked.isEmpty) return;
      setState(() => images = picked.take(8).toList());
    } catch (_) { if (mounted) _msg('تعذر فتح معرض الصور'); }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (images.isEmpty) { _msg('اختر صورة واحدة على الأقل'); return; }
    final p = int.tryParse(price.text.replaceAll(',', '').trim());
    if (p == null || p <= 0 || year == null) { _msg('أدخل السعر بشكل صحيح'); return; }
    setState(() => loading = true);
    try {
      final result = await widget.api.createCar(brand: type.text.trim(), model: model.text.trim(), year: year!, price: p, km: 0, city: 'العراق', fuel: 'بنزين', transmission: 'أوتوماتيك', description: description.text.trim(), plan: plan, images: images, phone: phone.text.trim(), bodyType: type.text.trim());
      if (!mounted) return;
      _msg('تم إرسال السيارة للمراجعة بنجاح'); Navigator.pop(context, result);
    } catch (e) { if (mounted) _msg(e is ApiException ? e.message : 'تعذر نشر السيارة'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  void _msg(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(
    backgroundColor: const Color(0xFF05070D), appBar: AppBar(title: const Text('بيع سيارة', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true, backgroundColor: const Color(0xFF080C14)),
    body: Form(key: formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,32), children: [
      const Text('صورة السيارة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 5), const Text('صورة واحدة تكفي، ويمكن إضافة صور إضافية', style: TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 10),
      SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: images.length + 1, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) {
        if (i == images.length) return InkWell(onTap: chooseImages, borderRadius: BorderRadius.circular(18), child: Container(width: 112, decoration: BoxDecoration(color: const Color(0xFF101722), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF149BFF).withOpacity(.45))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Color(0xFF149BFF), size: 30), SizedBox(height: 5), Text('إضافة صورة', style: TextStyle(color: Colors.white70, fontSize: 10))])));
        return Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(File(images[i].path), width: 112, height: 112, fit: BoxFit.cover)), Positioned(top: 5, left: 5, child: GestureDetector(onTap: () => setState(() => images.removeAt(i)), child: Container(decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), padding: const EdgeInsets.all(3), child: const Icon(Icons.close, color: Colors.white, size: 17))))]);
      })), const SizedBox(height: 18),
      input(type, 'نوعية السيارة', required: true), input(model, 'الموديل', required: true), yearPicker(),
      input(price, 'السعر بالدولار الأمريكي', type: TextInputType.number, required: true), input(phone, 'رقم الهاتف للتواصل', type: TextInputType.phone, required: true), input(description, 'وصف السيارة', maxLines: 4),
      const SizedBox(height: 4), const Text('باقة النشر', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
      for (final item in const [('عادي',5000),('مميز',15000),('VIP',25000)]) RadioListTile<String>(value: item.$1, groupValue: plan, onChanged: (v) => setState(() => plan = v!), title: Text('${item.$1} — ${item.$2} د.ع', style: const TextStyle(color: Colors.white70)), activeColor: const Color(0xFFFF176F)),
      const SizedBox(height: 10), SizedBox(height: 54, child: FilledButton(onPressed: loading ? null : submit, style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF176F), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('نشر السيارة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)))),
    ])),
  ));
}
