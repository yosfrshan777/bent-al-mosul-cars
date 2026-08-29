import 'package:flutter/material.dart';
import 'screens/add_car_screen.dart';
import 'screens/cars_screen.dart';
import 'screens/zyocar_home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/showrooms_screen.dart';
import 'screens/parts_screen.dart';
import 'services/api_service.dart';
import 'widgets/zyocar_logo.dart';

const Color kPink = Color(0xFFFF176F);
const Color kBlue = Color(0xFF1597FF);
const Color kBg = Color(0xFF07090F);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final api = ApiService();
  await api.initAuth();
  runApp(ZyoCarApp(api: api));
}

class ZyoCarApp extends StatelessWidget {
  const ZyoCarApp({super.key, required this.api});
  final ApiService api;
  @override Widget build(BuildContext context) => MaterialApp(debugShowCheckedModeBanner:false,title:'ZYOCAR',theme:ThemeData.dark().copyWith(scaffoldBackgroundColor:kBg,colorScheme:ColorScheme.fromSeed(seedColor:kPink,brightness:Brightness.dark)),home:SplashScreen(api:api));
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key,required this.api}); final ApiService api; @override State<SplashScreen> createState()=>_SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController controller=AnimationController(vsync:this,duration:const Duration(milliseconds:1200))..forward();
  @override void initState(){super.initState();Future.delayed(const Duration(milliseconds:1800),(){if(!mounted)return;Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>AuthGate(api:widget.api)));});}
  @override void dispose(){controller.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.black,body:Center(child:FadeTransition(opacity:CurvedAnimation(parent:controller,curve:Curves.easeOut),child:Column(mainAxisAlignment:MainAxisAlignment.center,children:const[ZyoCarLogo(size:96,showWordmark:true),SizedBox(height:22),Text('بيع وشراء السيارات وقطع الغيار',style:TextStyle(color:Colors.white70,fontSize:13)),SizedBox(height:8),Text('IRAQ • CAR MARKET',style:TextStyle(color:kBlue,fontSize:8,fontWeight:FontWeight.w800,letterSpacing:2.5))])));
}

class AuthGate extends StatefulWidget { const AuthGate({super.key,required this.api}); final ApiService api; @override State<AuthGate> createState()=>_AuthGateState(); }
class _AuthGateState extends State<AuthGate>{bool checking=true,loggedIn=false;@override void initState(){super.initState();check();}Future<void>check()async{var valid=widget.api.isLoggedIn;if(valid){try{await widget.api.me();}catch(_){valid=false;}}if(!mounted)return;setState((){loggedIn=valid;checking=false;});}Future<void>login()async{final result=await Navigator.push(context,MaterialPageRoute(builder:(_)=>LoginScreen(api:widget.api)));if(result!=null&&mounted)setState(()=>loggedIn=true);}@override Widget build(BuildContext context){if(checking)return const Scaffold(body:Center(child:CircularProgressIndicator(color:kPink)));if(loggedIn)return MainShell(api:widget.api);return LoginRequiredScreen(onLogin:login);}}

class LoginRequiredScreen extends StatelessWidget{const LoginRequiredScreen({super.key,required this.onLogin});final VoidCallback onLogin;@override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:kBg,body:Center(child:Padding(padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[const ZyoCarLogo(size:82,showWordmark:false),const SizedBox(height:22),const Text('تسجيل الدخول مطلوب',style:TextStyle(color:Colors.white,fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('سجّل دخولك حتى تدخل إلى ZYOCAR',textAlign:TextAlign.center,style:TextStyle(color:Colors.white54)),const SizedBox(height:24),SizedBox(width:double.infinity,height:54,child:ElevatedButton(onPressed:onLogin,style:ElevatedButton.styleFrom(backgroundColor:kPink,foregroundColor:Colors.white),child:const Text('تسجيل الدخول',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900))))]))));}

class MainShell extends StatefulWidget{const MainShell({super.key,required this.api});final ApiService api;@override State<MainShell> createState()=>_MainShellState();}
class _MainShellState extends State<MainShell>{int index=0;void addCar()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>AddCarScreen(api:widget.api)));void showrooms()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ShowroomsScreen(api:widget.api)));void parts()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>PartsScreen(api:widget.api)));@override Widget build(BuildContext context){final pages=<Widget>[ZyoCarHomeScreen(api:widget.api,onOpenCars:()=>setState(()=>index=1),onOpenShowrooms:showrooms,onOpenParts:parts,onAddCar:addCar),CarsScreen(api:widget.api),const Center(child:Text('ريلز',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900))),const Center(child:Text('المفضلة',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900))),ProfileScreen(api:widget.api)];return Scaffold(body:IndexedStack(index:index,children:pages),floatingActionButton:FloatingActionButton(onPressed:addCar,backgroundColor:kPink,foregroundColor:Colors.white,child:const Icon(Icons.add_rounded)),floatingActionButtonLocation:FloatingActionButtonLocation.startFloat,bottomNavigationBar:NavigationBar(selectedIndex:index,onDestinationSelected:(value)=>setState(()=>index=value),backgroundColor:const Color(0xFF0D1018),indicatorColor:kPink.withOpacity(.20),destinations:const[NavigationDestination(icon:Icon(Icons.home_outlined),label:'الرئيسية'),NavigationDestination(icon:Icon(Icons.search_outlined),label:'السيارات'),NavigationDestination(icon:Icon(Icons.play_circle_outline),label:'ريلز'),NavigationDestination(icon:Icon(Icons.favorite_border),label:'المفضلة'),NavigationDestination(icon:Icon(Icons.person_outline),label:'حسابي')]));}}
