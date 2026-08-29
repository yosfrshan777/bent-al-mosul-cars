import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/api_service.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key, required this.api});
  final ApiService api;
  @override State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> reels = [];
  final Map<int, VideoPlayerController> controllers = {};

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; error = null; });
    try {
      final data = await widget.api.getReels();
      if (!mounted) return;
      reels = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      await _prepare(0);
      setState(() => loading = false);
    } on ApiException catch (e) {
      if (mounted) setState(() { loading = false; error = e.message; });
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'تعذر تحميل الريلز'; });
    }
  }

  Future<void> _prepare(int index) async {
    if (index < 0 || index >= reels.length || controllers.containsKey(index)) return;
    final raw = reels[index]['video_url']?.toString() ?? '';
    if (raw.isEmpty) return;
    final url = widget.api.imageUrl(raw);
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    controllers[index] = c;
    try {
      await c.initialize();
      if (mounted) setState(() {});
    } catch (_) {
      await c.dispose();
      controllers.remove(index);
    }
  }

  @override
  void dispose() {
    for (final c in controllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF05070D),
        appBar: AppBar(title: const Text('ريلز', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
        body: loading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFF176F)))
            : error != null
                ? _message(error!, true)
                : reels.isEmpty
                    ? _message('لا توجد فيديوهات سيارات حالياً', false)
                    : PageView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: reels.length,
                        onPageChanged: (i) { _prepare(i); _prepare(i + 1); },
                        itemBuilder: (_, i) => _reel(i),
                      ),
      ),
    );
  }

  Widget _message(String text, bool retry) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Text(text, style: const TextStyle(color: Colors.white60)), if (retry) TextButton(onPressed: load, child: const Text('إعادة المحاولة'))]));

  Widget _reel(int i) {
    final c = controllers[i];
    final r = reels[i];
    final title = '${r['brand'] ?? ''} ${r['model'] ?? ''}'.trim();
    final price = r['price']?.toString() ?? '';
    final city = r['city']?.toString() ?? '';
    return Stack(fit: StackFit.expand, children: [
      Container(color: Colors.black),
      if (c != null && c.value.isInitialized)
        GestureDetector(onTap: () => setState(() => c.value.isPlaying ? c.pause() : c.play()), child: Center(child: AspectRatio(aspectRatio: c.value.aspectRatio, child: VideoPlayer(c))))
      else
        const Center(child: CircularProgressIndicator(color: Color(0xFFFF176F))),
      Positioned.fill(child: IgnorePointer(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black26, Colors.transparent, Colors.black87]))))),
      Positioned(right: 18, left: 18, bottom: 28, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title.isNotEmpty) Text(title, style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w900)),
          if (city.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Text(city, style: const TextStyle(color: Colors.white70))),
          if (price.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text('\$$price', style: const TextStyle(color: Color(0xFFFF176F), fontSize: 22, fontWeight: FontWeight.w900))),
        ])),
        const Column(mainAxisSize: MainAxisSize.min, children: [
          _ReelAction(icon: Icons.favorite_border_rounded, label: 'إعجاب'),
          SizedBox(height: 18),
          _ReelAction(icon: Icons.comment_rounded, label: 'تعليق'),
          SizedBox(height: 18),
          _ReelAction(icon: Icons.share_rounded, label: 'مشاركة'),
        ]),
      ])),
    ]);
  }
}

class _ReelAction extends StatelessWidget {
  const _ReelAction({required this.icon, required this.label});
  final IconData icon;
  final String label;
  @override Widget build(BuildContext context) => Column(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(icon, color: Colors.white, size: 27)), const SizedBox(height: 3), Text(label, style: const TextStyle(color: Colors.white, fontSize: 9))]);
}
