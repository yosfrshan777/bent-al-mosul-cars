import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();
  final _phoneController =
      TextEditingController();
  final _passwordController =
      TextEditingController();
  final _confirmPasswordController =
      TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      _showMessage(
        'تم تجهيز إنشاء الحساب.',
      );

      Navigator.pop(context);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'حدث خطأ أثناء إنشاء الحساب',
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
            'إنشاء حساب',
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
                  const SizedBox(height: 15),

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF176F),
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        color: Colors.white,
                        size: 42,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'أنشئ حسابك',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'انضم إلى بنت الموصل للسيارات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  ),

                  const SizedBox(height: 28),

                  TextFormField(
                    controller: _nameController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _decoration(
                      label: 'الاسم الكامل',
                      icon: Icons.person_rounded,
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'أدخل الاسم';
                      }

                      if (value.trim().length < 3) {
                        return 'الاسم قصير جداً';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

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
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _decoration(
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
                        return '6 أحرف على الأقل';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller:
                        _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    decoration: _decoration(
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_outline_rounded,
                    ).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirm =
                                !_obscureConfirm;
                          });
                        },
                        icon: Icon(
                          _obscureConfirm
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
                        return 'أكد كلمة المرور';
                      }

                      if (value !=
                          _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتين';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _register,
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
                              'إنشاء الحساب',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'عندي حساب بالفعل',
                      style: TextStyle(
                        color: Color(0xFFFF4F91),
                        fontWeight: FontWeight.bold,
                      ),
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
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
