import 'package:flutter/material.dart';

import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.api,
    this.onLogin,
    this.onAddCar,
    this.onAdmin,
  });

  final ApiService api;
  final VoidCallback? onLogin;
  final VoidCallback? onAddCar;
  final VoidCallback? onAdmin;

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool loading = true;
  bool loggedIn = false;
  bool isAdmin = false;

  String name = 'زائر';
  String email = '';
  String phone = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // =========================================================
  // LOAD PROFILE
  // =========================================================

  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final token = await widget.api.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          loading = false;
          loggedIn = false;
          isAdmin = false;
          name = 'زائر';
          email = '';
          phone = '';
        });

        return;
      }

      final profile = await widget.api.me();

      if (!mounted) return;

      setState(() {
        loggedIn = true;

        name =
            profile['name']?.toString() ??
            profile['user']?['name']?.toString() ??
            'المستخدم';

        email =
            profile['email']?.toString() ??
            profile['user']?['email']?.toString() ??
            '';

        phone =
            profile['phone']?.toString() ??
            profile['user']?['phone']?.toString() ??
            '';

        isAdmin =
            profile['isAdmin'] == true ||
            profile['is_admin'] == true ||
            profile['role']?.toString().toLowerCase() ==
                'admin' ||
            profile['user']?['isAdmin'] == true ||
            profile['user']?['role']
                    ?.toString()
                    .toLowerCase() ==
                'admin';

        loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      if (e.statusCode == 401) {
        await widget.api.clearToken();
      }

      setState(() {
        loading = false;
        loggedIn = false;
        isAdmin = false;
        name = 'زائر';
        email = '';
        phone = '';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
        loggedIn = false;
        isAdmin = false;
        name = 'زائر';
        email = '';
        phone = '';
      });
    }
  }

  // =========================================================
  // LOGOUT
  // =========================================================

  Future<void> _logout() async {
    await widget.api.logout();

    if (!mounted) return;

    setState(() {
      loggedIn = false;
      isAdmin = false;
      name = 'زائر';
      email = '';
      phone = '';
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'تم تسجيل الخروج',
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  // =========================================================
  // AVATAR
  // =========================================================

  Widget _avatar() {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF176F),
            Color(0xFFE0005C),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF176F)
                .withOpacity(.22),
            blurRadius: 25,
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        color: Colors.white,
        size: 48,
      ),
    );
  }

  // =========================================================
  // PROFILE HEADER
  // =========================================================

  Widget _profileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        children: [
          _avatar(),

          const SizedBox(height: 15),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (email.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              email,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],

          if (phone.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              phone,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
              ),
            ),
          ],

          if (isAdmin) ...[
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF321222),
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFF176F),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons
                        .admin_panel_settings_rounded,
                    color: Color(0xFFFF176F),
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'مدير النظام',
                    style: TextStyle(
                      color: Color(0xFFFF176F),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================
  // MENU ITEM
  // =========================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 3,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF21121A),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor ??
                const Color(0xFFFF176F),
          ),
        ),
        title: Text(
          title,
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                textDirection:
                    TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white38,
        ),
      ),
    );
  }

  // =========================================================
  // GUEST VIEW
  // =========================================================

  Widget _guestView() {
    return Column(
      children: [
        _avatar(),

        const SizedBox(height: 18),

        const Text(
          'أهلاً بك في بنت الموصل',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'سجّل الدخول حتى تتمكن من إضافة سياراتك وإدارة إعلاناتك.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 53,
          child: ElevatedButton(
            onPressed: widget.onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF176F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

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
          'حسابي',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),

        actions: [
          IconButton(
            onPressed: loading
                ? null
                : _loadProfile,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF176F),
              ),
            )
          : RefreshIndicator(
              color:
                  const Color(0xFFFF176F),

              onRefresh: _loadProfile,

              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),

                padding:
                    const EdgeInsets.all(15),

                children: [
                  // =================================================
                  // GUEST
                  // =================================================

                  if (!loggedIn)
                    Container(
                      padding:
                          const EdgeInsets.all(22),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(0xFF15151B),
                        borderRadius:
                            BorderRadius.circular(
                          24,
                        ),
                        border: Border.all(
                          color:
                              const Color(0xFF292932),
                        ),
                      ),
                      child: _guestView(),
                    )

                  // =================================================
                  // LOGGED USER
                  // =================================================

                  else ...[
                    _profileHeader(),

                    const SizedBox(height: 18),

                    const Text(
                      'الخدمات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 11),

                    // بيع سيارة
                    _menuItem(
                      icon: Icons
                          .add_circle_outline_rounded,
                      title: 'بيع سيارتك',
                      subtitle:
                          'إضافة إعلان سيارة جديد',
                      onTap: widget.onAddCar,
                    ),

                    // إعلاناتي
                    _menuItem(
                      icon: Icons
                          .directions_car_filled_outlined,
                      title: 'إعلاناتي',
                      subtitle:
                          'عرض وإدارة سياراتك',
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'قسم إعلاناتي قيد التجهيز',
                              textDirection:
                                  TextDirection.rtl,
                            ),
                          ),
                        );
                      },
                    ),

                    // المدفوعات
                    _menuItem(
                      icon: Icons
                          .receipt_long_outlined,
                      title: 'المدفوعات',
                      subtitle:
                          'متابعة طلبات الدفع والإيصالات',
                      onTap: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'قسم المدفوعات قيد التجهيز',
                              textDirection:
                                  TextDirection.rtl,
                            ),
                          ),
                        );
                      },
                    ),

                    // =================================================
                    // ADMIN
                    // =================================================

                    if (isAdmin) ...[
                      const SizedBox(height: 12),

                      const Text(
                        'الإدارة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 11),

                      _menuItem(
                        icon: Icons
                            .admin_panel_settings_rounded,
                        title: 'لوحة الإدارة',
                        subtitle:
                            'إدارة السيارات والمستخدمين والمدفوعات',
                        onTap: widget.onAdmin,
                      ),
                    ],

                    const SizedBox(height: 12),

                    // =================================================
                    // LOGOUT
                    // =================================================

                    _menuItem(
                      icon:
                          Icons.logout_rounded,
                      title:
                          'تسجيل الخروج',
                      subtitle:
                          'الخروج من الحساب الحالي',
                      iconColor:
                          Colors.redAccent,
                      onTap: _logout,
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'بنت الموصل للسيارات',
                        style: TextStyle(
                          color: Colors.white24,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
