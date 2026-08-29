import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key, required this.api});
  final ApiService api;
  @override State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool loading = true;
  List<dynamic> users = [];
  @override void initState(){super.initState(); load();}
  Future<void> load() async { setState(()=>loading=true); try { final d=await widget.api.getAdminUsers(); if(mounted)setState(()=>users=d is List?d:[]); } on ApiException catch(e){msg(e.message);} finally {if(mounted)setState(()=>loading=false);} }
  void msg(String s){if(!mounted)return;ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}
  String role(dynamic r){switch(r?.toString()){case 'owner':return 'المالك';case 'admin':return 'أدمن';case 'showroom':return 'صاحب معرض';case 'parts':return 'قطع غيار';case 'seller':return 'بائع';default:return 'مستخدم';}}
  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:const Color(0xFF08080B),appBar:AppBar(title:const Text('المستخدمون',style:TextStyle(fontWeight:FontWeight.w900)),centerTitle:true,actions:[IconButton(onPressed:load,icon:const Icon(Icons.refresh_rounded))]),body:loading?const Center(child:CircularProgressIndicator(color:Color(0xFFFF176F))):RefreshIndicator(color:const Color(0xFFFF176F),onRefresh:load,child:ListView.builder(padding:const EdgeInsets.all(14),itemCount:users.length,itemBuilder:(_,i){final u=Map<String,dynamic>.from(users[i] as Map);return Card(color:const Color(0xFF15151B),child:ListTile(title:Text(u['name']?.toString()??'بدون اسم',style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w800)),subtitle:Text('${u['phone']??''} • ${role(u['role'])}',style:const TextStyle(color:Colors.white54,fontSize:11)));})));}
}
