import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const BentAlMosulApp());
}

/* ============================================================
   APP
============================================================ */

class BentAlMosulApp extends StatelessWidget {
  const BentAlMosulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'بنت الموصل للسيارات',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF176F),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF111116),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF292932),
            ),
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
              width: 1.5,
            ),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

/* ============================================================
   CONFIG
============================================================ */

class AppConfig {
  // Android emulator:
  // http://10.0.2.2:3000
  //
  // Web / real phone:
  // ضع رابط Render هنا عند النشر.

  static const String apiBase = '';

  static String api(String path) {
    return '$apiBase$path';
  }
}

/* ============================================================
   API
============================================================ */

class ApiService {
  static Future<Map<String, dynamic>> get(
    String path, {
    String? token,
  }) async {
    final response = await http.get(
      Uri.parse(AppConfig.api(path)),
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
    );

    return _decode(response);
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(AppConfig.api(path)),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty)
          'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    return _decode(response);
  }

  static Map<String, dynamic> _decode(
    http.Response response,
  ) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = {};
    }

    if (data is Map<String, dynamic>) {
      if (response.statusCode < 200 ||
          response.statusCode >= 300) {
        throw Exception(
          data['error']?.toString() ??
              'حدث خطأ في الاتصال بالسيرفر',
        );
      }

      return data;
    }

    throw Exception('استجابة غير صحيحة من السيرفر');
  }
}

/* ============================================================
   STORAGE
============================================================ */

class LocalStore {
  static const String tokenKey = 'token';

  static Future<String?> token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}

/* ============================================================
   SPLASH
============================================================ */

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF08080B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFFF176F),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF176F)
                        .withOpacity(.35),
                    blurRadius: 35,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                size: 62,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'بنت الموصل',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFF176F),
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'للسيارات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFFFF176F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   MAIN SCREEN
============================================================ */

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int index = 0;

  final List<Widget> pages = const [
    HomePage(),
    CarsPage(),
    AddCarPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF111116),
        indicatorColor: const Color(0xFFFF176F),
        selectedIndex: index,
        onDestinationSelected: (value) {
          setState(() {
            index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'السيارات',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'أضف سيارة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   TOP BAR
============================================================ */

class AppTopBar extends StatelessWidget {
  final String title;

  const AppTopBar({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        10,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF176F),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ============================================================
   HOME
============================================================ */

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List cars = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCars();
  }

  Future<void> loadCars() async {
    try {
      final data = await ApiService.get('/api/cars');

      if (!mounted) return;

      setState(() {
        cars = data['cars'] is List
            ? data['cars']
            : [];
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: loadCars,
        color: const Color(0xFFFF176F),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 25),
          children: [
            const AppTopBar(
              title: 'بنت الموصل للسيارات',
            ),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color(0xFF28111C),
                      Color(0xFF111116),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFFFF176F)
                        .withOpacity(.35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'سيارتك القادمة\nتبدأ من هنا',
                      style: TextStyle(
                        fontSize: 31,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'بيع وشراء السيارات في العراق بطريقة أسهل وأسرع.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CarsPage(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.search,
                            ),
                            label: const Text(
                              'تصفح السيارات',
                            ),
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(
                                0xFFFF176F,
                              ),
                              foregroundColor:
                                  Colors.white,
                              minimumSize:
                                  const Size(
                                0,
                                52,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SectionTitle(
              title: 'سيارات مميزة',
              icon: Icons.star_rounded,
            ),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(35),
                child: Center(
                  child:
                      CircularProgressIndicator(
                    color: Color(0xFFFF176F),
                  ),
                ),
              )
            else if (cars.isEmpty)
              const EmptyState(
                text:
                    'لا توجد سيارات منشورة حالياً',
              )
            else
              SizedBox(
                height: 330,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 18,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      cars.length > 6
                          ? 6
                          : cars.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(width: 14),
                  itemBuilder: (_, i) {
                    return SizedBox(
                      width: 285,
                      child: CarCard(
                        car: cars[i],
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 25),

            const SectionTitle(
              title: 'لماذا بنت الموصل؟',
              icon: Icons.verified_rounded,
            ),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: FeatureCard(
                      icon: Icons.search_rounded,
                      title: 'بحث سريع',
                      text:
                          'ابحث عن السيارة المناسبة بسهولة.',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: FeatureCard(
                      icon:
                          Icons.verified_user_rounded,
                      title: 'مراجعة',
                      text:
                          'الإعلانات تمر بالمراجعة قبل النشر.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ============================================================
   CARS
============================================================ */

class CarsPage extends StatefulWidget {
  const CarsPage({super.key});

  @override
  State<CarsPage> createState() => _CarsPageState();
}

class _CarsPageState extends State<CarsPage> {
  final TextEditingController search =
     
