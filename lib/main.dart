import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/add_car_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BentAlMosulApp());
}

class BentAlMosulApp extends StatelessWidget {
  const BentAlMosulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بنت الموصل للسيارات',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080B),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF176F),
          brightness: Brightness.dark,
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111116),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF15151B),
          labelStyle: const TextStyle(
            color: Colors.white70,
          ),
          hintStyle: const TextStyle(
            color: Colors.white38,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFFFF176F),
              width: 2,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF176F),
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              52,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),

      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late final ApiService api;

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    api = ApiService();
  }

  void _openAddCar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddCarScreen(
          api: api,
        ),
      ),
    );
  }

  void _openLogin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'صفحة تسجيل الدخول موجودة ضمن الحساب',
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  void _openAdmin() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'لوحة الإدارة',
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        api: api,
      ),

      CarsScreen(
        api: api,
        onCarTap: (car) {
          // يمكن فتح تفاصيل السيارة هنا لاحقاً
        },
      ),

      const SizedBox.shrink(),

      ProfileScreen(
        api: api,
        onLogin: _openLogin,
        onAddCar: _openAddCar,
        onAdmin: _openAdmin,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111116),
        indicatorColor: const Color(0xFF321222),

        selectedIndex: currentIndex,

        onDestinationSelected: (index) {
          if (index == 2) {
            _openAddCar();
            return;
          }

          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: Color(0xFFFF176F),
            ),
            label: 'الرئيسية',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.directions_car_outlined,
            ),
            selectedIcon: Icon(
              Icons.directions_car_rounded,
              color: Color(0xFFFF176F),
            ),
            label: 'السيارات',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.add_circle_outline_rounded,
              size: 30,
            ),
            selectedIcon: Icon(
              Icons.add_circle_rounded,
              color: Color(0xFFFF176F),
              size: 30,
            ),
            label: 'بيع سيارتك',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: Color(0xFFFF176F),
            ),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}
