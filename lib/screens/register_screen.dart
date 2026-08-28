import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  InputDecoration _decoration({
    required String label,
    required IconData icon,
    Widget? suffix,
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
      suffixIcon: suffix,
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

  Future<void> _register() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      await widget.api.register(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء الحساب بنجاح',
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
            'حدث خطأ أثناء إنشاء الحساب',
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
                  const SizedBox(height: 20),

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
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'انضم إلى ZYO Car',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF20232F),
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'أنشئ حسابك وابدأ البيع والشراء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF858995),
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _nameController,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      color: Color(0xFF20232F),
                    ),
                    decoration: _decoration(
                      label: 'الاسم الكامل',
                      icon: Icons.person_outline_rounded,
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
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                                !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF969AA6),
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

                  const SizedBox(height: 14),

                  TextFormField(
                    controller:
                        _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      color: Color(0xFF20232F),
                    ),
                    decoration: _decoration(
                      label: 'تأكيد كلمة المرور',
                      icon: Icons.lock_reset_rounded,
                      suffix: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirm =
                                !_obscureConfirm;
                          });
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF969AA6),
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
                    height: 56,
                    child: ElevatedButton(
                      onPressed:
                          _loading ? null : _register,
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
                              'إنشاء الحساب',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'بعد إنشاء الحساب يمكنك بيع سيارتك، شراء السيارات، والدخول إلى قسم قطع الغيار.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF979BA6),
                      fontSize: 11,
                      height: 1.6,
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
