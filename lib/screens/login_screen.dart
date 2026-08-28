import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'register_screen.dart';

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
      // سيتم ربط تسجيل الدخول مع endpoint السيرفر
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      _showMessage(
        'تم تجهيز تسجيل الدخول، وسيتم ربطه بالسيرفر الحقيقي.',
      );
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'حدث خطأ أثناء تسجيل الدخول',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

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

  InputDecoration _decoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF4F91),
      ),
      filled: true,
      fillColor: const Color(0xFF15151B),
      labelStyle: const TextStyle(
        color: Colors.white60,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFFF4F91),
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
                      color: const Color(0xFFFF176F),
                      borderRadius:
                          BorderRadius.circular(25),
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: Colors.white,
                      size: 45,
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'مرحباً بك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'سجل دخولك إلى بنت الموصل للسيارات',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _decoration(
                      label: 'رقم الهاتف',
                      icon: Icons.phone_rounded,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل رقم الهاتف';
                      }

                      if (value.trim().length < 8) {
                        return 'رقم الهاتف غير صحيح';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller:
                        _passwordController,
                    obscureText: _obscurePassword,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration:
                        _decoration(
                      label: 'كلمة المرور',
                      icon: Icons.lock_rounded,
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
                              ? Icons.visibility_rounded
                              : Icons
                                  .visibility_off_rounded,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'أدخل كلمة المرور';
                      }

                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 10),

                  Align(
                    alignment:
                        Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        _showMessage(
                          'استرجاع كلمة المرور سيتم ربطه لاحقاً',
                        );
                      },
                      child: const Text(
                        'نسيت كلمة المرور؟',
                        style: TextStyle(
                          color: Color(0xFFFF4F91),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _login,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFFF176F),
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'دخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ما عندك حساب؟',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(
                                api: widget.api,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color:
                                Color(0xFFFF4F91),
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
