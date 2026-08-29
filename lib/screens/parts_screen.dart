import 'package:flutter/material.dart';
import '../services/api_service.dart';

const _pink = Color(0xFFFF176F);
const _bg = Color(0xFF060810);
const _surface = Color(0xFF0E1522);

class PartsScreen extends StatefulWidget {
  const PartsScreen({super.key, required this.api});
  final ApiService api;
  @override State<PartsScreen> createState() => _PartsScreenState();
}

class _PartsScreenState extends State<PartsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> items = [];

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.getParts();
      final raw = data is List ? data : (data is Map && data['parts'] is List ? data['parts'] : const []);
      if (!mounted) return;
      setState(() {
        items = raw.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        loading = false;
      });
    } on ApiException catch (e) {
      if (mounted) setState(() { loading = false; error = e.message; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر الاتصال بالسيرفر'; });
    }
  }

  @override Widget build(BuildContext context) {
    Widget body;
    if (loading) {
      body = ListView(children: const [SizedBox(height: 220), Center(child: CircularProgressIndicator(color: _pink))]);
    } else if (error != null) {
      body = ListView(children: [const SizedBox(height: 160), Center(child: Text('تعذر الاتصال بالسيرفر', style: TextStyle(color: Colors.white70))), Center(child: TextButton(onPressed: _load, child: Text(error!)))]);
    } else if (items.isEmpty) {
      body = ListView(children: const [SizedBox(height: 160), Center(child: Text('لا توجد محلات قطع غيار معتمدة حالياً', style: TextStyle(color: Colors.white54)))]);
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(15), itemCount: items.length,
        itemBuilder: (_, i) {
          final x = items[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _pink.withOpacity(.25))),
            child: ListTile(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PartStoreDetailsScreen(api: widget.api, id: int.tryParse('${x['id']}') ?? 0))),
              leading: const Icon(Icons.handyman_rounded, color: _pink, size: 32),
              title: Text('${x['name'] ?? 'محل قطع غيار'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              subtitle: Text('📍 ${x['city'] ?? ''}\n☎ ${x['phone'] ?? ''}', style: const TextStyle(color: Colors.white54, height: 1.5)),
              trailing: const Icon(Icons.chevron_left_rounded, color: Colors.white38),
            ),
          );
        },
      );
    }
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(backgroundColor: _bg, appBar: AppBar(title: const Text('قطع الغيار', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: _bg), body: RefreshIndicator(color: _pink, onRefresh: _load, child: body)));
  }
}

class PartStoreDetailsScreen extends StatefulWidget {
  const PartStoreDetailsScreen({super.key, required this.api, required this.id});
  final ApiService api; final int id;
  @override State<PartStoreDetailsScreen> createState() => _PartStoreDetailsScreenState();
}

class _PartStoreDetailsScreenState extends State<PartStoreDetailsScreen> {
  Map<String, dynamic>? store; bool loading = true;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final d = await widget.api.getPartStore(widget.id);
      if (!mounted) return;
      setState(() { store = d is Map ? Map<String, dynamic>.from(d) : null; loading = false; });
    } catch (_) { if (mounted) setState(() => loading = false); }
  }
  @override Widget build(BuildContext context) {
    final name = store?['name']?.toString() ?? 'محل قطع غيار';
    final city = store?['city']?.toString() ?? '';
    final phone = store?['phone']?.toString() ?? '';
    return Directionality(textDirection: TextDirection.rtl, child: Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(title: const Text('محل قطع الغيار', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: _bg),
      body: loading ? const Center(child: CircularProgressIndicator(color: _pink)) : ListView(padding: const EdgeInsets.all(15), children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: _pink.withOpacity(.35))), child: Column(children: [
          const Icon(Icons.handyman_rounded, color: _pink, size: 50), const SizedBox(height: 10),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8), Text('📍 $city', style: const TextStyle(color: Colors.white60)), Text('☎ $phone', style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 18), const Text('المنتجات والأسعار والتوصيل تظهر من بيانات السيرفر.', style: TextStyle(color: Colors.white54)),
        ])),
      ]),
    ));
  }
}
