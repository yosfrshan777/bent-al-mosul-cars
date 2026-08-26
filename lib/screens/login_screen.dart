import 'package:flutter/material.dart';

import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.api,
    this.onLoginSuccess,
    this.onRegister,
  });

  final ApiService api;
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onRegister;

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _loginController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool loading = false;
  bool obscurePassword = true;
  String? error;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await widget.api.login(
        login: _loginController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم تسجيل الدخول بنجاح',
          ),
          backgroundColor:
              Color(0xFF18A558),
        ),
      );

      widget.onLoginSuccess?.call();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = _cleanError(e);
      });
    }
  }

  String _cleanError(Object error) {
    final text = error.toString();

    if (text.contains('401')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    if (text.contains('SocketException')) {
      return 'تعذر الاتصال بالخادم';
    }

    return text
        .replaceFirst('Exception: ', '')
        .trim()
        .isEmpty
        ? 'حدث خطأ أثناء تسجيل الدخول'
        : text.replaceFirst(
            'Exception: ',
            '',
          );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
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
      suffixIcon: suffix,
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
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.redAccent,
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
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF176F),
            Color(0xFFE0005C),
          ],
        ),
        borderRadius:
            BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF176F)
                .withOpacity(.25),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.directions_car_filled_rounded,
        color: Colors.white,
        size: 44,
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        _logo(),
        const SizedBox(height: 20),
        const Text(
          'بنت الموصل',
          style: TextStyle(
            color: Colors.white,
            fontSize: 29,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'للسيارات',
          style: TextStyle(
            color: Color(0xFFFF176F),
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 9),
        const Text(
          'سجّل دخولك حتى تكمل استخدام التطبيق',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _loginForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تسجيل الدخول',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _loginController,
              keyboardType:
                  TextInputType.emailAddress,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                hint:
                    'البريد الإلكتروني أو رقم الهاتف',
                icon: Icons.person_outline_rounded,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'أدخل البريد أو رقم الهاتف';
                }

                return null;
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _passwordController,
              obscureText: obscurePassword,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                color: Colors.white,
              ),
              decoration: _inputDecoration(
                hint: 'كلمة المرور',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: () {
                    setState(() {
                      obscurePassword =
                          !obscurePassword;
                    });
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_outlined
                        : Icons
                            .visibility_off_outlined,
                    color: Colors.white54,
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

            if (error != null) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF35171E),
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Colors.redAccent
                            .withOpacity(.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.redAccent,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 18),

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed:
                    loading ? null : _login,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFFFF176F),
                  foregroundColor:
                      Colors.white,
                  disabledBackgroundColor:
                      const Color(0xFF7D1744),
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'دخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _registerButton() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Text(
          'ما عندك حساب؟',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
        TextButton(
          onPressed: widget.onRegister,
          child: const Text(
            'إنشاء حساب',
            style: TextStyle(
              color: Color(0xFFFF176F),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
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
            10,
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
                _header(),
                const SizedBox(height: 30),
                _loginForm(),
                const SizedBox(height: 10),
                _registerButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
