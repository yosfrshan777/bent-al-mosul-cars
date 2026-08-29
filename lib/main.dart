import 'package:flutter/material.dart';
import 'screens/add_car_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/zyocar_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/showrooms_screen.dart';
import 'screens/parts_screen.dart';
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZYOCAR',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kPink, brightness: Brightness.dark),
      ),
      home: SplashScreen(api: api),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.api});
  final ApiService api;
  @override State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthGate(api: widget.api)));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: const [
          Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 5)),
          SizedBox(height: 12),
          Text('بيع وشراء السيارات وقطع الغيار', style: TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.api});
  final ApiService api;
  @override State<AuthGate> createState() => _AuthGateState();
}
class _AuthGateState extends State<AuthGate> {
  bool checking = true;
  bool loggedIn = false;
  @override void initState() { super.initState(); check(); }
  Future<void> check() async {
    var valid = widget.api.isLoggedIn;
    if (valid) { try { await widget.api.me(); } catch (_) { valid = false; } }
    if (mounted) setState(() { loggedIn = valid; checking = false; });
  }
  Future<void> login() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen(api: widget.api)));
    if (result != null && mounted) setState(() => loggedIn = true);
  }
  @override Widget build(BuildContext context) {
    if (checking) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPink)));
    if (loggedIn) return MainShell(api: widget.api);
    return LoginRequiredScreen(onLogin: login);
  }
}

class LoginRequiredScreen extends StatelessWidget {
  const LoginRequiredScreen({super.key, required this.onLogin});
  final VoidCallback onLogin;
  @override
  Widget build(BuildContext context) {
    return Directionality(
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
                    style: ElevatedButton.styleFrom(backgroundColor: kPink, foregroundColor: Colors.white),
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
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api});
  final ApiService api;
  @override State<MainShell> createState() => _MainShellState();
}
class _MainShellState extends State<MainShell> {
  int index = 0;
  void addCar() => Navigator.push(context, MaterialPageRoute(builder: (_) => AddCarScreen(api: widget.api)));
  void showrooms() => Navigator.push(context, MaterialPageRoute(builder: (_) => ShowroomsScreen(api: widget.api)));
  void parts() => Navigator.push(context, MaterialPageRoute(builder: (_) => PartsScreen(api: widget.api)));
  @override Widget build(BuildContext context) {
    final pages = <Widget>[
      ZyoCarHomeScreen(api: widget.api, onOpenCars: () => setState(() => index = 1), onOpenShowrooms: showrooms, onOpenParts: parts, onAddCar: addCar),
      CarsScreen(api: widget.api),
      const Center(child: Text('ريلز', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
      const Center(child: Text('المفضلة', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900))),
      ProfileScreen(api: widget.api),
    ];
    return Scaffold(
      body: IndexedStack(index: index, children: pages),
      floatingActionButton: FloatingActionButton(onPressed: addCar, backgroundColor: kPink, child: const Icon(Icons.add_rounded)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        backgroundColor: const Color(0xFF0D1018),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.search_outlined), label: 'السيارات'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), label: 'ريلز'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'المفضلة'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'حسابي'),
        ],
      ),
    );
  }
}
