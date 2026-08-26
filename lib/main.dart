import 'package:flutter/material.dart';

void main() {
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
        fontFamily: 'Arial',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF08080B),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF176F),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeTab(),
    CarsTab(),
    AddCarTab(),
    ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: pages[currentIndex],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF111116),
          indicatorColor: const Color(0x33FF176F),
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
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF111116),
          title: const Text(
            'بنت الموصل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF176F),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Color(0xFFFF176F),
                        Color(0xFF8E1749),
                      ],
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سيارتك القادمة تبدأ من هنا',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'بيع وشراء السيارات في العراق بسهولة',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'تصفح حسب الفئة',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  height: 105,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      CategoryCard(
                        icon: Icons.directions_car,
                        title: 'سيارات',
                      ),
                      CategoryCard(
                        icon: Icons.local_offer,
                        title: 'عروض',
                      ),
                      CategoryCard(
                        icon: Icons.build,
                        title: 'قطع غيار',
                      ),
                      CategoryCard(
                        icon: Icons.store,
                        title: 'معارض',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'أحدث السيارات',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                const CarCard(
                  brand: 'Toyota',
                  model: 'Camry',
                  year: '2022',
                  price: '28,000,000',
                ),

                const CarCard(
                  brand: 'BMW',
                  model: '520i',
                  year: '2021',
                  price: '45,000,000',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 34,
            color: const Color(0xFFFF176F),
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    );
  }
}

class CarsTab extends StatelessWidget {
  const CarsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: Color(0xFF111116),
          title: Text('السيارات'),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث عن سيارة أو ماركة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF15151B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              const [
                CarCard(
                  brand: 'Toyota',
                  model: 'Land Cruiser',
                  year: '2023',
                  price: '72,000,000',
                ),
                CarCard(
                  brand: 'Mercedes',
                  model: 'C200',
                  year: '2022',
                  price: '55,000,000',
                ),
                CarCard(
                  brand: 'Lexus',
                  model: 'ES350',
                  year: '2021',
                  price: '48,000,000',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CarCard extends StatelessWidget {
  final String brand;
  final String model;
  final String year;
  final String price;

  const CarCard({
    super.key,
    required this.brand,
    required this.model,
    required this.year,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF15151B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF292932),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 190,
            width: double.infinity,
            color: const Color(0xFF202027),
            child: const Icon(
              Icons.directions_car,
              size: 90,
              color: Color(0xFFFF176F),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand $model',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '$year • العراق',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  '$price د.ع',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF176F),
                  ),
                ),

                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('عرض التفاصيل'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddCarTab extends StatelessWidget {
  const AddCarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: Color(0xFF111116),
          title: Text('إضافة سيارة'),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(
                  Icons.add_a_photo,
                  size: 70,
                  color: Color(0xFFFF176F),
                ),

                const SizedBox(height: 20),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'ماركة السيارة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  decoration: InputDecoration(
                    labelText: 'الموديل',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر بالدينار العراقي',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.photo_library),
                    label: const Text('اختيار صور السيارة'),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {},
                    child: const Text('نشر السيارة'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          pinned: true,
          backgroundColor: Color(0xFF111116),
          title: Text('حسابي'),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF176F),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  'أهلاً بك',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 25),

                ProfileButton(
                  icon: Icons.login,
                  title: 'تسجيل الدخول',
                  onTap: () {},
                ),

                ProfileButton(
                  icon: Icons.person_add,
                  title: 'إنشاء حساب',
                  onTap: () {},
                ),

                ProfileButton(
                  icon: Icons.directions_car,
                  title: 'سياراتي',
                  onTap: () {},
                ),

                ProfileButton(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ProfileButton({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: const Color(0xFF15151B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        leading: Icon(
          icon,
          color: const Color(0xFFFF176F),
        ),
        title: Text(title),
        trailing: const Icon(
          Icons.chevron_left,
        ),
      ),
    );
  }
}
