import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({
    super.key,
    required this.api,
    this.onSuccess,
  });

  final ApiService api;
  final VoidCallback? onSuccess;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final yearController = TextEditingController();
  final priceController = TextEditingController();
  final kmController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  List<XFile> images = [];

  String fuel = 'بنزين';
  String transmission = 'أوتوماتيك';
  String plan = 'عادي';

  bool loading = false;
  String? error;

  @override
  void dispose() {
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();
    priceController.dispose();
    kmController.dispose();
    cityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final picked = await picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (!mounted) return;

      if (picked.isNotEmpty) {
        setState(() {
          images = picked.take(8).toList();
        });
      }
    } catch (_) {
      _showMessage('تعذر اختيار الصور');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1800,
      );

      if (!mounted || photo == null) return;

      setState(() {
        if (images.length < 8) {
          images.add(photo);
        }
      });
    } catch (_) {
      _showMessage('تعذر فتح الكاميرا');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (images.isEmpty) {
      _showMessage('أضف صورة واحدة على الأقل للسيارة');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await widget.api.createCar(
        brand: brandController.text.trim(),
        model: modelController.text.trim(),
        year: int.parse(yearController.text.trim()),
        price: int.parse(
          priceController.text
              .replaceAll(',', '')
              .trim(),
        ),
        km: int.tryParse(
              kmController.text
                  .replaceAll(',', '')
                  .trim(),
            ) ??
            0,
        city: cityController.text.trim(),
        fuel: fuel,
        transmission: transmission,
        description:
            descriptionController.text.trim(),
        images: images,
        plan: plan,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      _showMessage(
        'تم إرسال إعلانك للمراجعة',
        success: true,
      );

      widget.onSuccess?.call();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e
            .toString()
            .replaceFirst('Exception: ', '');
      });
    }
  }

  void _showMessage(
    String message, {
    bool success = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success
            ? const Color(0xFF18A558)
            : const Color(0xFF292932),
      ),
    );
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF176F),
      ),
      filled: true,
      fillColor: const Color(0xFF0D0D11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFF176F),
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: _decoration(
        hint: hint,
        icon: icon,
      ),
      validator: validator,
    );
  }

  Widget _dropdown<T>({
    required String title,
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: const Color(0xFF1A1A21),
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(
          color: Colors.white54,
        ),
        filled: true,
        fillColor: const Color(0xFF0D0D11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF292932),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF292932),
          ),
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(item.toString()),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _imagePicker() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'صور السيارة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'أضف صور واضحة للسيارة. يمكنك إضافة حتى 8 صور.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (images.isNotEmpty)
            SizedBox(
              height: 115,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final image = images[index];

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(13),
                        child: SizedBox(
                          width: 135,
                          height: 115,
                          child: kIsWeb
                              ? Image.network(
                                  image.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(image.path),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              images.removeAt(index);
                            });
                          },
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: Colors.black87,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      if (index == 0)
                        Positioned(
                          bottom: 5,
                          left: 5,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFFF176F),
                              borderRadius:
                                  BorderRadius.circular(7),
                            ),
                            child: const Text(
                              'الصورة الرئيسية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: images.length >= 8
                      ? null
                      : _pickImages,
                  icon: const Icon(
                    Icons.photo_library_outlined,
                  ),
                  label: const Text(
                    'اختيار صور',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF44444E),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: images.length >= 8
                      ? null
                      : _takePhoto,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                  ),
                  label: const Text(
                    'الكاميرا',
                  ),
                  style:
                      OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(
                      color: Color(0xFF44444E),
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String price,
    required String description,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF301323)
                : const Color(0xFF15151B),
            borderRadius:
                BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF176F)
                  : const Color(0xFF292932),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: selected
                            ? const Color(
                                0xFFFF176F,
                              )
                            : Colors.white,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ),
                  if (selected)
                    const Icon(
                      Icons.check_circle_rounded,
                      color:
                          Color(0xFFFF176F),
                      size: 19,
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                price,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plans() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'اختر نوع الإعلان',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _planCard(
                title: 'عادي',
                price: '10,000 د.ع',
                description:
                    'إعلان أساسي',
                selected: plan == 'عادي',
                onTap: () {
                  setState(() {
                    plan = 'عادي';
                  });
                },
              ),
              const SizedBox(width: 8),
              _planCard(
                title: 'مميز',
                price: '20,000 د.ع',
                description:
                    'ظهور أفضل',
                selected: plan == 'مميز',
                onTap: () {
                  setState(() {
                    plan = 'مميز';
                  });
                },
              ),
              const SizedBox(width: 8),
              _planCard(
                title: 'VIP',
                price: '30,000 د.ع',
                description:
                    'أولوية وظهور قوي',
                selected: plan == 'VIP',
                onTap: () {
                  setState(() {
                    plan = 'VIP';
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF08080B),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF111116),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'إضافة سيارة',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints:
              const BoxConstraints(
            maxWidth: 900,
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              padding:
                  const EdgeInsets.all(15),
              children: [
                _imagePicker(),
                const SizedBox(height: 14),

                Container(
                  padding:
                      const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF15151B),
                    borderRadius:
                        BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          const Color(0xFF292932),
                    ),
                  ),
                  child: Column(
                    children: [
                      _field(
                        controller:
                            brandController,
                        hint: 'ماركة السيارة',
                        icon: Icons
                            .directions_car_outlined,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'أدخل الماركة';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      _field(
                        controller:
                            modelController,
                        hint: 'الموديل',
                        icon: Icons
                            .drive_eta_outlined,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'أدخل الموديل';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller:
                                  yearController,
                              hint: 'سنة الصنع',
                              icon: Icons
                                  .calendar_today_outlined,
                              keyboardType:
                                  TextInputType
                                      .number,
                              validator: (value) {
                                final year =
                                    int.tryParse(
                                  value?.trim() ??
                                      '',
                                );

                                if (year == null ||
                                    year < 1950 ||
                                    year > 2035) {
                                  return 'السنة غير صحيحة';
                                }

                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              controller:
                                  priceController,
                              hint:
                                  'السعر بالدينار',
                              icon: Icons
                                  .payments_outlined,
                              keyboardType:
                                  TextInputType
                                      .number,
                              validator: (value) {
                                final price =
                                    int.tryParse(
                                  (value ?? '')
                                      .replaceAll(
                                    ',',
                                    '',
                                  )
                                      .trim(),
                                );

                                if (price == null ||
                                    price <= 0) {
                                  return 'أدخل السعر';
                                }

                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _field(
                              controller:
                                  kmController,
                              hint:
                                  'الممشى بالكيلومتر',
                              icon: Icons
                                  .speed_outlined,
                              keyboardType:
                                  TextInputType
                                      .number,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'أدخل الممشى';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _field(
                              controller:
                                  cityController,
                              hint: 'المدينة',
                              icon: Icons
                                  .location_on_outlined,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'أدخل المدينة';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _dropdown(
                              title: 'نوع الوقود',
                              value: fuel,
                              items: const [
                                'بنزين',
                                'ديزل',
                                'كهرباء',
                                'هايبرد',
                                'غاز',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    fuel = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _dropdown(
                              title: 'ناقل الحركة',
                              value:
                                  transmission,
                              items: const [
                                'أوتوماتيك',
                                'عادي',
                                'CVT',
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    transmission =
                                        value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller:
                            descriptionController,
                        maxLines: 5,
                        textDirection:
                            TextDirection.rtl,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: _decoration(
                          hint:
                              'اكتب تفاصيل السيارة وحالتها...',
                          icon: Icons
                              .description_outlined,
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'اكتب وصفاً للسيارة';
                          }

                          if (value.trim().length <
                              10) {
                            return 'الوصف قصير جداً';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),
                _plans(),

                if (error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding:
                        const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF35171E),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 18),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed:
                        loading ? null : _submit,
                    icon: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.publish_rounded,
                          ),
                    label: Text(
                      loading
                          ? 'جاري إرسال الإعلان...'
                          : 'إرسال الإعلان للمراجعة',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFFF176F),
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'بعد إرسال الإعلان، تتم مراجعته من الإدارة قبل نشره.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
