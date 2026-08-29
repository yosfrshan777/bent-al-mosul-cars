import 'package:flutter/material.dart';
import '../services/api_service.dart';

const _pink = Color(0xFFFF176F);
const _blue = Color(0xFF1597FF);
const _bg = Color(0xFF060810);
const _surface = Color(0xFF0E1522);

class ShowroomsScreen extends StatefulWidget {
  const ShowroomsScreen({super.key, required this.api});
  final ApiService api;

  @override
  State<ShowroomsScreen> createState() => _ShowroomsScreenState();
}

class _ShowroomsScreenState extends State<ShowroomsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        loading = true;
        error = null;
      });
    }
    try {
      final data = await widget.api.getShowrooms();
      final raw = data is List
          ? data
          : (data is Map && data['showrooms'] is List
              ? data['showrooms'] as List
              : <dynamic>[]);
      if (!mounted) return;
      setState(() {
        items = raw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'تعذر تحميل المعارض';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = const Center(
        child: CircularProgressIndicator(color: _pink),
      );
    } else if (error != null) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(error!, style: const TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: _load,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    } else if (items.isEmpty) {
      body = const Center(
        child: Text(
          'لا توجد معارض معتمدة حالياً',
          style: TextStyle(color: Colors.white54),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: items.length,
        itemBuilder: (_, index) => _card(items[index]),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: const Text(
            'المعارض',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: _bg,
        ),
        body: RefreshIndicator(
          color: _pink,
          onRefresh: _load,
          child: body,
        ),
      ),
    );
  }

  Widget _card(Map<String, dynamic> item) {
    final id = int.tryParse('${item['id']}') ?? 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _blue.withOpacity(.25)),
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShowroomDetailsScreen(api: widget.api, id: id),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        leading: const Icon(
          Icons.storefront_rounded,
          color: _pink,
          size: 32,
        ),
        title: Text(
          '${item['name'] ?? 'معرض'}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          '📍 ${item['city'] ?? ''}\n☎ ${item['phone'] ?? ''}',
          style: const TextStyle(color: Colors.white54, height: 1.5),
        ),
        trailing: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white38,
        ),
      ),
    );
  }
}

class ShowroomDetailsScreen extends StatefulWidget {
  const ShowroomDetailsScreen({
    super.key,
    required this.api,
    required this.id,
  });

  final ApiService api;
  final int id;

  @override
  State<ShowroomDetailsScreen> createState() => _ShowroomDetailsScreenState();
}

class _ShowroomDetailsScreenState extends State<ShowroomDetailsScreen> {
  Map<String, dynamic>? showroom;
  List<Map<String, dynamic>> cars = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await widget.api.getShowroom(widget.id);
      if (!mounted) return;
      final map = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};
      final rawCars = map['cars'];
      setState(() {
        showroom = map['showroom'] is Map
            ? Map<String, dynamic>.from(map['showroom'])
            : null;
        cars = rawCars is List
            ? rawCars
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : [];
        loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'تعذر تحميل بيانات المعرض';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _pink),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          title: const Text('صفحة المعرض'),
        ),
        body: Center(
          child: Text(
            error!,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    final name = showroom?['name']?.toString() ?? 'معرض';
    final city = showroom?['city']?.toString() ?? '';
    final phone = showroom?['phone']?.toString() ?? '';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          title: const Text(
            'صفحة المعرض',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          backgroundColor: _bg,
        ),
        body: ListView(
          padding: const EdgeInsets.all(15),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _pink.withOpacity(.4)),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.storefront_rounded,
                    color: _pink,
                    size: 48,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '📍 $city',
                    style: const TextStyle(color: Colors.white60),
                  ),
                  Text(
                    '☎ $phone',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'سيارات المعرض (${cars.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            ...cars.map(
              (car) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.directions_car_rounded,
                      color: _blue,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${car['brand'] ?? ''} ${car['model'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${car['year'] ?? ''} • ${car['city'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            '\$${car['price'] ?? 0}',
                            style: const TextStyle(
                              color: _pink,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
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
