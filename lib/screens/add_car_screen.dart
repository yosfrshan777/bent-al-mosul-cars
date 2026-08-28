import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AddCarScreen> createState() =>
      _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<XFile> _images = [];

  String _fuel = 'بنزين';
  String _transmission = 'أوتوماتيك';
  String _plan = 'عادي';

  bool _loading = false;

  static const int maxImages = 8;

  Future<void> _pickImages() async {
    if (_images.length >= maxImages) {
      _message('الحد الأقصى 8 صور');
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (picked.isEmpty) return;

      final remaining =
          maxImages - _images.length;

      setState(() {
        _images.addAll(
          picked.take(remaining),
        );
      });
    } catch (_) {
      _message('تعذر اختيار الصور');
    }
  }

  Future<void> _camera() async {
    if (_images.length >= maxImages) {
      _message('الحد الأقصى 8 صور');
      return;
    }

    try {
      final image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (image == null) return;

      setState(() {
        _images.add(image);
      });
    } catch (_) {
      _message('تعذر فتح الكاميرا');
    }
  }

  void _deleteImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  void _mainImage(int index) {
    if (index == 0) return;

    final image = _images.removeAt(index);

    setState(() {
      _images.insert(0, image);
    });

    _message('تم تحديد الصورة الرئيسية');
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      _message('أضف صورة واحدة على الأقل');
      return;
    }

    final year = int.tryParse(
      _yearController.text.trim(),
    );

    final price = int.tryParse(
      _priceController.text
          .replaceAll(',', '')
          .trim(),
    );

    final km = int.tryParse(
          _kmController.text
              .replaceAll(',', '')
              .trim(),
        ) ??
        0;

    if (year == null ||
        price == null ||
        price <= 0) {
      _message('تأكد من السنة والسعر');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result =
          await widget.api.createCar(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        price: price,
        km: km,
        city: _cityController.text.trim(),
        fuel: _fuel,
        transmission: _transmission,
        description:
            _descriptionController.text.trim(),
        plan: _plan,
        images: List<XFile>.from(_images),
      );

      if (!mounted) return;

      _message(
        'تم إرسال الإعلان للمراجعة',
      );

      Navigator.pop(context, result);
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'حدث خطأ أثناء نشر السيارة',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white54,
          ),
          filled: true,
          fillColor: const Color(0xFF15151B),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFFF176F),
            ),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _imagesSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'صور السيارة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${_images.length}/8',
              style: const TextStyle(
                color: Color(0xFFFF176F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        const Text(
          'الصورة الأولى هي الصورة الرئيسية',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),

        const SizedBox(height: 12),

        if (_images.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF15151B),
                borderRadius:
                    BorderRadius.circular(17),
                border: Border.all(
                  color: const Color(0xFF292932),
                ),
              ),
              child: const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    color: Color(0xFFFF176F),
                    size: 48,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'أضف صور السيارة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(),
            itemCount:
                _images.length < maxImages
                    ? _images.length + 1
                    : _images.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, index) {
              if (index == _images.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF15151B),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color:
                            const Color(0xFF292932),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color:
                            Color(0xFFFF176F),
                        size: 45,
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.file(
                      File(_images[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),

                  if (index == 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(0xFFFF176F),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 6,
                    left: 6,
                    child: CircleAvatar(
                      backgroundColor:
                          Colors.red,
                      child: IconButton(
                        onPressed: () {
                          _deleteImage(index);
                        },
                        icon: const Icon(
                          Icons.delete_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  if (index != 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: ElevatedButton(
                        onPressed: () {
                          _mainImage(index);
                        },
                        child: const Text(
                          'اجعلها الرئيسية',
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _images.length >= maxImages
                        ? null
                        : _pickImages,
                icon: const Icon(
                  Icons.photo_library_rounded,
                ),
                label: const Text(
                  'المعرض',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _images.length >= maxImages
                        ? null
                        : _camera,
                icon: const Icon(
                  Icons.camera_alt_rounded,
                ),
                label: const Text(
                  'الكاميرا',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor:
            const Color(0xFF15151B),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.white54,
          ),
          filled: true,
          fillColor: const Color(0xFF15151B),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
          ),
        ),
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'إضافة سيارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  _imagesSection(),

                  const SizedBox(height: 22),

                  _field(
                    controller:
                        _brandController,
                    label: 'الماركة',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل الماركة';
                      }
                      return null;
                    },
                  ),

                  _field(
                    controller:
                        _modelController,
                    label: 'الموديل',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل الموديل';
                      }
                      return null;
                    },
                  ),

                  _field(
                    controller:
                        _yearController,
                    label: 'سنة الصنع',
                    keyboardType:
                        TextInputType.number,
                    validator: (value) {
                      final year =
                          int.tryParse(
                        value?.trim() ?? '',
                      );

                      if (year == null) {
                        return 'أدخل سنة صحيحة';
                      }

                      if (year < 1900 ||
                          year >
                              DateTime.now()
                                      .year +
                                  1) {
                        return 'السنة غير صحيحة';
                      }

                      return null;
                    },
                  ),

                  _field(
                    controller:
                        _priceController,
                    label: 'السعر بالدولار الأمريكي',
                    keyboardType:
                        TextInputType.number,
                    validator: (value) {
                      final price =
                          int.tryParse(
                        (value ?? '')
                            .replaceAll(',', '')
                            .trim(),
                      );

                      if (price == null ||
                          price <= 0) {
                        return 'أدخل سعراً صحيحاً';
                      }

                      return null;
                    },
                  ),

                  _field(
                    controller:
                        _kmController,
                    label: 'المسافة بالكيلومتر',
                    keyboardType:
                        TextInputType.number,
                  ),

                  _field(
                    controller:
                        _cityController,
                    label: 'المحافظة / المدينة',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل المدينة';
                      }
                      return null;
                    },
                  ),

                  _dropdown(
                    label: 'نوع الوقود',
                    value: _fuel,
                    items: const [
                      'بنزين',
                      'ديزل',
                      'هايبرد',
                      'كهرباء',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _fuel = value;
                      });
                    },
                  ),

                  _dropdown(
                    label: 'ناقل الحركة',
                    value: _transmission,
                    items: const [
                      'أوتوماتيك',
                      'عادي',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _transmission = value;
                      });
                    },
                  ),

                  _dropdown(
                    label: 'نوع الإعلان',
                    value: _plan,
                    items: const [
                      'عادي',
                      'مميز',
                      'VIP',
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _plan = value;
                      });
                    },
                  ),

                  _field(
                    controller:
                        _descriptionController,
                    label: 'وصف السيارة',
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _submit,
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
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'نشر السيارة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _priceController.dispose();
    _kmController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }
}
