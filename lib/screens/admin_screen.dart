import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AdminScreen> createState() =>
      _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedSection = 0;

  final List<_AdminSection> _sections = const [
    _AdminSection(
      title: 'المعارض',
      icon: Icons.store_rounded,
    ),
    _AdminSection(
      title: 'قطع الغيار',
      icon: Icons.build_rounded,
    ),
    _AdminSection(
      title: 'البيع والشراء',
      icon: Icons.swap_horiz_rounded,
    ),
  ];

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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFF2A1420),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFFFF176F),
              size: 32,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'لوحة الإدارة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'إدارة الطلبات والإعلانات',
                  style: TextStyle(
                    color: Colors.white54,
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

  Widget _buildSections() {
    return Column(
      children: List.generate(
        _sections.length,
        (index) {
          final section = _sections[index];
          final selected =
              _selectedSection == index;

          return Padding(
            padding:
                const EdgeInsets.only(bottom: 10),
            child: Material(
              color: selected
                  ? const Color(0xFF2A1420)
                  : const Color(0xFF15151B),
              borderRadius:
                  BorderRadius.circular(17),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(17),
                onTap: () {
                  setState(() {
                    _selectedSection = index;
                  });
                },
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(
                                  0xFFFF176F,
                                )
                              : const Color(
                                  0xFF222229,
                                ),
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        child: Icon(
                          section.icon,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Text(
                          section.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_left_rounded,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequests() {
    final section = _sections[_selectedSection];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                section.icon,
                color: const Color(0xFFFF176F),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'طلبات ${section.title}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A1420),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: const Text(
                  '0',
                  style: TextStyle(
                    color: Color(0xFFFF176F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Icon(
            Icons.inbox_rounded,
            color: Colors.white24,
            size: 52,
          ),
          const SizedBox(height: 10),
          const Text(
            'لا توجد طلبات حالياً',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            Icons.directions_car_rounded,
            'السيارات',
            '0',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.people_alt_rounded,
            'المستخدمون',
            '0',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            Icons.pending_actions_rounded,
            'طلبات',
            '0',
          ),
        ),
      ],
    );
  }

  Widget _statCard(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
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
            size: 24,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Text(
          'إدارة النظام',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        _adminAction(
          icon: Icons.account_balance_rounded,
          title: 'طريقة الاستلام والتحويل',
          subtitle:
              'تغيير رقم الهاتف أو رقم البطاقة',
          onTap: () {
            _showMessage(
              'إعدادات التحويل ستكون من هنا',
            );
          },
        ),
        const SizedBox(height: 10),
        _adminAction(
          icon: Icons.manage_accounts_rounded,
          title: 'الأدمنية والمالك',
          subtitle:
              'إدارة صلاحيات المشرفين والمالك',
          onTap: () {
            _showMessage(
              'إدارة الأدمنية والمالك',
            );
          },
        ),
      ],
    );
  }

  Widget _adminAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF15151B),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF222229),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFFF176F),
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white38,
              ),
            ],
          ),
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
            'الإدارة',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildQuickStats(),
              const SizedBox(height: 25),
              const Text(
                'الأقسام',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _buildSections(),
              const SizedBox(height: 12),
              _buildRequests(),
              const SizedBox(height: 25),
              _buildAdminActions(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSection {
  final String title;
  final IconData icon;

  const _AdminSection({
    required this.title,
    required this.icon,
  });
}
