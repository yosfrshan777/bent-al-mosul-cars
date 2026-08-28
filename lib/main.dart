import 'package:flutter/material.dart';

import 'services/api_service.dart';
import 'screens/add_car_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/profile_screen.dart';

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

    api = ApiService(
      baseUrl: 'https://bent-al-mosul-cars.onrender.com/api',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ZYOCAR',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF176F),
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF08080B),
          elevation: 0,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(api: api),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.api,
  });

  final ApiService api;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  late final List<Widget> _pages = [
    _HomePage(api: widget.api),
    CarsScreen(api: widget.api),
    const _ReelsPage(),
    const _FavoritesPage(),
    ProfileScreen(api: widget.api),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF176F),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCarScreen(
                api: widget.api,
              ),
            ),
          );
        },
        child: const Icon(
          Icons.add_rounded,
          size: 30,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        backgroundColor: const Color(0xFF111116),
        indicatorColor: const Color(0xFF3A1425),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search_rounded),
            label: 'بحث',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle_fill),
            label: 'Reels',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'مفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({
    required this.api,
  });

  final ApiService api;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF08080B),
              title: const Text(
                'ZYOCAR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 170,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFFFF176F),
                            Color(0xFF5B1838),
                            Color(0xFF17171D),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'سيارتك القادمة',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'اكتشف سيارات للبيع في العراق',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.store_rounded,
                            title: 'المعارض',
                            subtitle: 'معارض السيارات',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickCard(
                            icon: Icons.build_rounded,
                            title: 'قطع الغيار',
                            subtitle: 'قطع غيار السيارات',
                            onTap: () {},
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'أحدث السيارات',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 21,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'عرض الكل',
                            style: TextStyle(
                              color: Color(0xFFFF176F),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 330,
                      child: CarsScreen(api: api),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF15151B),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF292932),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFF176F),
              size: 34,
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReelsPage extends StatelessWidget {
  const _ReelsPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Reels',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _FavoritesPage extends StatelessWidget {
  const _FavoritesPage();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'المفضلة',
        style: TextStyle(
          color: Colors.white,
          fontSize: 25,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
