import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      // ربط تسجيل الدخول بالسيرفر
      await widget.api.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل الدخول بنجاح',
            textDirection: TextDirection.rtl,
          ),
        ),
      );

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message,
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'حدث خطأ أثناء تسجيل الدخول',
            textDirection: TextDirection.rtl,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF9296A3),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF4F91),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE8E9EF),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFE8E9EF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(17),
        borderSide: const BorderSide(
          color: Color(0xFFFF4F91),
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
        backgroundColor: const Color(0xFFF7F8FC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF7F8FC),
          foregroundColor: const Color(0xFF20232F),
          elevation: 0,
          title: const Text(
            'تسجيل الدخول',
            style: TextStyle(
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 25),

                  Container(
                    width: 82,
                    height: 82,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Color(0xFFFF4F91),
                          Color(0xFF7B61FF),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFFF4F91,
                          ).withOpacity(.22),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      color: Colors.white,
                      size: 43,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'ZYO Car',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'سجّل دخولك واستمتع بتجربة السيارات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF858995),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Color(0xFF20232F),
                    ),
                    decoration: _decoration(
                      label: 'رقم الهاتف',
                      icon: Icons.phone_outlined,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل رقم الهاتف';
                      }

                      if (value.trim().length < 7) {
                        return 'رقم الهاتف غير صحيح';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Color(0xFF20232F),
                    ),
                    decoration: _decoration(
                      label: 'كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                                  .visibility_outlined
                              : Icons
                                  .visibility_off_outlined,
                          color: const Color(
                            0xFF969AA6,
                          ),
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'أدخل كلمة المرور';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: Color(0xFFFF4F91),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _login,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFF4F91),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(17),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 25,
                              height: 25,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'دخول',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE1E3E9),
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'أو',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Color(0xFFE1E3E9),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  OutlinedButton(
                    onPressed: () {},
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFF20232F),
                      minimumSize:
                          const Size.fromHeight(54),
                      side: const BorderSide(
                        color: Color(0xFFE1E3E9),
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(17),
                      ),
                    ),
                    child: const Text(
                      'إنشاء حساب جديد',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    'بتسجيل الدخول أنت توافق على شروط استخدام ZYO Car',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9A9DA8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
