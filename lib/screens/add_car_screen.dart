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

  final _priceController = TextEditingController();
  final _kmController = TextEditingController();
  final _cityController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  final List<XFile> _images = [];

  String? _brand;
  String? _model;
  int? _year;

  String _fuel = 'بنزين';
  String _transmission = 'أوتوماتيك';
  String _plan = 'عادي';

  bool _loading = false;

  static const int maxImages = 8;

  final List<String> brands = [
    'Toyota',
    'BMW',
    'Mercedes-Benz',
    'Kia',
    'Hyundai',
    'Nissan',
    'Lexus',
    'Chevrolet',
    'Ford',
    'Honda',
    'Dodge',
    'GMC',
    'Jeep',
    'Audi',
    'Porsche',
    'Land Rover',
    'Cadillac',
    'Changan',
    'MG',
    'Geely',
  ];

  final Map<String, List<String>> models = {
    'Toyota': [
      'Camry',
      'Corolla',
      'Land Cruiser',
      'Hilux',
      'Prado',
      'Avalon',
      'RAV4',
    ],
    'BMW': [
      '320i',
      '330i',
      '520i',
      '530i',
      '740i',
      'X3',
      'X5',
      'X6',
    ],
    'Mercedes-Benz': [
      'C200',
      'C300',
      'E200',
      'E300',
      'S500',
      'GLE',
      'GLC',
    ],
    'Kia': [
      'K5',
      'K8',
      'Sportage',
      'Sorento',
      'Carnival',
      'Cerato',
    ],
    'Hyundai': [
      'Elantra',
      'Sonata',
      'Tucson',
      'Santa Fe',
      'Azera',
    ],
    'Nissan': [
      'Patrol',
      'Altima',
      'Maxima',
      'Sunny',
      'X-Trail',
    ],
    'Lexus': [
      'ES350',
      'LS500',
      'LX570',
      'LX600',
      'RX350',
    ],
    'Chevrolet': [
      'Tahoe',
      'Suburban',
      'Camaro',
      'Malibu',
      'Silverado',
    ],
    'Ford': [
      'Explorer',
      'Mustang',
      'F150',
      'Expedition',
      'Edge',
    ],
    'Honda': [
      'Accord',
      'Civic',
      'CR-V',
      'Pilot',
    ],
    'Dodge': [
      'Charger',
      'Challenger',
      'Durango',
      'Ram',
    ],
    'GMC': [
      'Yukon',
      'Sierra',
      'Terrain',
      'Acadia',
    ],
    'Jeep': [
      'Grand Cherokee',
      'Wrangler',
      'Gladiator',
      'Compass',
    ],
    'Audi': [
      'A3',
      'A4',
      'A6',
      'A8',
      'Q5',
      'Q7',
    ],
    'Porsche': [
      'Cayenne',
      'Panamera',
      '911',
      'Macan',
    ],
    'Land Rover': [
      'Range Rover',
      'Range Rover Sport',
      'Defender',
      'Discovery',
    ],
    'Cadillac': [
      'Escalade',
      'CT5',
      'XT5',
      'XT6',
    ],
    'Changan': [
      'CS75',
      'CS95',
      'UNI-K',
      'UNI-T',
    ],
    'MG': [
      '5',
      '6',
      'GT',
      'ZS',
      'HS',
    ],
    'Geely': [
      'Coolray',
      'Emgrand',
      'Monjaro',
      'Tugella',
    ],
  };

  @override
  void initState() {
    super.initState();
  }

  Future<void> _pickImages() async {
    if (_images.length >= maxImages) {
      _message('وصلت إلى الحد الأقصى 8 صور');
      return;
    }

    try {
      final picked = await _picker.pickMultiImage(
        imageQuality: 88,
        maxWidth: 2200,
        maxHeight: 2200,
      );

      if (picked.isEmpty) return;

      final remaining = maxImages - _images.length;

      setState(() {
        _images.addAll(picked.take(remaining));
      });
    } catch (_) {
      _message('تعذر اختيار الصور');
    }
  }

  Future<void> _takePhoto() async {
    if (_images.length >= maxImages) {
      _message('وصلت إلى الحد الأقصى 8 صور');
      return;
    }

    try {
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 88,
        maxWidth: 2200,
        maxHeight: 2200,
      );

      if (photo == null) return;

      setState(() {
        _images.add(photo);
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

    _message('تم اختيار الصورة الرئيسية');
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_brand == null || _model == null || _year == null) {
      _message('حدد الماركة والموديل والسنة');
      return;
    }

    if (_images.isEmpty) {
      _message('أضف صورة واحدة على الأقل');
      return;
    }

    final price = int.tryParse(
      _priceController.text.replaceAll(',', '').trim(),
    );

    final km = int.tryParse(
          _kmController.text.replaceAll(',', '').trim(),
        ) ??
        0;

    if (price == null || price <= 0) {
      _message('السعر غير صحيح');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final result = await widget.api.createCar(
        brand: _brand!,
        model: _model!,
        year: _year!,
        price: price,
        km: km,
        city: _cityController.text.trim(),
        fuel: _fuel,
        transmission: _transmission,
        description: _descriptionController.text.trim(),
        plan: _plan,
        images: List<XFile>.from(_images),
      );

      if (!mounted) return;

      _message('تم إرسال الإعلان للمراجعة');

      Navigator.pop(context, result);
    } on ApiException catch (e) {
      if (!mounted) return;
      _message(e.message);
    } catch (_) {
      if (!mounted) return;
      _message('حدث خطأ أثناء نشر الإعلان');
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textDirection: TextDirection.rtl,
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFF3B91),
                Color(0xFF7B6CFF),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF171722),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF858592),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _box(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.88),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) text,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFFFF3B91),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFF777783),
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(
                text(item),
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  color: Color(0xFF20202A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _textInput({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return _box(
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Color(0xFF20202A),
          fontWeight: FontWeight.w700,
        ),
        validator: (value) {
          if (label == 'السعر' &&
              (value == null || value.trim().isEmpty)) {
            return 'أدخل السعر';
          }

          if (label == 'المحافظة' &&
              (value == null || value.trim().isEmpty)) {
            return 'أدخل المحافظة';
          }

          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF777783),
          ),
          hintStyle: const TextStyle(
            color: Color(0xFFAAAAAF),
            fontSize: 11,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _imagesSection() {
    return Column(
      children: [
        _sectionTitle(
          'صور السيارة',
          'الصورة الأولى ستكون واجهة الإعلان',
          Icons.photo_camera_back_rounded,
        ),
        const SizedBox(height: 14),
        if (_images.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 205,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.82),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: const Color(0xFFFF8FBD),
                  width: 1.4,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 48,
                    color: Color(0xFFFF3B91),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'أضف صور سيارتك',
                    style: TextStyle(
                      color: Color(0xFF20202A),
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'حتى 8 صور',
                    style: TextStyle(
                      color: Color(0xFF9999A4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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
            itemBuilder: (_, index) {
              if (index == _images.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.8),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      size: 45,
                      color: Color(0xFFFF3B91),
                    ),
                  ),
                );
              }

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.file(
                      File(_images[index].path),
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (index == 0)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF3B91),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 7,
                    left: 7,
                    child: GestureDetector(
                      onTap: () => _deleteImage(index),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.65),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  if (index != 0)
                    Positioned(
                      bottom: 7,
                      left: 7,
                      right: 7,
                      child: GestureDetector(
                        onTap: () => _mainImage(index),
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(.68),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Text(
                              'اجعلها الرئيسية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _smallButton(
                Icons.photo_library_rounded,
                'المعرض',
                _pickImages,
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _smallButton(
                Icons.camera_alt_rounded,
                'الكاميرا',
                _takePhoto,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _smallButton(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: const Color(0xFFFF3B91),
            ),
            const SizedBox(width: 7),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF353540),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _planCard() {
    final plans = [
      ('عادي', '5,000', Icons.bolt_rounded),
      ('مميز', '15,000', Icons.star_rounded),
      ('VIP', '25,000', Icons.workspace_premium_rounded),
    ];

    return Column(
      children: [
        _sectionTitle(
          'نوع الإعلان',
          'اختار مستوى ظهور إعلانك',
          Icons.auto_awesome_rounded,
        ),
        const SizedBox(height: 14),
        Row(
          children: plans.map((plan) {
            final selected = _plan == plan.$1;

            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _plan = plan.$1;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: EdgeInsets.only(
                    left: plan.$1 == 'عادي' ? 0 : 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFF3B91),
                              Color(0xFF7B6CFF),
                            ],
                          )
                        : null,
                    color: selected
                        ? null
                        : Colors.white.withOpacity(.8),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: selected
                          ? Colors.transparent
                          : Colors.white,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        plan.$3,
                        color: selected
                            ? Colors.white
                            : const Color(0xFFFF3B91),
                        size: 23,
                      ),
                      const SizedBox(height: 7),
                      Text(
                        plan.$1,
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : const Color(0xFF292934),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${plan.$2} د.ع',
                        style: TextStyle(
                          color: selected
                              ? Colors.white70
                              : const Color(0xFF888894),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4E8F4),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0xFFFFE6F1),
                Color(0xFFE4F1FF),
                Color(0xFFF4E8FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  35,
                ),
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.75),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF25252F),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'أضف إعلانك',
                              style: TextStyle(
                                color: Color(0xFF171722),
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              'خلّي سيارتك تظهر بشكل يليق بيها',
                              style: TextStyle(
                                color: Color(0xFF858592),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 47,
                        height: 47,
                        decoration: BoxDecoration(
                          color: const Color(0xFF171722),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(
                          child: Text(
                            'ZY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  _imagesSection(),

                  const SizedBox(height: 28),

                  _sectionTitle(
                    'معلومات السيارة',
                    'حدد التفاصيل من القوائم',
                    Icons.directions_car_filled_rounded,
                  ),

                  const SizedBox(height: 14),

                  _box(
                    _dropdown<String>(
                      label: 'ماركة السيارة',
                      value: _brand,
                      items: brands,
                      text: (v) => v,
                      onChanged: (value) {
                        setState(() {
                          _brand = value;
                          _model = null;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 11),

                  _box(
                    _dropdown<String>(
                      label: 'الموديل',
                      value: _model,
                      items: _brand == null
                          ? []
                          : (models[_brand] ?? []),
                      text: (v) => v,
                      onChanged: (value) {
                        setState(() {
                          _model = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 11),

                  _box(
                    _dropdown<int>(
                      label: 'سنة الصنع',
                      value: _year,
                      items: List.generate(
                        DateTime.now().year - 1989,
                        (i) => DateTime.now().year - i,
                      ),
                      text: (v) => '$v',
                      onChanged: (value) {
                        setState(() {
                          _year = value;
                        });
                      },
                    ),
                  ),

                  const SizedBox(height: 11),

                  Row(
                    children: [
                      Expanded(
                        child: _box(
                          _dropdown<String>(
                            label: 'الجير',
                            value: _transmission,
                            items: const [
                              'أوتوماتيك',
                              'عادي',
                            ],
                            text: (v) => v,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _transmission = value;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: _box(
                          _dropdown<String>(
                            label: 'الوقود',
                            value: _fuel,
                            items: const [
                              'بنزين',
                              'ديزل',
                              'هايبرد',
                              'كهرباء',
                            ],
                            text: (v) => v,
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() {
                                _fuel = value;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 11),

                  _textInput(
                    controller: _priceController,
                    label: 'السعر',
                    hint: 'السعر بالدولار',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 11),

                  _textInput(
                    controller: _kmController,
                    label: 'الممشى',
                    hint: 'مثلاً 120000 كم',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 11),

                  _textInput(
                    controller: _cityController,
                    label: 'المحافظة',
                    hint: 'مثلاً نينوى',
                  ),

                  const SizedBox(height: 11),

                  _textInput(
                    controller: _descriptionController,
                    label: 'الوصف',
                    hint: 'اكتب ملاحظاتك عن السيارة...',
                    maxLines: 5,
                  ),

                  const SizedBox(height: 28),

                  _planCard(),

                  const SizedBox(height: 28),

                  SizedBox(
                    height: 58,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF171722),
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.rocket_launch_rounded,
                                ),
                                SizedBox(width: 9),
                                Text(
                                  'نشر إعلان السيارة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
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
    _priceController.dispose();
    _kmController.dispose();
    _cityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
