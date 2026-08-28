import 'package:flutter/material.dart';

import '../services/api_service.dart';

class AdminPaymentScreen extends StatefulWidget {
  const AdminPaymentScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<AdminPaymentScreen> createState() =>
      _AdminPaymentScreenState();
}

class _AdminPaymentScreenState
    extends State<AdminPaymentScreen> {
  final _phoneController = TextEditingController();
  final _cardController = TextEditingController();
  final _accountController = TextEditingController();

  String _method = 'phone';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
    });

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

        final method =
            data['method']?.toString();

        if (method == 'phone' ||
            method == 'card') {
          _method = method!;
        }
      }
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'تعذر تحميل بيانات الاستلام',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _save() async {
    final phone =
        _phoneController.text.trim();

    final card =
        _cardController.text.trim();

    final account =
        _accountController.text.trim();

    if (_method == 'phone' && phone.isEmpty) {
      _message('أدخل رقم الهاتف');
      return;
    }

    if (_method == 'card' && card.isEmpty) {
      _message('أدخل رقم البطاقة');
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await widget.api.updatePaymentSettings(
        phone: phone,
        cardNumber: card,
        accountName: account,
        method: _method,
      );

      if (!mounted) return;

      _message(
        'تم حفظ بيانات الاستلام بنجاح',
      );
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'حدث خطأ أثناء حفظ البيانات',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _message(String message) {
    if (!mounted) return;

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

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
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
            BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFFF176F),
        ),
      ),
    );
  }

  Widget _methodCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _method == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _method = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF2A1420)
              : const Color(0xFF15151B),
          borderRadius:
              BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? const Color(0xFFFF176F)
                : const Color(0xFF292932),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF176F)
                    : const Color(0xFF222229),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.white,
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
                      fontWeight: FontWeight.w900,
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
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFFFF176F)
                  : Colors.white30,
            ),
          ],
        ),
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
            'طريقة الاستلام',
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
              const Text(
                'بيانات التحويل',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'المالك أو الأدمن المخول يقدر يغير وسيلة استلام المبالغ من هنا.',
                style: TextStyle(
                  color: Colors.white54,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 20),

              _methodCard(
                value: 'phone',
                title: 'تحويل إلى رقم الهاتف',
                subtitle:
                    'المستخدم يحول الرصيد إلى رقم الهاتف المحدد',
                icon: Icons.phone_rounded,
              ),

              const SizedBox(height: 10),

              _methodCard(
                value: 'card',
                title: 'تحويل إلى رقم البطاقة',
                subtitle:
                    'المستخدم يحول المبلغ إلى البطاقة المحددة',
                icon: Icons.credit_card_rounded,
              ),

              const SizedBox(height: 22),

              TextField(
                controller: _phoneController,
                keyboardType:
                    TextInputType.phone,
                textDirection:
                    TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: _decoration(
                  label:
                      'رقم الهاتف للتحويل',
                  icon: Icons.phone_rounded,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: _cardController,
                keyboardType:
                    TextInputType.number,
                textDirection:
                    TextDirection.ltr,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: _decoration(
                  label: 'رقم البطاقة',
                  icon:
                      Icons.credit_card_rounded,
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller:
                    _accountController,
                textDirection:
                    TextDirection.rtl,
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: _decoration(
                  label: 'اسم صاحب الحساب',
                  icon:
                      Icons.person_rounded,
                ),
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF15151B),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color:
                          Color(0xFFFF176F),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'غيّر البيانات من هنا فقط. التطبيق يستخدم البيانات المحفوظة من السيرفر عند عرض تعليمات الدفع.',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: ElevatedButton.icon(
                  onPressed:
                      _loading ? null : _save,
                  icon: const Icon(
                    Icons.save_rounded,
                  ),
                  label: Text(
                    _loading
                        ? 'جاري الحفظ...'
                        : 'حفظ التغييرات',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFFFF176F),
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
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
    super.dispose();
  }
}
