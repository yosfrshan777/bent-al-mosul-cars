import 'package:flutter/material.dart';

class CarBrandLogo extends StatelessWidget {
  const CarBrandLogo({
    super.key,
    required this.brand,
    this.size = 42,
    this.background = const Color(0xFF0D1522),
    this.showName = false,
  });

  final String brand;
  final double size;
  final Color background;
  final bool showName;

  static final Map<String, String> _slugs = {
    'toyota': 'toyota', 'تويوتا': 'toyota',
    'hyundai': 'hyundai', 'هيونداي': 'hyundai',
    'bmw': 'bmw', 'بي ام دبليو': 'bmw', 'بي إم دبليو': 'bmw',
    'mercedes': 'mercedes', 'mercedes-benz': 'mercedes', 'مرسيدس': 'mercedes',
    'kia': 'kia', 'كيا': 'kia',
    'audi': 'audi', 'أودي': 'audi',
    'ford': 'ford', 'فورد': 'ford',
    'chevrolet': 'chevrolet', 'شيفروليه': 'chevrolet',
    'mazda': 'mazda', 'مازدا': 'mazda',
    'honda': 'honda', 'هوندا': 'honda',
    'nissan': 'nissan', 'نيسان': 'nissan',
    'volvo': 'volvo', 'فولفو': 'volvo',
    'volkswagen': 'volkswagen', 'فولكس فاجن': 'volkswagen',
    'porsche': 'porsche', 'بورشه': 'porsche',
    'jaguar': 'jaguar', 'جاكوار': 'jaguar',
    'land rover': 'landrover', 'landrover': 'landrover', 'لاند روفر': 'landrover',
    'jeep': 'jeep', 'جيب': 'jeep',
    'tesla': 'tesla', 'تسلا': 'tesla',
    'mitsubishi': 'mitsubishi', 'ميتسوبيشي': 'mitsubishi',
    'suzuki': 'suzuki', 'سوزوكي': 'suzuki',
    'subaru': 'subaru', 'سوبارو': 'subaru',
    'renault': 'renault', 'رينو': 'renault',
    'peugeot': 'peugeot', 'بيجو': 'peugeot',
    'citroen': 'citroen', 'سيتروين': 'citroen',
    'fiat': 'fiat', 'فيات': 'fiat',
    'alfaromeo': 'alfaromeo', 'alfa romeo': 'alfaromeo', 'الفا روميو': 'alfaromeo',
    'astonmartin': 'astonmartin', 'aston martin': 'astonmartin', 'استون مارتن': 'astonmartin',
    'bentley': 'bentley', 'بنتلي': 'bentley',
    'lamborghini': 'lamborghini', 'لامبورغيني': 'lamborghini',
    'mclaren': 'mclaren', 'ماكلارين': 'mclaren',
    'maserati': 'maserati', 'مازيراتي': 'maserati',
    'chrysler': 'chrysler', 'كرايسلر': 'chrysler',
    'ram': 'ram', 'رام': 'ram',
    'acura': 'acura', 'اكورا': 'acura',
    'infiniti': 'infiniti', 'انفينيتي': 'infiniti',
    'skoda': 'skoda', 'سكودا': 'skoda',
    'seat': 'seat', 'سيات': 'seat',
    'lada': 'lada', 'لادا': 'lada',
  };

  String get _slug => _slugs[brand.trim().toLowerCase()] ?? brand.trim().toLowerCase().replaceAll(' ', '-');

  Widget _box() {
    final clean = brand.trim();
    final logoUrl = 'https://cdn.simpleicons.org/$_slug/FFFFFF';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * .22),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      alignment: Alignment.center,
      padding: EdgeInsets.all(size * .18),
      child: clean.isEmpty
          ? const Text('?', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w900))
          : Image.network(
              logoUrl,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Text(
                clean.substring(0, 1).toUpperCase(),
                style: TextStyle(color: Colors.white70, fontSize: size * .34, fontWeight: FontWeight.w900),
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!showName) return _box();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _box(),
        const SizedBox(height: 5),
        Text(brand, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800)),
      ],
    );
  }
}
