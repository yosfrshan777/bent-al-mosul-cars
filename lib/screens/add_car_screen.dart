import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final formKey = GlobalKey<FormState>();
  final brand = TextEditingController();
  final model = TextEditingController();
  final year = TextEditingController();
  final price = TextEditingController();
  final km = TextEditingController();
  final city = TextEditingController();
  final description = TextEditingController();
  String fuel = 'بنزين';
  String transmission = 'أوتوماتيك';
  String plan = 'عادي';
  bool loading = false;

  InputDecoration decoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF15151B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF292932)),
        ),
      );

  Widget field(TextEditingController c, String label,
      {TextInputType? keyboardType, bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(color: Colors.white),
        decoration: decoration(label),
        validator: required
            ? (v) => v == null || v.trim().isEmpty ? 'هذا الحقل مطلوب' : null
            : null,
      ),
    );
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    final y = int.tryParse(year.text.trim());
    final p = int.tryParse(price.text.replaceAll(',', '').trim());
    final k = int.tryParse(km.text.replaceAll(',', '').trim()) ?? 0;
    if (y == null || p == null || p <= 0) return;
    setState(() => loading = true);
    try {
      final result = await widget.api.createCar(
        brand: brand.text.trim(),
        model: model.text.trim(),
        year: y,
        price: p,
        km: k,
        city: city.text.trim(),
        fuel: fuel,
        transmission: transmission,
        description: description.text.trim(),
        plan: plan,
        images: const [],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال السيارة للمراجعة بنجاح')),
      );
      Navigator.pop(context, result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e is ApiException ? e.message : 'تعذر نشر السيارة')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text('نشر سيارة', style: TextStyle(fontWeight: FontWeight.w900)),
          centerTitle: true,
        ),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('بيانات السيارة', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 14),
              field(brand, 'الماركة', required: true),
              field(model, 'الموديل', required: true),
              field(year, 'سنة الصنع', keyboardType: TextInputType.number, required: true),
              field(price, 'السعر بالدولار الأمريكي', keyboardType: TextInputType.number, required: true),
              field(km, 'المسافة بالكيلومتر', keyboardType: TextInputType.number),
              field(city, 'المحافظة / المدينة', required: true),
              DropdownButtonFormField<String>(
                value: fuel,
                dropdownColor: const Color(0xFF15151B),
                decoration: decoration('نوع الوقود'),
                items: const ['بنزين', 'ديزل', 'هايبرد', 'كهرباء'].map((x) => DropdownMenuItem(value: x, child: Text(x, style: TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) { if (v != null) setState(() => fuel = v); },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: transmission,
                dropdownColor: const Color(0xFF15151B),
                decoration: decoration('ناقل الحركة'),
                items: const ['أوتوماتيك', 'عادي'].map((x) => DropdownMenuItem(value: x, child: Text(x, style: TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) { if (v != null) setState(() => transmission = v); },
              ),
              const SizedBox(height: 18),
              const Text('باقة النشر', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              for (final item in const [('عادي', 5000), ('مميز', 15000), ('VIP', 25000)])
                RadioListTile<String>(
                  value: item.$1,
                  groupValue: plan,
                  onChanged: (v) { if (v != null) setState(() => plan = v); },
                  title: Text(item.$1, style: const TextStyle(color: Colors.white)),
                  subtitle: Text('${item.$2} د.ع', style: const TextStyle(color: Colors.white54)),
                  activeColor: const Color(0xFFFF176F),
                ),
              const SizedBox(height: 8),
              field(description, 'وصف السيارة'),
              const SizedBox(height: 12),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF176F), foregroundColor: Colors.white),
                  child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('نشر السيارة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    brand.dispose(); model.dispose(); year.dispose(); price.dispose(); km.dispose(); city.dispose(); description.dispose();
    super.dispose();
  }
}
