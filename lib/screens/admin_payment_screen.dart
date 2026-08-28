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
  final _formKey = GlobalKey<FormState>();

  final _phoneController =
      TextEditingController();

  final _cardController =
      TextEditingController();

  final _nameController =
      TextEditingController();

  String _method = 'card';

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _loading = true;
    });

    try {
      final data =
          await widget.api.getPaymentSettings();

      if (!mounted) return;

      if (data is Map) {
        _phoneController.text =
            data['phone']?.toString() ?? '';

        _cardController.text =
            data['card_number']?.toString() ?? '';

        _nameController.text =
            data['account_name']?.toString() ?? '';

        final method =
            data['method']?.toString();

        if (method != null &&
            [
              'card',
              'qi',
              'bank',
              'cash',
            ].contains(method)) {
          _method = method;
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _saving = true;
    });

    try {
      await widget.api.updatePaymentSettings(
        phone: _phoneController.text.trim(),
        cardNumber:
            _cardController.text.trim(),
        accountName:
            _nameController.text.trim(),
        method: _method,
      );

      if (!mounted) return;

      _message(
        'تم حفظ بيانات الاستلام',
      );
    } on ApiException catch (e) {
      _message(e.message);
    } catch (_) {
      _message(
        'تعذر حفظ البيانات',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
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
          width: 1.5,
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
            'بيانات الاستلام',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(
                  color: Color(0xFFFF176F),
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(17),
                      decoration:
                          BoxDecoration(
                        gradient:
                            const LinearGradient(
                          colors: [
                            Color(0xFF321222),
                            Color(0xFF15151B),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                        border: Border.all(
                          color: const Color(
                            0xFF3A2631,
                          ),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons
                                .account_balance_wallet_rounded,
                            color: Color(
                              0xFFFF176F,
                            ),
                            size: 35,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'من هنا تغيّر بيانات الحساب الذي يستلم الدفعات من المستخدمين.',
                              style: TextStyle(
                                color:
                                    Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    DropdownButtonFormField<
                        String>(
                      value: _method,
                      dropdownColor:
                          const Color(
                        0xFF15151B,
                      ),
                      decoration:
                          _decoration(
                        label:
                            'طريقة الاستلام',
                        icon: Icons
                            .payments_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'card',
                          child: Text(
                            'بطاقة',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'qi',
                          child: Text(
                            'Qi Card',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'bank',
                          child: Text(
                            'تحويل مصرفي',
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'cash',
                          child: Text(
                            'نقدي',
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setState(() {
                          _method = value;
                        });
                      },
                    ),

                    const SizedBox(height: 13),

                    TextFormField(
                      controller:
                          _nameController,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _decoration(
                        label:
                            'اسم صاحب الحساب',
                        icon:
                            Icons.person_rounded,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'أدخل اسم صاحب الحساب';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 13),

                    TextFormField(
                      controller:
                          _phoneController,
                      keyboardType:
                          TextInputType.phone,
                      textDirection:
                          TextDirection.ltr,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _decoration(
                        label:
                            'رقم الهاتف',
                        icon:
                            Icons.phone_rounded,
                      ),
                    ),

                    const SizedBox(height: 13),

                    TextFormField(
                      controller:
                          _cardController,
                      keyboardType:
                          TextInputType.number,
                      textDirection:
                          TextDirection.ltr,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _decoration(
                        label:
                            'رقم البطاقة / الحساب',
                        icon:
                            Icons.credit_card_rounded,
                      ),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed:
                            _saving
                                ? null
                                : _save,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFFF176F,
                          ),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              15,
                            ),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  color:
                                      Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ البيانات',
                                style:
                                    TextStyle(
                                  fontSize: 18,
                                  fontWeight:
                                      FontWeight
                                          .w900,
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
    _nameController.dispose();

    super.dispose();
  }
}
