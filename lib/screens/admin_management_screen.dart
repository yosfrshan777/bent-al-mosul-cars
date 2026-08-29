import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key, required this.api});
  final ApiService api;
  @override State<AdminManagementScreen> createState()=>_AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  final phone=TextEditingController();
  bool loading=true; List<dynamic> admins=[];
  @override void initState(){super.initState(); load();}
  Future<void> load() async {setState(()=>loading=true);try{final d=await widget.api.getAdmins();if(mounted)setState(()=>admins=d is List?d:[]);}on ApiException catch(e){msg(e.message);}finally{if(mounted)setState(()=>loading=false);}}
  void msg(String s){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  Future<void> add() async {final p=phone.text.trim();if(p.isEmpty){msg('أدخل رقم الهاتف');return;}try{await widget.api.makeAdmin(p);phone.clear();msg('تم تعيين المستخدم كأدمن');await load();}on ApiException catch(e){msg(e.message);}}
  Future<void> remove(Map u) async {final p=u['phone']?.toString()??'';try{await widget.api.removeAdmin(p);msg('تم إلغاء صلاحية الأدمن');await load();}on ApiException catch(e){msg(e.message);}}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:const Color(0xFF08080B),appBar:AppBar(title:const Text('إدارة الأدمنية',style:TextStyle(fontWeight:FontWeight.w900)),centerTitle:true,actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh_rounded))]),body:loading?const Center(child:CircularProgressIndicator(color:Color(0xFFFF176F))):ListView(padding:const EdgeInsets.all(16),children:[TextField(controller:phone,keyboardType:TextInputType.phone,textDirection:TextDirection.ltr,style:const TextStyle(color:Colors.white),decoration:const InputDecoration(labelText:'رقم هاتف المستخدم',labelStyle:TextStyle(color:Colors.white54),filled:true,fillColor:Color(0xFF15151B))),const SizedBox(height:12),SizedBox(height:50,width:double.infinity,child:ElevatedButton(onPressed:add,style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFFFF176F)),child:const Text('تعيين كأدمن',style:TextStyle(fontWeight:FontWeight.w900)))),const SizedBox(height:24),const Text('الأدمنية والمالك',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:10),...admins.map((x){final u=Map<String,dynamic>.from(x as Map);final owner=u['role']=='owner';return Card(color:const Color(0xFF15151B),child:ListTile(title:Text(u['name']?.toString()??'بدون اسم',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),subtitle:Text('${u['phone']??''} • ${owner?'المالك':'أدمن'}',style:const TextStyle(color:Colors.white54)),trailing:owner?const Icon(Icons.lock_rounded,color:Colors.white38):IconButton(onPressed:()=>remove(u),icon:const Icon(Icons.remove_circle_outline,color:Colors.redAccent)));})]));
  @override void dispose(){phone.dispose();super.dispose();}
}
