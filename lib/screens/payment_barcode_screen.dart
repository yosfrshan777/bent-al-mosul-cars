import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class PaymentBarcodeScreen extends StatelessWidget {
  const PaymentBarcodeScreen({super.key, required this.api, this.amount});
  final ApiService api;
  final int? amount;

  // Approved Qi payment QR from the provided payment card.
  static const String paymentQrData = '28101501202608286476647925';

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      backgroundColor: const Color(0xFFFFD400),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFD400),
        foregroundColor: const Color(0xFF171717),
        title: const Text('الدفع', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            const SizedBox(height: 8),
            const _QiMark(),
            const SizedBox(height: 14),
            const Text(
              'استخدم سوبر كي',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF111111), fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
                    child: QrImageView(
                      data: paymentQrData,
                      size: 285,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
                      dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('زينب خالد', style: TextStyle(color: Color(0xFF111111), fontSize: 24, fontWeight: FontWeight.w900)),
                  if (amount != null) ...[
                    const SizedBox(height: 8),
                    Text('المبلغ: $amount د.ع', style: const TextStyle(color: Color(0xFF111111), fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.black.withOpacity(.08), borderRadius: BorderRadius.circular(18)),
              child: const Text(
                'امسح الباركود من تطبيق سوبر كي لإتمام الدفع. لا توجد حاجة لإدخال رقم بطاقة أو رقم حساب داخل ZYOCAR.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF171717), fontSize: 13, fontWeight: FontWeight.w700, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _QiMark extends StatelessWidget {
  const _QiMark();

  @override
  Widget build(BuildContext context) => Container(
    width: 86,
    height: 86,
    decoration: BoxDecoration(color: const Color(0xFF191919), borderRadius: BorderRadius.circular(43)),
    child: const Center(
      child: Icon(Icons.search_rounded, color: Color(0xFFFFD400), size: 46),
    ),
  );
}
