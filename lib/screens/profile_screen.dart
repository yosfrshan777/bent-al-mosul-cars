import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _header(),
              ),
              SliverToBoxAdapter(
                child: _profileCard(),
              ),
              SliverToBoxAdapter(
                child: _menu(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        14,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'حسابي',
              style: TextStyle(
                color: Color(0xFF171923),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF343744),
            ),
          ),
        ],
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFFFF6FA8),
            Color(0xFF718DFF),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4F91)
                .withOpacity(.18),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 67,
            height: 67,
            decoration: BoxDecoration(
              color: Colors.white
                  .withOpacity(.22),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white
                    .withOpacity(.45),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 36,
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'حساب ZYOCAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'بيع • شراء • متابعة إعلاناتك',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menu() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        22,
        16,
        30,
      ),
      child: Column(
        children: [
          _sectionTitle('حسابك'),
          const SizedBox(height: 10),

          _item(
            icon: Icons.person_outline_rounded,
            title: 'الملف الشخصي',
            subtitle: 'معلوماتك الشخصية',
            onTap: () {},
          ),

          _item(
            icon: Icons.directions_car_outlined,
            title: 'إعلاناتي',
            subtitle: 'السيارات التي نشرتها',
            onTap: () {},
          ),

          _item(
            icon: Icons.favorite_border_rounded,
            title: 'المفضلة',
            subtitle: 'السيارات التي حفظتها',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          _sectionTitle('ZYOCAR'),
          const SizedBox(height: 10),

          _item(
            icon: Icons.storefront_outlined,
            title: 'المعارض',
            subtitle: 'استكشف معارض السيارات',
            onTap: () {},
          ),

          _item(
            icon: Icons.build_outlined,
            title: 'قطع الغيار',
            subtitle: 'أصحاب محلات قطع الغيار',
            onTap: () {},
          ),

          _item(
            icon: Icons.help_outline_rounded,
            title: 'المساعدة',
            subtitle: 'الأسئلة والدعم',
            onTap: () {},
          ),

          const SizedBox(height: 20),

          if (!loggedIn)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/login',
                  );
                },
                icon: const Icon(
                  Icons.login_rounded,
                ),
                label: const Text(
                  'تسجيل الدخول',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF4F91),
                  foregroundColor: Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF858997),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.045),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 5,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEFF5),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF4F91),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF252735),
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF9296A3),
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 15,
          color: Color(0xFFB1B4BE),
        ),
      ),
    );
  }
}
