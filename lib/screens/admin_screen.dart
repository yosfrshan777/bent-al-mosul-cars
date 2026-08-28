import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'admin_payment_screen.dart';
import 'admin_requests_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool _loading = true;

  int _cars = 0;
  int _users = 0;
  int _requests = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await widget.api.getAdminData();

      if (!mounted) return;

      if (data is Map) {
        setState(() {
          _cars = _toInt(
            data['cars_count'] ??
                data['cars'] ??
                0,
          );

          _users = _toInt(
            data['users_count'] ??
                data['users'] ??
                0,
          );

          _requests = _toInt(
            data['requests_count'] ??
                data['pending_requests'] ??
                0,
          );
        });
      }
    } catch (_) {
      if (mounted) {
        _message(
          'تعذر تحميل بيانات الإدارة',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
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

  void _openPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPaymentScreen(
          api: widget.api,
        ),
      ),
    );
  }

  void _openRequests() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminRequestsScreen(
          api: widget.api,
        ),
      ),
    );
  }

  Widget _stat(
    IconData icon,
    String title,
    int value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: const Color(0xFF292932),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF176F),
              size: 25,
            ),
            const SizedBox(height: 7),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 4,
        ),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: const Color(0xFF28141F),
            borderRadius: BorderRadius.circular(13),
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
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF08080B),
        appBar: AppBar(
          title: const Text(
            'لوحة الإدارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed:
                  _loading ? null : _loadDashboard,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFFF176F),
            onRefresh: _loadDashboard,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFF321222),
                        Color(0xFF15151B),
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(21),
                    border: Border.all(
                      color: const Color(0xFF3A2631),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .admin_panel_settings_rounded,
                        color: Color(0xFFFF176F),
                        size: 42,
                      ),
                      SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إدارة ZYOCAR',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'إدارة الإعلانات والطلبات وطرق الاستلام',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    _stat(
                      Icons.directions_car_rounded,
                      'السيارات',
                      _cars,
                    ),
                    const SizedBox(width: 8),
                    _stat(
                      Icons.people_rounded,
                      'المستخدمون',
                      _users,
                    ),
                    const SizedBox(width: 8),
                    _stat(
                      Icons.pending_actions_rounded,
                      'الطلبات',
                      _requests,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                const Text(
                  'الإدارة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 12),

                _menuCard(
                  icon: Icons.payments_rounded,
                  title: 'طريقة الاستلام والتحويل',
                  subtitle:
                      'تغيير رقم الهاتف أو رقم البطاقة',
                  onTap: _openPayment,
                ),

                _menuCard(
                  icon: Icons.fact_check_rounded,
                  title: 'طلبات الموافقة',
                  subtitle:
                      'المعارض وقطع الغيار والإعلانات',
                  onTap: _openRequests,
                ),

                _menuCard(
                  icon:
                      Icons.directions_car_rounded,
                  title: 'إدارة السيارات',
                  subtitle:
                      'مراجعة وإدارة إعلانات السيارات',
                  onTap: () {
                    _message(
                      'إدارة السيارات مرتبطة بالسيرفر',
                    );
                  },
                ),

                _menuCard(
                  icon: Icons.people_rounded,
                  title: 'المستخدمون',
                  subtitle:
                      'إدارة حسابات المستخدمين',
                  onTap: () {
                    _message(
                      'إدارة المستخدمين مرتبطة بالسيرفر',
                    );
                  },
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151B),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF292932),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: Color(0xFFFF176F),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'لوحة الإدارة مخصصة للمالك والأدمن المخول فقط. تغيير بيانات التحويل يجب أن يتم من خلال صلاحية الإدارة.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
