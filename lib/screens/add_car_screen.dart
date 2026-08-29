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
  final formKey = GlobalKey<FormState>();
  final price = TextEditingController();
  final km = TextEditingController();
  final phone = TextEditingController();
  final description = TextEditingController();
  final picker = ImagePicker();

  static const brands = <String>['تويوتا','هيونداي','بي إم دبليو','مرسيدس','كيا','نيسان','أودي','فورد','شيفروليه','مازدا','هوندا','لكزس','ميتسوبيشي','جيب','فولكس فاجن','بورشه','تسلا','سوزوكي','رينو','بيجو'];
  static const cities = <String>['بغداد','نينوى','البصرة','أربيل','دهوك','السليمانية','كركوك','الأنبار','صلاح الدين','ديالى','واسط','بابل','كربلاء','النجف','القادسية','ميسان','ذي قار','المثنى'];
  static const bodyTypes = <String>['سيدان','SUV','كروس أوفر','بيك أب','كوبيه','هاتشباك','فان','واجِن'];
  static const categories = <String>['اقتصادية','عائلية','فاخرة','رياضية','دفع رباعي','تجارية'];
  static const fuelTypes = <String>['بنزين','ديزل','هايبرد','كهرباء'];
  static const transmissions = <String>['أوتوماتيك','عادي'];
  final years = List<int>.generate(47, (i) => 2026 - i);
  final Map<String,List<String>> models = const {
    'تويوتا':['كامري','كورولا','لاندكروزر','راف فور','هايلاندر','برادو','يارس'], 'هيونداي':['توسان','سوناتا','إلنترا','سانتافي','كونا','أكسنت'],
    'بي إم دبليو':['X5','X3','X6','الفئة الثالثة','الفئة الخامسة','الفئة السابعة'], 'مرسيدس':['C-Class','E-Class','S-Class','GLE','GLC','G-Class'],
    'كيا':['سبورتاج','سورينتو','K5','سيراتو','سيلتوس','كارنفال'], 'نيسان':['باترول','ألتيما','سنترا','إكس تريل','صني'],
    'أودي':['A4','A6','Q5','Q7','Q8'], 'فورد':['إكسبلورر','إيدج','إف-150','موستانغ','إسكيب'],
    'شيفروليه':['تاهو','سوبربان','ماليبو','كابتيفا','سيلفرادو'], 'مازدا':['CX-5','CX-9','6','3'], 'هوندا':['أكورد','سيفيك','CR-V','بايلوت'],
    'لكزس':['LX','GX','RX','ES','IS'], 'ميتسوبيشي':['باجيرو','أوتلاندر','ASX','L200'], 'جيب':['جراند شيروكي','رانجلر','كومباس','جلاديتور'],
    'فولكس فاجن':['تيرامونت','تيغوان','جيتا','باسات'], 'بورشه':['كاين','ماكان','911','باناميرا'], 'تسلا':['Model 3','Model Y','Model S','Model X'],
    'سوزوكي':['سويفت','فيتارا','جيمني','سويفت ديزاير'], 'رينو':['داستر','كوليوس','ميغان'], 'بيجو':['3008','5008','508','2008'],
  };

  String? brand, model, city, bodyType, category;
  int? year;
  String fuel = 'بنزين', transmission = 'أوتوماتيك', plan = 'عادي';
  List<XFile> images = [];
  bool loading = false, analyzing = false;

  InputDecoration dec(String label, {String? hint}) => InputDecoration(labelText: label, hintText: hint, labelStyle: const TextStyle(color: Colors.white54), hintStyle: const TextStyle(color: Colors.white24), filled: true, fillColor: const Color(0xFF111722), prefixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white38), border: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.white12)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Colors.white12)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(17), borderSide: const BorderSide(color: Color(0xFFFF176F), width: 1.4)));

  Widget select<T>({required String label, required T? value, required List<T> items, required String Function(T) text, required ValueChanged<T?> onChanged}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: DropdownButtonFormField<T>(value: value, dropdownColor: const Color(0xFF101722), isExpanded: true, decoration: dec(label), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), items: items.map((x) => DropdownMenuItem<T>(value: x, child: Text(text(x), overflow: TextOverflow.ellipsis))).toList(), onChanged: onChanged, validator: (v) => v == null ? 'اختر $label' : null));
  Widget input(TextEditingController c, String label, {TextInputType? type, bool required = false, int maxLines = 1}) => Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, keyboardType: type, maxLines: maxLines, textDirection: TextDirection.rtl, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700), decoration: dec(label).copyWith(prefixIcon: const Icon(Icons.edit_outlined, color: Colors.white38)), validator: required ? (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null : null));

  Future<void> chooseImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 88, maxWidth: 1800, maxHeight: 1800);
    if (picked.isEmpty) return;
    if (picked.length < 2) { _msg('لازم تختار صورتين على الأقل'); return; }
    setState(() => images = picked.take(5).toList());
    if (picked.length > 5) _msg('تم اعتماد أول 5 صور فقط');
  }

  Future<void> analyze() async {
    if (images.isEmpty) { _msg('اختار صورة أولاً حتى يحللها AI'); return; }
    setState(() => analyzing = true);
    try {
      final a = await widget.api.analyzeCarImage(images.first);
      if (!mounted) return;
      final aiBrand = a['brand']?.toString(), aiModel = a['model']?.toString();
      final aiYear = int.tryParse('${a['year'] ?? ''}'), aiFuel = a['fuel']?.toString(), aiTransmission = a['transmission']?.toString();
      setState(() {
        if (aiBrand != null && brands.contains(aiBrand)) { brand = aiBrand; model = null; }
        if (aiYear != null && years.contains(aiYear)) year = aiYear;
        if (brand != null && aiModel != null && (models[brand!] ?? const []).contains(aiModel)) model = aiModel;
        if (aiFuel != null && fuelTypes.contains(aiFuel)) fuel = aiFuel;
        if (aiTransmission != null && transmissions.contains(aiTransmission)) transmission = aiTransmission;
      });
      _msg('تم تحليل السيارة بالذكاء الاصطناعي');
    } catch (e) { _msg(e is ApiException ? e.message : 'تعذر تحليل الصورة'); }
    finally { if (mounted) setState(() => analyzing = false); }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (images.length < 2 || images.length > 5) { _msg('اختر من صورتين إلى 5 صور'); return; }
    final p = int.tryParse(price.text.replaceAll(',', '').trim()), k = int.tryParse(km.text.replaceAll(',', '').trim()) ?? 0;
    if (p == null || p <= 0 || year == null || brand == null || model == null || city == null) return;
    setState(() => loading = true);
    try {
      final result = await widget.api.createCar(brand: brand!, model: model!, year: year!, price: p, km: k, city: city!, fuel: fuel, transmission: transmission, description: description.text.trim(), plan: plan, images: images, phone: phone.text.trim(), bodyType: bodyType, category: category);
      if (!mounted) return; _msg('تم إرسال السيارة للمراجعة بنجاح'); Navigator.pop(context, result);
    } catch (e) { if (mounted) _msg(e is ApiException ? e.message : 'تعذر نشر السيارة'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  void _msg(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: const Color(0xFF05070D), appBar: AppBar(title: const Text('إضافة إعلان سيارة', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true, backgroundColor: const Color(0xFF080C14)), body: Form(key: formKey, child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), children: [
    Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF27102B), Color(0xFF0D1A2A)]), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFF176F).withOpacity(.35))), child: Row(children: [Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFFF176F).withOpacity(.15)), child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFFF176F), size: 30)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text('ZYOCAR AI', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)), SizedBox(height: 4), Text('صوّر السيارة وخلي الذكاء الاصطناعي يساعدك بالبيانات', style: TextStyle(color: Colors.white60, fontSize: 10))])), IconButton(onPressed: analyzing ? null : analyze, icon: analyzing ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF176F))) : const Icon(Icons.camera_enhance_rounded, color: Colors.white))])),
    const SizedBox(height: 18), const Text('صور السيارة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 5), const Text('اختر من صورتين إلى 5 صور — هذا الحقل إجباري', style: TextStyle(color: Colors.white54, fontSize: 11)), const SizedBox(height: 10),
    SizedBox(height: 112, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: images.length + 1, separatorBuilder: (_, __) => const SizedBox(width: 10), itemBuilder: (_, i) { if (i == images.length) return InkWell(onTap: chooseImages, borderRadius: BorderRadius.circular(18), child: Container(width: 112, decoration: BoxDecoration(color: const Color(0xFF101722), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF149BFF).withOpacity(.45))), child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: Color(0xFF149BFF), size: 30), SizedBox(height: 5), Text('إضافة صور', style: TextStyle(color: Colors.white70, fontSize: 10))]))); return Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(File(images[i].path), width: 112, height: 112, fit: BoxFit.cover)), Positioned(top: 5, left: 5, child: GestureDetector(onTap: () => setState(() => images.removeAt(i)), child: Container(decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle), padding: const EdgeInsets.all(3), child: const Icon(Icons.close, color: Colors.white, size: 17))))]); })),
    const SizedBox(height: 18),
    select(label: 'الصناعة / الماركة', value: brand, items: brands, text: (x) => x, onChanged: (v) => setState(() { brand = v; model = null; })),
    select(label: 'الموديل', value: model, items: brand == null ? const <String>[] : (models[brand!] ?? const <String>[]), text: (x) => x, onChanged: (v) => setState(() => model = v)),
    select(label: 'سنة الصنع', value: year, items: years, text: (x) => '$x', onChanged: (v) => setState(() => year = v)),
    select(label: 'نوع السيارة', value: bodyType, items: bodyTypes, text: (x) => x, onChanged: (v) => setState(() => bodyType = v)),
    select(label: 'الفئة', value: category, items: categories, text: (x) => x, onChanged: (v) => setState(() => category = v)),
    select(label: 'المحافظة', value: city, items: cities, text: (x) => x, onChanged: (v) => setState(() => city = v)),
    select(label: 'نوع الوقود', value: fuel, items: fuelTypes, text: (x) => x, onChanged: (v) => setState(() => fuel = v!)),
    select(label: 'ناقل الحركة', value: transmission, items: transmissions, text: (x) => x, onChanged: (v) => setState(() => transmission = v!)),
    input(price, 'السعر بالدولار الأمريكي', type: TextInputType.number, required: true), input(km, 'المسافة بالكيلومتر', type: TextInputType.number), input(phone, 'رقم الهاتف للتواصل', type: TextInputType.phone, required: true), input(description, 'وصف السيارة', maxLines: 4), const SizedBox(height: 6),
    const Text('باقة النشر', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
    for (final item in const [('عادي',5000),('مميز',15000),('VIP',25000)]) RadioListTile<String>(value: item.$1, groupValue: plan, onChanged: (v) => setState(() => plan = v!), activeColor: const Color(0xFFFF176F), title: Text(item.$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)), subtitle: Text('${item.$2} د.ع', style: const TextStyle(color: Colors.white54))),
    const SizedBox(height: 10), SizedBox(height: 58, child: ElevatedButton(onPressed: loading ? null : submit, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('نشر الإعلان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)))),
  ]))));

  @override
  void dispose() { price.dispose(); km.dispose(); phone.dispose(); description.dispose(); super.dispose(); }
}
