import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_screen.dart';
import 'admin_screen.dart';

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

class _ProfileScreenState
    extends State<ProfileScreen> {
  bool _loading = true;

  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data =
          await widget.api.me();

      if (!mounted) return;

      if (data is Map &&
          data['user'] is Map) {
        setState(() {
          _user =
              Map<String, dynamic>.from(
            data['user'],
          );
        });
      }
    } catch (_) {
      // المستخدم غير مسجل دخول
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  bool get _isAdmin {
    final role =
        _user?['role']?.toString();

    return role == 'admin' ||
        role == 'owner';
  }

  Future<void> _login() async {
    final result =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          api: widget.api,
        ),
      ),
    );

    if (result != null) {
      await _loadUser();
    }
  }

  Future<void> _logout() async {
    try {
      await widget.api.logout();
    } catch (_) {
      widget.api.clearToken();
    }

    if (!mounted) return;

    setState(() {
      _user = null;
    });

    _message('تم تسجيل الخروج');
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
  }

  String _userName() {
    return _user?['name']
            ?.toString() ??
        'مستخدم ZYOCAR';
  }

  String _userPhone() {
    return _user?['phone']
            ?.toString() ??
        '';
  }

  String _roleName() {
    switch (_user?['role']?.toString()) {
      case 'owner':
        return 'مالك التطبيق';
      case 'admin':
        return 'مدير';
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

  Widget _menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color:
            const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFF292932),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 43,
          height: 43,
          decoration: BoxDecoration(
            color:
                const Color(0xFF28141F),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color:
                const Color(0xFFFF176F),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style:
                    const TextStyle(
                  color:
                      Colors.white38,
                  fontSize: 11,
                ),
              ),
        trailing: const Icon(
          Icons
              .chevron_left_rounded,
          color:
              Colors.white30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'حسابي',
            style: TextStyle(
              fontWeight:
                  FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      Color(0xFFFF176F),
                ),
              )
            : ListView(
                padding:
                    const EdgeInsets.all(
                  16,
                ),
                children: [
                  Container(
                    padding:
                        const EdgeInsets.all(
                      18,
                    ),
                    decoration:
                        BoxDecoration(
                      gradient:
                          const LinearGradient(
                        begin:
                            Alignment.topRight,
                        end: Alignment
                            .bottomLeft,
                        colors: [
                          Color(
                              0xFF321222),
                          Color(
                              0xFF15151B),
                        ],
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        21,
                      ),
                      border:
                          Border.all(
                        color:
                            const Color(
                          0xFF3A2631,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration:
                              BoxDecoration(
                            color:
                                const Color(
                              0xFFFF176F,
                            ),
                            shape:
                                BoxShape
                                    .circle,
                          ),
                          child:
                              const Icon(
                            Icons
                                .person_rounded,
                            color: Colors
                                .white,
                            size: 34,
                          ),
                        ),
                        const SizedBox(
                          width: 14,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                _userName(),
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white,
                                  fontSize:
                                      20,
                                  fontWeight:
                                      FontWeight
                                          .w900,
                                ),
                              ),
                              if (_userPhone()
                                  .isNotEmpty)
                                Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    top: 4,
                                  ),
                                  child:
                                      Text(
                                    _userPhone(),
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white54,
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                _roleName(),
                                style:
                                    const TextStyle(
                                  color:
                                      Color(
                                    0xFFFF4F91,
                                  ),
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  if (_user == null)
                    _menuItem(
                      icon: Icons
                          .login_rounded,
                      title:
                          'تسجيل الدخول',
                      subtitle:
                          'ادخل إلى حسابك',
                      onTap: _login,
                    ),

                  if (_user == null)
                    _menuItem(
                      icon: Icons
                          .person_add_rounded,
                      title:
                          'إنشاء حساب',
                      subtitle:
                          'أنشئ حساب ZYOCAR جديد',
                      onTap: _login,
                    ),

                  if (_user != null)
                    _menuItem(
                      icon: Icons
                          .directions_car_rounded,
                      title:
                          'إعلاناتي',
                      subtitle:
                          'السيارات التي أضفتها',
                      onTap: () {
                        _message(
                          'سنربط إعلاناتك بالسيرفر',
                        );
                      },
                    ),

                  if (_user != null)
                    _menuItem(
                      icon: Icons
                          .favorite_rounded,
                      title:
                          'المفضلة',
                      subtitle:
                          'السيارات المحفوظة',
                      onTap: () {
                        _message(
                          'المفضلة قيد الربط',
                        );
                      },
                    ),

                  if (_isAdmin)
                    _menuItem(
                      icon: Icons
                          .admin_panel_settings_rounded,
                      title:
                          'لوحة الإدارة',
                      subtitle:
                          'إدارة ZYOCAR',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AdminScreen(
                              api:
                                  widget.api,
                            ),
                          ),
                        );
                      },
                    ),

                  if (_user != null)
                    _menuItem(
                      icon: Icons
                          .logout_rounded,
                      title:
                          'تسجيل الخروج',
                      onTap: _logout,
                    ),

                  const SizedBox(
                    height: 25,
                  ),

                  const Center(
                    child: Text(
                      'ZYOCAR',
                      style: TextStyle(
                        color:
                            Colors.white24,
                        fontSize: 22,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
