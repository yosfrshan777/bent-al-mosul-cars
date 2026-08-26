import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({
    super.key,
    required this.api,
    this.onRegisterSuccess,
    this.onLogin,
  });

  final ApiService api;
  final VoidCallback? onRegisterSuccess;
  final VoidCallback? onLogin;

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  String? error;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await widget.api.register(
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إنشاء الحساب بنجاح',
          ),
          backgroundColor:
              Color(0xFF18A558),
        ),
      );

      widget.onRegisterSuccess?.call();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });
    }
  }

  InputDecoration _decoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.white38,
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF176F),
      ),
      filled: true,
      fillColor: const Color(0xFF0D0D11),
      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF292932),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFFF176F),
          width: 1.4,
        ),
      ),
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 16,
      ),
    );
  }

  Widget _logo() {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF176F),
            Color(0xFFE0005C),
          ],
        ),
        borderRadius:
            BorderRadius.circular(23),
      ),
      child: const Icon(
        Icons.person_add_alt_1_rounded,
        color: Colors.white,
        size: 38,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF08080B),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            5,
            18,
            35,
          ),
          child: ConstrainedBox(
            constraints:
                const BoxConstraints(
              maxWidth: 520,
            ),
            child: Column(
              children: [
                _logo(),
                const SizedBox(height: 18),
                const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'أنشئ حسابك وابدأ بيع وشراء السيارات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF15151B),
                    borderRadius:
                        BorderRadius.circular(22),
                    border: Border.all(
                      color:
                          const Color(0xFF292932),
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller:
                              nameController,
                          textDirection:
                              TextDirection.rtl,
                          style:
                              const TextStyle(
                            color: Colors.white,
                          ),
                          decoration:
                              _decoration(
                            hint: 'الاسم الكامل',
                            icon: Icons
                                .person_outline_rounded,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return 'أدخل اسمك';
                            }

                            if (value
                                    .trim()
                                    .length <
                                2) {
                              return 'الاسم قصير جداً';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                              phoneController,
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
                            hint:
                                'رقم الهاتف - 07xxxxxxxxx',
                            icon: Icons
                                .phone_outlined,
                          ),
                          validator: (value) {
                            final phone =
                                value?.trim() ??
                                    '';

                            if (phone.isEmpty) {
                              return 'أدخل رقم الهاتف';
                            }

                            if (!RegExp(
                              r'^07\d{9}$',
                            ).hasMatch(phone)) {
                              return 'الرقم يجب أن يبدأ بـ 07 ويتكون من 11 رقم';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                              emailController,
                          keyboardType:
                              TextInputType.emailAddress,
                          textDirection:
                              TextDirection.ltr,
                          style:
                              const TextStyle(
                            color: Colors.white,
                          ),
                          decoration:
                              _decoration(
                            hint:
                                'البريد الإلكتروني',
                            icon: Icons
                                .email_outlined,
                          ),
                          validator: (value) {
                            final email =
                                value?.trim() ??
                                    '';

                            if (email.isEmpty) {
                              return 'أدخل البريد الإلكتروني';
                            }

                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(email)) {
                              return 'البريد الإلكتروني غير صحيح';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller:
                              passwordController,
                          obscureText:
                              obscurePassword,
                          textDirection:
                              TextDirection.ltr,
                          style:
                              const TextStyle(
                            color: Colors.white,
                          ),
                          decoration:
                              _decoration(
                            hint: 'كلمة المرور',
                            icon: Icons
                                .lock_outline_rounded,
                          ).copyWith(
                            suffixIcon:
                                IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color:
                                    Colors.white54,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'أدخل كلمة المرور';
                            }

                            if (value.length <
                                6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }

                            return null;
                          },
                        ),

                        if (error != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width:
                                double.infinity,
                            padding:
                                const EdgeInsets.all(
                              12,
                            ),
                            decoration:
                                BoxDecoration(
                              color:
                                  const Color(
                                0xFF35171E,
                              ),
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                12,
                              ),
                            ),
                            child: Text(
                              error!,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 18),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 54,
                          child:
                              ElevatedButton(
                            onPressed:
                                loading
                                    ? null
                                    : _register,
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
                                  14,
                                ),
                              ),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors
                                          .white,
                                      strokeWidth:
                                          2.5,
                                    ),
                                  )
                                : const Text(
                                    'إنشاء الحساب',
                                    style:
                                        TextStyle(
                                      fontSize:
                                          16,
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
                const SizedBox(height: 10),
                TextButton(
                  onPressed: widget.onLogin,
                  child: const Text(
                    'عندي حساب — تسجيل الدخول',
                    style: TextStyle(
                      color:
                          Color(0xFFFF176F),
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
