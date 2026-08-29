import 'package:flutter/material.dart';

import 'screens/add_car_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/api_service.dart';

const Color kPink = Color(0xFFFF176F);
const Color kBlue = Color(0xFF1597FF);
const Color kBg = Color(0xFF07090F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  await api.initAuth();
  runApp(ZyoCarApp(api: api));
}

class ZyoCarApp extends StatelessWidget {
  const ZyoCarApp({super.key, required this.api});
  final ApiService api;

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ZYOCAR',
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
          scaffoldBackgroundColor: kBg,
          colorScheme: ColorScheme.fromSeed(seedColor: kPink, brightness: Brightness.dark),
          appBarTheme: const AppBarTheme(backgroundColor: kBg, elevation: 0, centerTitle: true),
        ),
        home: SplashScreen(api: api),
      );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800))..forward();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    Future.delayed(const Duration(milliseconds: 4200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => AuthGate(api: widget.api)));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(-.65, -.35), radius: 1.15, colors: [kPink.withOpacity(.34), Colors.black, Colors.black]))),
            DecoratedBox(decoration: BoxDecoration(gradient: RadialGradient(center: const Alignment(.65, .35), radius: 1.0, colors: [kBlue.withOpacity(.28), Colors.transparent, Colors.transparent]))),
            Center(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (_, __) {
                  final v = _animation.value;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: .88 + (v.clamp(0.0, 1.0) * .12),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(colors: [kPink, Colors.white, kBlue]).createShader(bounds),
                          child: const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 5)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('بيع وشراء السيارات وقطع الغيار', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 38),
                      SizedBox(
                        height: 220,
                        width: 340,
                        child: AnimatedOpacity(
                          opacity: v.clamp(0.0, 1.0),
                          duration: const Duration(milliseconds: 250),
                          child: Image.asset('assets/icons/zyocar.png', fit: BoxFit.contain, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Opacity(opacity: v.clamp(0.0, 1.0), child: const Text('اكتشف سيارتك القادمة', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800))),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.api});
  final ApiService api;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _checking = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    var valid = widget.api.isLoggedIn;
    if (valid) {
      try {
        await widget.api.me();
      } catch (_) {
        valid = false;
      }
    }
    if (!mounted) return;
    setState(() {
      _loggedIn = valid;
      _checking = false;
    });
  }

  Future<void> _openLogin() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api)));
    if (result != null && mounted) setState(() => _loggedIn = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPink)));
    if (_loggedIn) return MainShell(api: widget.api);
    return LoginRequiredScreen(onLogin: _openLogin);
  }
}

class LoginRequiredScreen extends StatelessWidget {
  const LoginRequiredScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: kBg,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lock_person_rounded, color: kPink, size: 72),
                  const SizedBox(height: 18),
                  const Text('تسجيل الدخول مطلوب', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('سجّل دخولك حتى تدخل إلى ZYOCAR', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: onLogin,
                      style: ElevatedButton.styleFrom(backgroundColor: kPink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                      child: const Text('تسجيل الدخول', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api});
  final ApiService api;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _addCar() => Navigator.push(context, MaterialPageRoute(builder: (_) => AddCarScreen(api: widget.api)));

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(api: widget.api, onOpenCars: () => setState(() => _index = 1), onAddCar: _addCar),
      CarsScreen(api: widget.api),
      const Center(child: Text('ريلز', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))),
      const Center(child: Text('المفضلة', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w900))),
      ProfileScreen(api: widget.api),
    ];

    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _index, children: pages),
      floatingActionButton: FloatingActionButton(onPressed: _addCar, backgroundColor: kPink, foregroundColor: Colors.white, child: const Icon(Icons.add_rounded, size: 31)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        backgroundColor: const Color(0xFF0D1018),
        indicatorColor: const Color(0xFF3A1630),
        height: 78,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search_outlined), selectedIcon: Icon(Icons.search_rounded), label: 'السيارات'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline_rounded), selectedIcon: Icon(Icons.play_circle_fill_rounded), label: 'ريلز'),
          NavigationDestination(icon: Icon(Icons.favorite_border_rounded), selectedIcon: Icon(Icons.favorite_rounded), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person_outline_rounded), selectedIcon: Icon(Icons.person_rounded), label: 'حسابي'),
        ],
      ),
    );
  }
}
