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
  State<AddCarScreen> createState() => _AddCarScreenState();
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

  // =========================================================
  // اختيار عدة صور
  // =========================================================

  Future<void> _pickMultipleImages() async {
    if (_images.length >= maxImages) {
      _showMessage('وصلت إلى الحد الأقصى: 8 صور');
      return;
    }

    try {
      final remaining = maxImages - _images.length;

      final picked = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (picked.isEmpty) {
        return;
      }

      final available = picked.take(remaining).toList();

      setState(() {
        _images.addAll(available);
      });

      if (picked.length > remaining) {
        _showMessage(
          'تمت إضافة $remaining صور فقط لأن الحد الأقصى 8',
        );
      }
    } catch (_) {
      _showMessage('تعذر اختيار الصور');
    }
  }

  // =========================================================
  // الكاميرا
  // =========================================================

  Future<void> _takePhoto() async {
    if (_images.length >= maxImages) {
      _showMessage('وصلت إلى الحد الأقصى: 8 صور');
      return;
    }

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (photo == null) {
        return;
      }

      setState(() {
        _images.add(photo);
      });
    } catch (_) {
      _showMessage('تعذر فتح الكاميرا');
    }
  }

  // =========================================================
  // قائمة الصور
  // =========================================================

  Future<void> _showImagePickerMenu() async {
    if (_images.length >= maxImages) {
      _showMessage('وصلت إلى الحد الأقصى: 8 صور');
      return;
    }

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF15151B),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFFFF176F),
                ),
                title: const Text(
                  'اختيار عدة صور',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickMultipleImages();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFFFF176F),
                ),
                title: const Text(
                  'التقاط صورة بالكاميرا',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================
  // حذف صورة
  // =========================================================

  void _deleteImage(int index) {
    if (index < 0 || index >= _images.length) {
      return;
    }

    setState(() {
      _images.removeAt(index);
    });
  }

  // =========================================================
  // تحديد الصورة الرئيسية
  // =========================================================

  void _makeMainImage(int index) {
    if (index <= 0 || index >= _images.length) {
      return;
    }

    setState(() {
      final image = _images.removeAt(index);
      _images.insert(0, image);
    });

    _showMessage('تم تحديد الصورة الرئيسية');
  }

  // =========================================================
  // إرسال الإعلان
  // =========================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_images.isEmpty) {
      _showMessage('أضف صورة واحدة على الأقل');
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

    if (year == null) {
      _showMessage('السنة غير صحيحة');
      return;
    }

    if (price == null) {
      _showMessage('السعر غير صحيح');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await widget.api.createCar(
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: year,
        price: price,
        km: km,
        city: _cityController.text.trim(),
        fuel: _fuel,
        transmission: _transmission,
        description: _descriptionController.text.trim(),
        plan: _plan,
        images: List<XFile>.from(_images),
      );

      if (!mounted) {
        return;
      }

      _showMessage('تم إرسال السيارة بنجاح');

      Navigator.pop(
        context,
        result,
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('حدث خطأ أثناء إضافة السيارة');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // =========================================================
  // رسالة
  // =========================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  // =========================================================
  // حقل نص
  // =========================================================

  Widget _textField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
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
            color: Colors.white60,
          ),
          filled: true,
          fillColor: const Color(0xFF15151B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        validator: validator,
      ),
    );
  }

  // =========================================================
  // قسم الصور
  // =========================================================

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'صور السيارة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
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
            onTap: _showImagePickerMenu,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFF15151B),
                border: Border.all(
                  color: const Color(0xFF292932),
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo,
                    size: 50,
                    color: Color(0xFFFF176F),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'أضف صور السيارة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'يمكنك إضافة حتى 8 صور',
                    style: TextStyle(
                      color: Colors.white54,
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
            itemCount: _images.length < maxImages
                ? _images.length + 1
                : _images.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index == _images.length &&
                  _images.length < maxImages) {
                return GestureDetector(
                  onTap: _showImagePickerMenu,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151B),
                      border: Border.all(
                        color: const Color(0xFF292932),
                      ),
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                    child: const Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          size: 45,
                          color: Color(0xFFFF176F),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'إضافة صور',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final image = _images[index];

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(14),
                    child: Image.file(
                      File(image.path),
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
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF176F),
                          borderRadius:
                              BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  Positioned(
                    top: 6,
                    left: 6,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.red,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 19,
                        ),
                        onPressed: () {
                          _deleteImage(index);
                        },
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
                          _makeMainImage(index);
                        },
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.black87,
                          foregroundColor:
                              Colors.white,
                        ),
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
                        : _pickMultipleImages,
                icon: const Icon(
                  Icons.photo_library,
                ),
                label: const Text('المعرض'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _images.length >= maxImages
                        ? null
                        : _takePhoto,
                icon: const Icon(
                  Icons.camera_alt,
                ),
                label: const Text('الكاميرا'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
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
                  _buildImagesSection(),

                  const SizedBox(height: 25),

                  _textField(
                    controller: _brandController,
                    label: 'الماركة',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل الماركة';
                      }
                      return null;
                    },
                  ),

                  _textField(
                    controller: _modelController,
                    label: 'الموديل',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل الموديل';
                      }
                      return null;
                    },
                  ),

                  _textField(
                    controller: _yearController,
                    label: 'سنة الصنع',
                    keyboardType:
                        TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل السنة';
                      }

                      final year =
                          int.tryParse(value.trim());

                      if (year == null) {
                        return 'السنة غير صحيحة';
                      }

                      if (year < 1900 ||
                          year > DateTime.now().year + 1) {
                        return 'أدخل سنة صحيحة';
                      }

                      return null;
                    },
                  ),

                  _textField(
                    controller: _priceController,
                    label: 'السعر بالدينار العراقي',
                    keyboardType:
                        TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل السعر';
                      }

                      final price = int.tryParse(
                        value
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

                  _textField(
                    controller: _kmController,
                    label: 'المسافة بالكيلومتر',
                    keyboardType:
                        TextInputType.number,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return null;
                      }

                      final km = int.tryParse(
                        value
                            .replaceAll(',', '')
                            .trim(),
                      );

                      if (km == null || km < 0) {
                        return 'أدخل رقم صحيح';
                      }

                      return null;
                    },
                  ),

                  _textField(
                    controller: _cityController,
                    label: 'المحافظة / المدينة',
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل المدينة';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 4),

                  DropdownButtonFormField<String>(
                    value: _fuel,
                    dropdownColor:
                        const Color(0xFF15151B),
                    decoration:
                        InputDecoration(
                      labelText: 'نوع الوقود',
                      labelStyle:
                          const TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFF15151B),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'بنزين',
                        child: Text('بنزين'),
                      ),
                      DropdownMenuItem(
                        value: 'ديزل',
                        child: Text('ديزل'),
                      ),
                      DropdownMenuItem(
                        value: 'هايبرد',
                        child: Text('هايبرد'),
                      ),
                      DropdownMenuItem(
                        value: 'كهرباء',
                        child: Text('كهرباء'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _fuel = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _transmission,
                    dropdownColor:
                        const Color(0xFF15151B),
                    decoration:
                        InputDecoration(
                      labelText: 'ناقل الحركة',
                      labelStyle:
                          const TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFF15151B),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'أوتوماتيك',
                        child: Text('أوتوماتيك'),
                      ),
                      DropdownMenuItem(
                        value: 'عادي',
                        child: Text('عادي'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _transmission = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _plan,
                    dropdownColor:
                        const Color(0xFF15151B),
                    decoration:
                        InputDecoration(
                      labelText: 'نوع الإعلان',
                      labelStyle:
                          const TextStyle(
                        color: Colors.white60,
                      ),
                      filled: true,
                      fillColor:
                          const Color(0xFF15151B),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'عادي',
                        child: Text(
                          'عادي - 10,000 د.ع',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'مميز',
                        child: Text(
                          'مميز - 20,000 د.ع',
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'VIP',
                        child: Text(
                          'VIP - 30,000 د.ع',
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _plan = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller:
                        _descriptionController,
                    maxLines: 5,
                    textDirection:
                        TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        InputDecoration(
                      labelText: 'وصف السيارة',
                      labelStyle:
                          const TextStyle(
                        color: Colors.white60,
                      ),
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor:
                          const Color(0xFF15151B),
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

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
                            14,
                          ),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'نشر السيارة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
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

  // =========================================================
  // DISPOSE
  // =========================================================

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
