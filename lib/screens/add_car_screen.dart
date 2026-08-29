import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, required this.api});

  final ApiService api;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _model = TextEditingController();
  final _year = TextEditingController();
  final _price = TextEditingController();
  final _km = TextEditingController();
  final _city = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _images = [];

  String _fuel = 'بنزين';
  String _transmission = 'أوتوماتيك';
  String _plan = 'عادي';
  bool _loading = false;

  static const int maxImages = 8;
  static const Map<String, int> planPrices = {
    'عادي': 5000,
    'مميز': 15000,
    'VIP': 25000,
  };

  Future<void> _pickImages() async {
    if (_images.length >= maxImages) return _message('الحد الأقصى 8 صور');
    try {
      final picked = await _picker.pickMultiImage(imageQuality: 85, maxWidth: 2000, maxHeight: 2000);
      if (picked.isEmpty) return;
      setState(() => _images.addAll(picked.take(maxImages - _images.length)));
    } catch (_) {
      _message('تعذر اختيار الصور');
    }
  }

  Future<void> _camera() async {
    if (_images.length >= maxImages) return _message('الحد الأقصى 8 صور');
    try {
      final image = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 2000, maxHeight: 2000);
      if (image != null) setState(() => _images.add(image));
    } catch (_) {
      _message('تعذر فتح الكاميرا');
    }
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) return _message('أضف صورة واحدة على الأقل');

    final year = int.tryParse(_year.text.trim());
    final price = int.tryParse(_price.text.replaceAll(',', '').trim());
    final km = int.tryParse(_km.text.replaceAll(',', '').trim()) ?? 0;
    if (year == null || price == null || price <= 0) return _message('تأكد من سنة السيارة وسعرها');

    setState(() => _loading = true);
    try {
      final result = await widget.api.createCar(
        brand: _brand.text.trim(),
        model: _model.text.trim(),
        year: year,
        price: price,
        km: km,
        city: _city.text.trim(),
        fuel: _fuel,
        transmission: _transmission,
        description: _description.text.trim(),
        plan: _plan,
        images: List<XFile>.from(_images),
      );
      if (!mounted) return;
      _message('تم إرسال الإعلان للمراجعة بنجاح');
      Navigator.pop(context, result);
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('حدث خطأ أثناء نشر السيارة');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF15151B),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF292932))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFFF176F))),
  );

  Widget _field(TextEditingController controller, String label, {TextInputType? type, String? Function(String?)? validator}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      textDirection: TextDirection.rtl,
      style: const TextStyle(color: Colors.white),
      decoration: _decoration(label),
      validator: validator,
    ),
  );

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<String>(
      value: value,
      dropdownColor: const Color(0xFF15151B),
      decoration: _decoration(label),
      items: items.map((x) => DropdownMenuItem(value: x, child: Text(x, style: const TextStyle(color: Colors.white)))).toList(),
      onChanged: onChanged,
    ),
  );

  Widget _planCard(String name, int amount) {
    final selected = _plan == name;
    final description = name == 'VIP' ? 'أولوية أعلى وظهور مميز' : name == 'مميز' ? 'ظهور أفضل من الإعلان العادي' : 'نشر أساسي';
    return GestureDetector(
      onTap: () => setState(() => _plan = name),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF24131D) : const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? const Color(0xFFFF176F) : const Color(0xFF292932), width: selected ? 2 : 1),
        ),
        child: Row(children: [
          Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFFFF176F) : Colors.white38),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text(description, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          ])),
          Text('${amount.toString()} د.ع', style: const TextStyle(color: Color(0xFFFF176F), fontSize: 16, fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }

  Widget _imagesSection() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
    Row(children: [
      const Expanded(child: Text('صور السيارة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900))),
      Text('${_images.length}/8', style: const TextStyle(color: Color(0xFFFF176F), fontWeight: FontWeight.bold)),
    ]),
    const SizedBox(height: 6),
    const Text('الصورة الأولى هي الصورة الرئيسية', style: TextStyle(color: Colors.white54)),
    const SizedBox(height: 12),
    if (_images.isEmpty)
      GestureDetector(onTap: _pickImages, child: Container(height: 170, decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFF292932))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Color(0xFFFF176F), size: 48), SizedBox(height: 10), Text('أضف صور السيارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))])))
    else
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _images.length < maxImages ? _images.length + 1 : _images.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemBuilder: (_, index) {
          if (index == _images.length) return GestureDetector(onTap: _pickImages, child: Container(decoration: BoxDecoration(color: const Color(0xFF15151B), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFF292932))), child: const Icon(Icons.add_rounded, color: Color(0xFFFF176F), size: 45)));
          return Stack(fit: StackFit.expand, children: [
            ClipRRect(borderRadius: BorderRadius.circular(14), child: Image.file(File(_images[index].path), fit: BoxFit.cover)),
            if (index == 0) Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFF176F), borderRadius: BorderRadius.circular(20)), child: const Text('الرئيسية', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
            Positioned(top: 5, left: 5, child: CircleAvatar(backgroundColor: Colors.red, child: IconButton(onPressed: () => setState(() => _images.removeAt(index)), icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 18)))),
            if (index != 0) Positioned(bottom: 6, left: 6, right: 6, child: ElevatedButton(onPressed: () => setState(() { final x = _images.removeAt(index); _images.insert(0, x); }), child: const Text('اجعلها الرئيسية'))),
          ]);
        },
      ),
    const SizedBox(height: 10),
    Row(children: [
      Expanded(child: OutlinedButton.icon(onPressed: _images.length >= maxImages ? null : _pickImages, icon: const Icon(Icons.photo_library_rounded), label: const Text('المعرض'))),
      const SizedBox(width: 10),
      Expanded(child: OutlinedButton.icon(onPressed: _images.length >= maxImages ? null : _camera, icon: const Icon(Icons.camera_alt_rounded), label: const Text('الكاميرا'))),
    ]),
  ]);

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFF08080B),
      appBar: AppBar(title: const Text('نشر سيارة', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
      body: SafeArea(child: Form(key: _formKey, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _imagesSection(),
        const SizedBox(height: 22),
        _field(_brand, 'الماركة', validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الماركة' : null),
        _field(_model, 'الموديل', validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الموديل' : null),
        _field(_year, 'سنة الصنع', type: TextInputType.number, validator: (v) { final y = int.tryParse(v?.trim() ?? ''); return y == null || y < 1900 || y > DateTime.now().year + 1 ? 'أدخل سنة صحيحة' : null; }),
        _field(_price, 'سعر السيارة بالدولار الأمريكي', type: TextInputType.number, validator: (v) { final p = int.tryParse((v ?? '').replaceAll(',', '').trim()); return p == null || p <= 0 ? 'أدخل سعر السيارة بالدولار' : null; }),
        _field(_km, 'المسافة بالكيلومتر', type: TextInputType.number),
        _field(_city, 'المحافظة / المدينة', validator: (v) => v == null || v.trim().isEmpty ? 'أدخل المدينة' : null),
        _dropdown('نوع الوقود', _fuel, const ['بنزين', 'ديزل', 'هايبرد', 'كهرباء'], (v) { if (v != null) setState(() => _fuel = v); }),
        _dropdown('ناقل الحركة', _transmission, const ['أوتوماتيك', 'عادي'], (v) { if (v != null) setState(() => _transmission = v); }),
        const Text('اختر باقة النشر', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 8),
        _planCard('عادي', planPrices['عادي']!),
        _planCard('مميز', planPrices['مميز']!),
        _planCard('VIP', planPrices['VIP']!),
        _field(_description, 'وصف السيارة'),
        const SizedBox(height: 5),
        Text('رسوم النشر: ${planPrices[_plan]} د.ع', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(height: 56, child: ElevatedButton(onPressed: _loading ? null : _submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: _loading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('نشر السيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
        const SizedBox(height: 25),
      ]))),),
    ),
  );

  @override
  void dispose() {
    _brand.dispose(); _model.dispose(); _year.dispose(); _price.dispose(); _km.dispose(); _city.dispose(); _description.dispose();
    super.dispose();
  }
}
