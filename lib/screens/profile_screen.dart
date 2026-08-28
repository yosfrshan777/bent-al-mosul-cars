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
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF08080B),
          title: const Text(
            'حسابي',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 18),
              _buildSectionTitle('إدارة الحساب'),
              const SizedBox(height: 10),
              _menuItem(
                icon: Icons.person_outline_rounded,
                title: 'معلومات الحساب',
                subtitle: 'الاسم ورقم الهاتف',
                onTap: () {},
              ),
              _menuItem(
                icon: Icons.directions_car_outlined,
                title: 'إعلاناتي',
                subtitle: 'السيارات التي نشرتها',
                onTap: () {},
              ),
              _menuItem(
                icon: Icons.favorite_border_rounded,
                title: 'المفضلة',
                subtitle: 'السيارات المحفوظة',
                onTap: () {},
              ),
              const SizedBox(height: 20),
              _buildSectionTitle('ZYOCAR'),
              const SizedBox(height: 10),
              _menuItem(
                icon: Icons.storefront_outlined,
                title: 'المعارض',
                subtitle: 'تصفح معارض السيارات',
                onTap: () {},
              ),
              _menuItem(
                icon: Icons.build_circle_outlined,
                title: 'قطع الغيار',
                subtitle: 'محلات وبيع قطع الغيار',
                onTap: () {},
              ),
              _menuItem(
                icon: Icons.help_outline_rounded,
                title: 'المساعدة',
                subtitle: 'الدعم والأسئلة الشائعة',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF351326),
            Color(0xFF17171D),
            Color(0xFF101014),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF3A2631),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF176F),
                  Color(0xFF8B5CF6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF176F)
                      .withOpacity(.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  loggedIn
                      ? 'حسابي'
                      : 'مرحباً بك في ZYOCAR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  loggedIn
                      ? 'إدارة حسابك وإعلاناتك'
                      : 'سجّل الدخول لإدارة إعلاناتك',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292933),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 5,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFFF176F)
                .withOpacity(.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFF176F),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white45,
            fontSize: 11,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white30,
          size: 17,
        ),
      ),
    );
  }
}
