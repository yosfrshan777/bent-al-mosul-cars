import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/add_car_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/admin_screen.dart';

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
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor:
            const Color(0xFF08080B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF176F),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111116),
          foregroundColor: Colors.white,
          elevation: 0,
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

class _MainNavigationState
    extends State<MainNavigation> {
  int currentIndex = 0;

  final ApiService api = ApiService.instance;

  void _openPage(int index) {
    if (index < 0 || index > 4) return;

    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        api: api,
        onOpenCars: () {
          _openPage(1);
        },
        onAddCar: () {
          _openPage(2);
        },
        onLogin: () {
          _openPage(3);
        },
      ),

      CarsScreen(
        api: api,
      ),

      AddCarScreen(
        api: api,
      ),

      ProfileScreen(
        api: api,
      ),

      AdminScreen(
        api: api,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),

        bottomNavigationBar:
            NavigationBar(
          selectedIndex:
              currentIndex > 3
                  ? 0
                  : currentIndex,

          onDestinationSelected: (index) {
            _openPage(index);
          },

          backgroundColor:
              const Color(0xFF111116),

          indicatorColor:
              const Color(0x33FF176F),

          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.home_outlined,
              ),
              selectedIcon: Icon(
                Icons.home_rounded,
              ),
              label: 'الرئيسية',
            ),

            NavigationDestination(
              icon: Icon(
                Icons
                    .directions_car_outlined,
              ),
              selectedIcon: Icon(
                Icons
                    .directions_car_rounded,
              ),
              label: 'السيارات',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.add_circle_outline,
              ),
              selectedIcon: Icon(
                Icons.add_circle_rounded,
              ),
              label: 'أضف سيارة',
            ),

            NavigationDestination(
              icon: Icon(
                Icons.person_outline,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
              ),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}
