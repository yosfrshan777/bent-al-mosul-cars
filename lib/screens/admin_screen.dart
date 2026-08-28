import 'package:flutter/material.dart';

import '../services/api_service.dart';

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
  int _section = 0;
  bool _loading = false;

  final _phoneController = TextEditingController();
  final _cardController = TextEditingController();
  final _accountController = TextEditingController();

  final _normalController =
      TextEditingController(text: '10000');
  final _featuredController =
      TextEditingController(text: '20000');
  final _vipController =
      TextEditingController(text: '30000');

  final List<_Section> _sections = const [
    _Section('المعارض', Icons.store_rounded),
    _Section('قطع الغيار', Icons.build_rounded),
    _Section('البيع والشراء', Icons.swap_horiz_rounded),
  ];

  Future<void> _loadPaymentSettings() async {
    setState(() => _loading = true);

    try {
      final data =
          await widget.api.getPaymentSettings();

      if (data is Map) {
        _phoneController.text =
            data['phone']?.toString() ?? '';
        _cardController.text =
            data['card_number']?.toString() ?? '';
        _accountController.text =
            data['account_name']?.toString() ?? '';
      }
    } catch (_) {
      _message('تعذر تحميل إعدادات التحويل');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _savePaymentSettings() async {
    setState(() => _loading = true);

    try {
      await widget.api.updatePaymentSettings(
        phone: _phoneController.text.trim(),
        cardNumber: _cardController.text.trim(),
        accountName:
            _accountController.text.trim(),
      );

      _message('تم حفظ طريقة الاستلام والتحويل');
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('حدث خطأ أثناء الحفظ');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _savePrices() async {
    final normal =
        int.tryParse(_normalController.text) ?? 0;
    final featured =
        int.tryParse(_featuredController.text) ?? 0;
    final vip =
        int.tryParse(_vipController.text) ?? 0;

    if (normal <= 0 ||
        featured <= 0 ||
        vip <= 0) {
      _message('أدخل أسعار صحيحة');
      return;
    }

    setState(() => _loading = true);

    try {
      await widget.api.updatePlanPrices(
        normal: normal,
        featured: featured,
        vip: vip,
      );

      _message('تم حفظ أسعار الإعلانات');
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message('حدث خطأ أثناء حفظ الأسعار');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            text,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
  }

  Widget _sectionButton(int index) {
    final selected = _section == index;
    final item = _sections[index];

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _section = index);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 3,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 13,
          ),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFFFF176F)
                : const Color(0xFF15151B),
            borderRadius:
                BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFF176F)
                  : const Color(0xFF292932),
            ),
          ),
          child: Column(
            children: [
              Icon(
                item.icon,
                color: Colors.white,
                size: 23,
              ),
              const SizedBox(height: 5),
              Text(
                item.title,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stat(
    IconData icon,
    String title,
    String value,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius:
              BorderRadius.circular(16),
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
                fontSize: 19,
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

  Widget _textField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color: const Color(0xFFFF176F),
          ),
          filled: true,
          fillColor: const Color(0xFF15151B),
          labelStyle: const TextStyle(
            color: Colors.white54,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
          ),
        ),
      ),
    );
  }

  Widget _paymentSettings() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Text(
          'طريقة الاستلام والتحويل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        const Text(
          'من هنا المالك يغير رقم الهاتف أو البطاقة التي يتم التحويل إليها.',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 16),

        _textField(
          _phoneController,
          'رقم الهاتف للتحويل',
          Icons.phone_rounded,
          keyboardType: TextInputType.phone,
        ),

        _textField(
          _cardController,
          'رقم البطاقة',
          Icons.credit_card_rounded,
          keyboardType: TextInputType.number,
        ),

        _textField(
          _accountController,
          'اسم صاحب الحساب',
          Icons.person_rounded,
        ),

        const SizedBox(height: 5),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed:
                _loading
                    ? null
                    : _savePaymentSettings,
            icon: const Icon(
              Icons.save_rounded,
            ),
            label: const Text(
              'حفظ بيانات التحويل',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF176F),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _prices() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.stretch,
      children: [
        const Text(
          'أسعار الإعلانات',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 15),

        _textField(
          _normalController,
          'الإعلان العادي',
          Icons.sell_outlined,
          keyboardType: TextInputType.number,
        ),

        _textField(
          _featuredController,
          'الإعلان المميز',
          Icons.star_rounded,
          keyboardType: TextInputType.number,
        ),

        _textField(
          _vipController,
          'إعلان VIP',
          Icons.workspace_premium_rounded,
          keyboardType: TextInputType.number,
        ),

        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed:
                _loading ? null : _savePrices,
            icon: const Icon(
              Icons.save_rounded,
            ),
            label: const Text(
              'حفظ الأسعار',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFFFF176F),
              foregroundColor: Colors.white,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _requests() {
    final section = _sections[_section];

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        children: [
          Icon(
            section.icon,
            color: const Color(0xFFFF176F),
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'طلبات ${section.title}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'الطلبات المعلقة تظهر هنا ليوافق عليها الأدمن أو المالك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          OutlinedButton.icon(
            onPressed: () {
              _message(
                'سيتم تحميل طلبات هذا القسم من السيرفر',
              );
            },
            icon: const Icon(
              Icons.refresh_rounded,
            ),
            label: const Text(
              'تحديث الطلبات',
            ),
          ),
        ],
      ),
    );
  }

  Widget _admins() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الأدمنية والمالك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'هذا القسم يظهر للمالك والأدمن المخول فقط.',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 15),
          ListTile(
            tileColor:
                const Color(0xFF202027),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(14),
            ),
            leading: const Icon(
              Icons.shield_rounded,
              color: Color(0xFFFF176F),
            ),
            title: const Text(
              'إدارة الصلاحيات',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_left_rounded,
              color: Colors.white38,
            ),
            onTap: () {
              _message(
                'إدارة الأدمنية والصلاحيات',
              );
            },
          ),
        ],
      ),
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
              Row(
                children: [
                  _stat(
                    Icons.directions_car_rounded,
                    'عدد السيارات',
                    '0',
                  ),
                  const SizedBox(width: 8),
                  _stat(
                    Icons.people_rounded,
                    'المستخدمون',
                    '0',
                  ),
                  const SizedBox(width: 8),
                  _stat(
                    Icons.pending_actions_rounded,
                    'الطلبات',
                    '0',
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'أقسام الموافقات',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: List.generate(
                  _sections.length,
                  _sectionButton,
                ),
              ),

              const SizedBox(height: 15),

              _requests(),

              const SizedBox(height: 22),

              _paymentSettings(),

              const SizedBox(height: 25),

              _prices(),

              const SizedBox(height: 25),

              _admins(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cardController.dispose();
    _accountController.dispose();
    _normalController.dispose();
    _featuredController.dispose();
    _vipController.dispose();
    super.dispose();
  }
}

class _Section {
  final String title;
  final IconData icon;

  const _Section(this.title, this.icon);
}
