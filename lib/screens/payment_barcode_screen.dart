import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class PaymentBarcodeScreen extends StatelessWidget {
  const PaymentBarcodeScreen({super.key, required this.api, this.amount});
  final ApiService api;
  final int? amount;

  // الباركود المعتمد من المستخدم — لا توجد بوابة دفع أخرى.
  static const String paymentQrData = '28101501202608286476647925';

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFF07090F),
      appBar: AppBar(
        title: const Text('باركود الدفع', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFF07090F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF101522),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFFF176F).withOpacity(.35)),
            ),
            child: Column(children: [
              const Text('ادفع باستخدام الباركود', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('هذا هو باركود الدفع المعتمد في ZYOCAR.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
                child: QrImageView(data: paymentQrData, size: 270, backgroundColor: Colors.white),
              ),
              const SizedBox(height: 18),
              if (amount != null)
                Text('المبلغ: $amount د.ع', style: const TextStyle(color: Color(0xFFFF176F), fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              const Text('زينب خالد', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('بعد التحويل، احتفظ بإيصال الدفع وأرسله حسب تعليمات الإدارة.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
          ),
        ],
      ),
    ),
  );
}
