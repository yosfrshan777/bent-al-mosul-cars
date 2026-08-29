import 'package:flutter/material.dart';
import 'package:simple_icons/simple_icons.dart';

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

  static final Map<String, IconData> _logos = {
    'toyota': SimpleIcons.toyota,
    'تويوتا': SimpleIcons.toyota,
    'hyundai': SimpleIcons.hyundai,
    'هيونداي': SimpleIcons.hyundai,
    'bmw': SimpleIcons.bmw,
    'بي ام دبليو': SimpleIcons.bmw,
    'بي إم دبليو': SimpleIcons.bmw,
    'mercedes': SimpleIcons.mercedes,
    'mercedes-benz': SimpleIcons.mercedes,
    'مرسيدس': SimpleIcons.mercedes,
    'kia': SimpleIcons.kia,
    'كيا': SimpleIcons.kia,
    'audi': SimpleIcons.audi,
    'أودي': SimpleIcons.audi,
    'ford': SimpleIcons.ford,
    'فورد': SimpleIcons.ford,
    'chevrolet': SimpleIcons.chevrolet,
    'شيفروليه': SimpleIcons.chevrolet,
    'mazda': SimpleIcons.mazda,
    'مازدا': SimpleIcons.mazda,
    'honda': SimpleIcons.honda,
    'هوندا': SimpleIcons.honda,
    'nissan': SimpleIcons.nissan,
    'نيسان': SimpleIcons.nissan,
    'lexus': SimpleIcons.lexus,
    'لكزس': SimpleIcons.lexus,
    'volvo': SimpleIcons.volvo,
    'فولفو': SimpleIcons.volvo,
    'volkswagen': SimpleIcons.volkswagen,
    'فولكس فاجن': SimpleIcons.volkswagen,
    'porsche': SimpleIcons.porsche,
    'بورشه': SimpleIcons.porsche,
    'jaguar': SimpleIcons.jaguar,
    'جاكوار': SimpleIcons.jaguar,
    'land rover': SimpleIcons.landrover,
    'landrover': SimpleIcons.landrover,
    'لاند روفر': SimpleIcons.landrover,
    'jeep': SimpleIcons.jeep,
    'جيب': SimpleIcons.jeep,
    'tesla': SimpleIcons.tesla,
    'تسلا': SimpleIcons.tesla,
    'mitsubishi': SimpleIcons.mitsubishi,
    'ميتسوبيشي': SimpleIcons.mitsubishi,
    'suzuki': SimpleIcons.suzuki,
    'سوزوكي': SimpleIcons.suzuki,
    'subaru': SimpleIcons.subaru,
    'سوبارو': SimpleIcons.subaru,
    'isuzu': SimpleIcons.isuzu,
    'ايسوزو': SimpleIcons.isuzu,
    'renault': SimpleIcons.renault,
    'رينو': SimpleIcons.renault,
    'peugeot': SimpleIcons.peugeot,
    'بيجو': SimpleIcons.peugeot,
    'citroen': SimpleIcons.citroen,
    'سيتروين': SimpleIcons.citroen,
    'fiat': SimpleIcons.fiat,
    'فيات': SimpleIcons.fiat,
    'alfaromeo': SimpleIcons.alfaromeo,
    'alfa romeo': SimpleIcons.alfaromeo,
    'الفا روميو': SimpleIcons.alfaromeo,
    'astonmartin': SimpleIcons.astonmartin,
    'aston martin': SimpleIcons.astonmartin,
    'استون مارتن': SimpleIcons.astonmartin,
    'bentley': SimpleIcons.bentley,
    'بنتلي': SimpleIcons.bentley,
    'lamborghini': SimpleIcons.lamborghini,
    'لامبورغيني': SimpleIcons.lamborghini,
    'mclaren': SimpleIcons.mclaren,
    'ماكلارين': SimpleIcons.mclaren,
    'maserati': SimpleIcons.maserati,
    'مازيراتي': SimpleIcons.maserati,
    'cadillac': SimpleIcons.cadillac,
    'كاديلاك': SimpleIcons.cadillac,
    'chrysler': SimpleIcons.chrysler,
    'كرايسلر': SimpleIcons.chrysler,
    'dodge': SimpleIcons.dodge,
    'دودج': SimpleIcons.dodge,
    'ram': SimpleIcons.ram,
    'رام': SimpleIcons.ram,
    'acura': SimpleIcons.acura,
    'اكورا': SimpleIcons.acura,
    'infiniti': SimpleIcons.infiniti,
    'انفينيتي': SimpleIcons.infiniti,
    'genesis': SimpleIcons.genesis,
    'جينيسس': SimpleIcons.genesis,
    'chery': SimpleIcons.chery,
    'شيري': SimpleIcons.chery,
    'geely': SimpleIcons.geely,
    'جيلي': SimpleIcons.geely,
    'mg': SimpleIcons.mg,
    'إم جي': SimpleIcons.mg,
    'byd': SimpleIcons.byd,
    'بي واي دي': SimpleIcons.byd,
    'skoda': SimpleIcons.skoda,
    'سكودا': SimpleIcons.skoda,
    'seat': SimpleIcons.seat,
    'سيات': SimpleIcons.seat,
    'mini': SimpleIcons.mini,
    'ميني': SimpleIcons.mini,
    'lada': SimpleIcons.lada,
    'لادا': SimpleIcons.lada,
  };

  IconData? get _icon {
    final key = brand.trim().toLowerCase();
    return _logos[key];
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icon;
    final box = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * .22),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      alignment: Alignment.center,
      child: icon == null
          ? Text(
              brand.trim().isEmpty ? '?' : brand.trim().substring(0, 1).toUpperCase(),
              style: TextStyle(color: Colors.white70, fontSize: size * .34, fontWeight: FontWeight.w900),
            )
          : Icon(icon, size: size * .58, color: Colors.white),
    );

    if (!showName) return box;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        const SizedBox(height: 5),
        Text(
          brand,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
