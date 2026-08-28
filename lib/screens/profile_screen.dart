import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  bool _loggedIn = false;

  String _name = 'زائر';
  String _phone = '';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await widget.api.me();

      if (!mounted) return;

      if (data is Map) {
        final user = data['user'] is Map
            ? Map<String, dynamic>.from(data['user'])
            : Map<String, dynamic>.from(data);

        setState(() {
          _loggedIn = true;
          _name =
              user['name']?.toString() ?? 'مستخدم';
          _phone =
              user['phone']?.toString() ?? '';
          _role =
              user['role']?.toString() ?? 'user';
        });
      }
    } on ApiException {
      if (mounted) {
        setState(() {
          _loggedIn = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loggedIn = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _login() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          api: widget.api,
        ),
      ),
    );

    if (result != null) {
      await _loadProfile();
    }
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });

    try {
      await widget.api.logout();
    } catch (_) {
      widget.api.clearToken();
    }

    if (!mounted) return;

    setState(() {
      _loggedIn = false;
      _name = 'زائر';
      _phone = '';
      _role = 'user';
      _loading = false;
    });
  }

  String get _roleName {
    switch (_role) {
      case 'owner':
        return 'المالك';

      case 'admin':
        return 'أدمن';

      case 'showroom':
        return 'صاحب معرض';

      case 'parts':
        return 'قطع غيار';

      case 'seller':
        return 'بائع';

      default:
        return 'مستخدم';
    }
  }

  void _message(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  Widget _profileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF321222),
            Color(0xFF17171D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF3A2631),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFFF176F),
              borderRadius:
                  BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 35,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                if (_phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _phone,
                    style: const TextStyle(
                      color: Colors.white60,
                    ),
                  ),
                ],
                const SizedBox(height: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF28141F),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    _roleName,
                    style: const TextStyle(
                      color:
                          Color(0xFFFF4F91),
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFF24141C),
            borderRadius:
                BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color:
                iconColor ??
                const Color(0xFFFF176F),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
              ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white30,
        ),
      ),
    );
  }

  Widget _guest() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Icon(
          Icons.person_outline_rounded,
          color: Colors.white24,
          size: 80,
        ),
        const SizedBox(height: 15),
        const Text(
          'أنت غير مسجل دخول',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'سجل دخولك حتى تقدر تنشر وتدير إعلاناتك.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 53,
          child: ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF176F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'تسجيل الدخول',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
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
            'حسابي',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed:
                  _loading ? null : _loadProfile,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: _loading
              ? const Center(
                  child:
                      CircularProgressIndicator(
                    color:
                        Color(0xFFFF176F),
                  ),
                )
              : ListView(
                  padding:
                      const EdgeInsets.all(16),
                  children: [
                    if (!_loggedIn)
                      _guest()
                    else ...[
                      _profileHeader(),

                      const SizedBox(height: 22),

                      const Text(
                        'حسابك',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 12),

                      _menuItem(
                        icon:
                            Icons.directions_car_rounded,
                        title: 'إعلاناتي',
                        subtitle:
                            'السيارات التي نشرتها',
                        onTap: () {
                          _message(
                            'سيتم عرض إعلاناتك هنا',
                          );
                        },
                      ),

                      _menuItem(
                        icon:
                            Icons.favorite_rounded,
                        title: 'المفضلة',
                        subtitle:
                            'السيارات المحفوظة',
                        onTap: () {
                          _message(
                            'قسم المفضلة',
                          );
                        },
                      ),

                      _menuItem(
                        icon:
                            Icons.receipt_long_rounded,
                        title: 'المدفوعات',
                        subtitle:
                            'عمليات الدفع والاشتراكات',
                        onTap: () {
                          _message(
                            'قسم المدفوعات',
                          );
                        },
                      ),

                      if (_role == 'owner' ||
                          _role == 'admin') ...[
                        const SizedBox(height: 12),
                        const Text(
                          'الإدارة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight:
                                FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _menuItem(
                          icon:
                              Icons.admin_panel_settings_rounded,
                          title: 'لوحة الإدارة',
                          subtitle:
                              'إدارة المستخدمين والإعلانات والطلبات',
                          onTap: () {
                            _message(
                              'افتح لوحة الإدارة من قسم الإدارة',
                            );
                          },
                        ),
                      ],

                      const SizedBox(height: 12),

                      _menuItem(
                        icon:
                            Icons.logout_rounded,
                        title:
                            'تسجيل الخروج',
                        iconColor:
                            Colors.redAccent,
                        onTap: _logout,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
