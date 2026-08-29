import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';

class PaymentBarcodeScreen extends StatefulWidget {
  const PaymentBarcodeScreen({super.key, required this.api, this.amount});
  final ApiService api;
  final int? amount;
  @override State<PaymentBarcodeScreen> createState()=>_PaymentBarcodeScreenState();
}

class _PaymentBarcodeScreenState extends State<PaymentBarcodeScreen> {
  bool loading=true; String? error; Map<String,dynamic> settings={};
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {try{final d=await widget.api.getPaymentSettings();if(!mounted)return;setState((){settings=d is Map?Map<String,dynamic>.from(d):{};loading=false;});}catch(e){if(mounted)setState((){loading=false;error=e is ApiException?e.message:'تعذر تحميل بيانات الدفع';});}}
  String get payload {final configured=settings['barcode_data']?.toString().trim()??'';if(configured.isNotEmpty)return configured;return 'ZYOCAR|${settings['method']??'card'}|${settings['account_name']??''}|${settings['phone']??''}|${settings['card_number']??''}|${widget.amount??0}';}
  @override Widget build(BuildContext context){return Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:const Color(0xFF07090F),appBar:AppBar(title:const Text('باركود الدفع',style:TextStyle(fontWeight:FontWeight.w900)),backgroundColor:const Color(0xFF07090F)),body:loading?const Center(child:CircularProgressIndicator(color:Color(0xFFFF176F))):error!=null?Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(error!,style:const TextStyle(color:Colors.white70)),TextButton(onPressed:_load,child:const Text('إعادة المحاولة'))]):ListView(padding:const EdgeInsets.all(20),children:[
    Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:const Color(0xFF101522),borderRadius:BorderRadius.circular(26),border:Border.all(color:const Color(0xFFFF176F).withOpacity(.35))),child:Column(children:[
      const Text('امسح الباركود للدفع',style:TextStyle(color:Colors.white,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:8),
      const Text('استخدم تطبيق الدفع أو الكاميرا لقراءة الباركود.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white54)),const SizedBox(height:20),
      Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22)),child:QrImageView(data:payload,size:250,backgroundColor:Colors.white)),
      const SizedBox(height:18),
      if(widget.amount!=null)Text('المبلغ: ${widget.amount} د.ع',style:const TextStyle(color:Color(0xFFFF176F),fontSize:18,fontWeight:FontWeight.w900)),
      if((settings['account_name']??'').toString().isNotEmpty)Text('الحساب: ${settings['account_name']}',style:const TextStyle(color:Colors.white70)),
      if((settings['phone']??'').toString().isNotEmpty)Text('الهاتف: ${settings['phone']}',style:const TextStyle(color:Colors.white70)),
      if((settings['method']??'').toString().isNotEmpty)Text('طريقة الدفع: ${settings['method']}',style:const TextStyle(color:Colors.white70)),
    ])),const SizedBox(height:14),
    const Text('بعد التحويل، احتفظ بإيصال الدفع وأرسله حسب تعليمات الإدارة.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white38,fontSize:12)),
  ]));}
}
