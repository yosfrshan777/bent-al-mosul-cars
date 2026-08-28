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
  bool loading = false;

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color: danger
                ? const Color(0xFFFFEDEF)
                : const Color(0xFFFFEFF5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: danger
                ? Colors.red
                : const Color(0xFFFF4F91),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: danger
                ? Colors.red
                : const Color(0xFF20232F),
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: danger
              ? Colors.red
              : const Color(0xFF9DA1AC),
        ),
      ),
    );
  }

  Widget _loginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF18181E),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4F91),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'أهلاً بك في بنت الموصل',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'سجل الدخول حتى تقدر تضيف إعلاناتك وتدير حسابك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white60,
              height: 1.6,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                _showMessage(
                  'صفحة تسجيل الدخول قيد الربط',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFFF4F91),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'تسجيل الدخول',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          title: const Text(
            'حسابي',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          backgroundColor:
              const Color(0xFFF7F8FC),
          foregroundColor:
              const Color(0xFF20232F),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            35,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.stretch,
            children: [
              _loginCard(),

              const SizedBox(height: 25),

              const Text(
                'الحساب',
                style: TextStyle(
                  color: Color(0xFF20232F),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              _menuItem(
                icon: Icons.directions_car_rounded,
                title: 'إعلاناتي',
                onTap: () {
                  _showMessage(
                    'سيتم عرض إعلاناتك هنا',
                  );
                },
              ),

              _menuItem(
                icon: Icons.favorite_rounded,
                title: 'المفضلة',
                onTap: () {
                  _showMessage(
                    'قائمة المفضلة',
                  );
                },
              ),

              _menuItem(
                icon: Icons.notifications_rounded,
                title: 'الإشعارات',
                onTap: () {
                  _showMessage(
                    'الإشعارات',
                  );
                },
              ),

              const SizedBox(height: 15),

              const Text(
                'المساعدة',
                style: TextStyle(
                  color: Color(0xFF20232F),
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              _menuItem(
                icon: Icons.support_agent_rounded,
                title: 'الدعم والتواصل',
                onTap: () {
                  _showMessage(
                    'سيتم إضافة الدعم والتواصل',
                  );
                },
              ),

              _menuItem(
                icon: Icons.info_outline_rounded,
                title: 'عن بنت الموصل',
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName:
                        'بنت الموصل للسيارات',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(
                      Icons.directions_car_rounded,
                      color: Color(0xFFFF4F91),
                    ),
                    children: const [
                      Text(
                        'منصة عراقية لبيع وشراء السيارات وقطع الغيار.',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 15),

              _menuItem(
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                danger: true,
                onTap: () {
                  _showMessage(
                    'سيتم ربط تسجيل الخروج مع السيرفر',
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
