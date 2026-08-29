import 'package:flutter/material.dart';

import 'screens/add_car_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'services/api_service.dart';

const Color kPink = Color(0xFFFF176F);
const Color kBlue = Color(0xFF1597FF);
const Color kBg = Color(0xFF07090F);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ZyoCarApp());
}

class ZyoCarApp extends StatefulWidget {
  const ZyoCarApp({super.key});
  @override
  State<ZyoCarApp> createState() => _ZyoCarAppState();
}

class _ZyoCarAppState extends State<ZyoCarApp> {
  late final ApiService api;

  @override
  void initState() {
    super.initState();
    api = ApiService();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => MainShell(api: widget.api)));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-.65, -.35),
                radius: 1.15,
                colors: [kPink.withOpacity(.34), Colors.black, Colors.black],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(.65, .35),
                radius: 1.0,
                colors: [kBlue.withOpacity(.28), Colors.transparent, Colors.transparent],
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                final v = _animation.value;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('ZYOCAR', style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 5)),
                    const SizedBox(height: 10),
                    const Text('بيع وشراء السيارات وقطع الغيار', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 55),
                    SizedBox(
                      height: 150,
                      width: 330,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 20 + (1 - v) * 120,
                            bottom: 20,
                            child: _SplashCar(color: kPink, letter: 'Z'),
                          ),
                          Positioned(
                            right: 20 + (1 - v) * 120,
                            bottom: 20,
                            child: _SplashCar(color: kBlue, letter: 'Y'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Opacity(
                      opacity: v.clamp(0.0, 1.0),
                      child: const Text('اكتشف سيارتك القادمة', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashCar extends StatelessWidget {
  const _SplashCar({required this.color, required this.letter});
  final Color color;
  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      height: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(.95), color.withOpacity(.25)]),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(.85), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(.35), blurRadius: 28)],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 48),
          Positioned(top: 8, right: 10, child: Text(letter, style: TextStyle(color: color, fontSize: 23, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.api});
  final ApiService api;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _addCar() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddCarScreen(api: widget.api)));
  }

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
      floatingActionButton: FloatingActionButton(
        onPressed: _addCar,
        backgroundColor: kPink,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded, size: 31),
      ),
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
