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
  bool _loggedIn = false;
  bool _loading = false;

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
                child: _buildHeader(),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  35,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (!_loggedIn) ...[
                      _buildLoginCard(),
                      const SizedBox(height: 18),
                    ],

                    _buildSectionTitle('الخدمات'),

                    const SizedBox(height: 10),

                    _menuTile(
                      icon: Icons.directions_car_filled_rounded,
                      title: 'إعلاناتي',
                      subtitle: 'السيارات التي قمت بإضافتها',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.favorite_rounded,
                      title: 'المفضلة',
                      subtitle: 'السيارات التي حفظتها',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.storefront_rounded,
                      title: 'المعارض',
                      subtitle: 'تصفح معارض السيارات',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.build_circle_rounded,
                      title: 'قطع الغيار',
                      subtitle: 'شراء وبيع قطع غيار السيارات',
                      onTap: () {},
                    ),

                    const SizedBox(height: 18),

                    _buildSectionTitle('الحساب'),

                    const SizedBox(height: 10),

                    _menuTile(
                      icon: Icons.person_outline_rounded,
                      title: 'البيانات الشخصية',
                      subtitle: 'إدارة معلومات حسابك',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.notifications_none_rounded,
                      title: 'الإشعارات',
                      subtitle: 'إدارة التنبيهات',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.settings_outlined,
                      title: 'الإعدادات',
                      subtitle: 'إعدادات التطبيق',
                      onTap: () {},
                    ),

                    _menuTile(
                      icon: Icons.help_outline_rounded,
                      title: 'المساعدة والدعم',
                      subtitle: 'تواصل معنا',
                      onTap: () {},
                    ),

                    const SizedBox(height: 20),

                    if (_loggedIn)
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed:
                              _loading ? null : _logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                          ),
                          label: const Text(
                            'تسجيل الخروج',
                          ),
                          style:
                              OutlinedButton.styleFrom(
                            foregroundColor:
                                const Color(0xFFE83B63),
                            side: const BorderSide(
                              color: Color(0xFFE83B63),
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1D1F2C),
            Color(0xFF111219),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFFFF4F91),
                  Color(0xFF7B61FF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(
                    0xFFFF4F91,
                  ).withOpacity(.25),
                  blurRadius: 15,
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
                  _loggedIn
                      ? 'مرحباً بك'
                      : 'أهلاً بك في ZYO Car',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  _loggedIn
                      ? 'إدارة حسابك وإعلاناتك'
                      : 'سجّل دخولك للاستفادة من جميع المميزات',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.08),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white54,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE9EAF0),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF5),
              borderRadius:
                  BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.login_rounded,
              color: Color(0xFFFF4F91),
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'سجّل دخولك',
                  style: TextStyle(
                    color: Color(0xFF20232F),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'حتى تتمكن من إضافة وإدارة إعلاناتك',
                  style: TextStyle(
                    color: Color(0xFF8B8F9B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: _login,
            child: const Text(
              'دخول',
              style: TextStyle(
                color: Color(0xFFFF4F91),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF20232F),
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(17),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEFF5),
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF4F91),
                    size: 21,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF292C38),
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF979BA6),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14,
                  color: Color(0xFFB5B8C2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _loggedIn = true;
    });
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 300),
    );

    if (!mounted) return;

    setState(() {
      _loading = false;
      _loggedIn = false;
    });
  }
}
