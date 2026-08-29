import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key, required this.api});
  final ApiService api;
  @override State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final formKey = GlobalKey<FormState>();
  final price = TextEditingController();
  final phone = TextEditingController();
  final description = TextEditingController();
  final picker = ImagePicker();

  static const brands = <String>['تويوتا','هيونداي','بي إم دبليو','مرسيدس','كيا','نيسان','أودي','فورد','شيفروليه','مازدا','هوندا','لكزس','ميتسوبيشي','جيب','فولكس فاجن','بورشه','تسلا','سوزوكي','رينو','بيجو','شيري','MG','جيلي','هافال','BYD'];
  static const cities = <String>['بغداد','نينوى','البصرة','أربيل','دهوك','السليمانية','كركوك','الأنبار','صلاح الدين','ديالى','واسط','بابل','كربلاء','النجف','القادسية','ميسان','ذي قار','المثنى'];
  static const bodyTypes = <String>['سيدان','SUV','كروس أوفر','بيك أب','كوبيه','هاتشباك','فان','واجِن','شاحنة','ميني فان'];
  static const fuelTypes = <String>['بنزين','ديزل','هايبرد','كهرباء'];
  static const transmissions = <String>['أوتوماتيك','عادي'];
  final years = List<int>.generate(47, (i) => 2026 - i);
  final Map<String,List<String>> models = const {
    'تويوتا':['كامري','كورولا','لاندكروزر','راف فور','هايلاندر','برادو','يارس','تندرا','تاكوما','أفالون','إنوفا'],
    'هيونداي':['توسان','سوناتا','إلنترا','سانتافي','كونا','أكسنت','باليسايد','كريتا'],
    'بي إم دبليو':['X5','X3','X6','الفئة الثالثة','الفئة الخامسة','الفئة السابعة','X1','X7'],
    'مرسيدس':['C-Class','E-Class','S-Class','GLE','GLC','G-Class','A-Class'],
    'كيا':['سبورتاج','سورينتو','K5','سيراتو','سيلتوس','كارنفال','ريو'],
    'نيسان':['باترول','ألتيما','سنترا','إكس تريل','صني','كيكس','نافارا'],
    'أودي':['A4','A6','Q5','Q7','Q8','A3'],
    'فورد':['إكسبلورر','إيدج','إف-150','موستانغ','إسكيب','إكسبيديشن'],
    'شيفروليه':['تاهو','سوبربان','ماليبو','كابتيفا','سيلفرادو','كولورادو'],
    'مازدا':['CX-5','CX-9','6','3','CX-30'],
    'هوندا':['أكورد','سيفيك','CR-V','بايلوت','HR-V'],
    'لكزس':['LX','GX','RX','ES','IS','NX'],
    'ميتسوبيشي':['باجيرو','أوتلاندر','ASX','L200'],
    'جيب':['جراند شيروكي','رانجلر','كومباس','جلاديتور'],
    'فولكس فاجن':['تيرامونت','تيغوان','جيتا','باسات'],
    'بورشه':['كاين','ماكان','911','باناميرا'],
    'تسلا':['Model 3','Model Y','Model S','Model X'],
    'سوزوكي':['سويفت','فيتارا','جيمني','سويفت ديزاير'],
    'رينو':['داستر','كوليوس','ميغان'],
    'بيجو':['3008','5008','508','2008'],
    'شيري':['تيجو 7','تيجو 8','أريزو 5'],
    'MG':['ZS','RX5','5','6'],
    'جيلي':['كولراي','أمجراند','أوكافانغو'],
    'هافال':['جوليان','H6','H9'],
    'BYD':['سونج','هان','سيل','دولفين'],
  };

  String? brand, model, city, bodyType;
  int? year;
  String fuel='بنزين', transmission='أوتوماتيك', plan='عادي';
  List<XFile> images=[];
  bool loading=false;

  InputDecoration dec(String label)=>InputDecoration(labelText:label,labelStyle:const TextStyle(color:Colors.white54),filled:true,fillColor:const Color(0xFF111722),border:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(17)),borderSide:BorderSide(color:Colors.white12)),enabledBorder:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(17)),borderSide:BorderSide(color:Colors.white12)),focusedBorder:const OutlineInputBorder(borderRadius:BorderRadius.all(Radius.circular(17)),borderSide:BorderSide(color:Color(0xFFFF176F),width:1.4)));
  Widget select<T>({required String label,required T? value,required List<T> items,required String Function(T) text,required ValueChanged<T?> onChanged})=>Padding(padding:const EdgeInsets.only(bottom:12),child:DropdownButtonFormField<T>(value:value,dropdownColor:const Color(0xFF101722),isExpanded:true,decoration:dec(label),style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700),items:items.map((x)=>DropdownMenuItem<T>(value:x,child:Text(text(x),overflow:TextOverflow.ellipsis))).toList(),onChanged:onChanged,validator:(v)=>v==null?'اختر $label':null));
  Widget input(TextEditingController c,String label,{TextInputType? type,bool required=false,int maxLines=1})=>Padding(padding:const EdgeInsets.only(bottom:12),child:TextFormField(controller:c,keyboardType:type,maxLines:maxLines,textDirection:TextDirection.rtl,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.w700),decoration:dec(label),validator:required?(v)=>v==null||v.trim().isEmpty?'هذا الحقل مطلوب':null:null));

  Future<void> chooseImages() async {
    final picked=await picker.pickMultiImage(imageQuality:88,maxWidth:1800,maxHeight:1800);
    if(picked.isEmpty)return;
    setState(()=>images=picked.take(5).toList());
    if(picked.length>5)_msg('تم اعتماد أول 5 صور فقط');
  }

  Future<void> submit() async {
    if(!formKey.currentState!.validate())return;
    if(images.length<2||images.length>5){_msg('اختر من صورتين إلى 5 صور');return;}
    final p=int.tryParse(price.text.replaceAll(',','').trim());
    if(p==null||p<=0||year==null||brand==null||model==null||city==null||bodyType==null)return;
    setState(()=>loading=true);
    try {
      final result=await widget.api.createCar(brand:brand!,model:model!,year:year!,price:p,city:city!,fuel:fuel,transmission:transmission,description:description.text.trim(),plan:plan,images:images,phone:phone.text.trim(),bodyType:bodyType);
      if(!mounted)return;
      _msg('تم إرسال السيارة للمراجعة بنجاح');
      Navigator.pop(context,result);
    } catch(e){if(mounted)_msg(e is ApiException?e.message:'تعذر نشر السيارة');}
    finally{if(mounted)setState(()=>loading=false);}
  }

  void _msg(String text)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(text),behavior:SnackBarBehavior.floating));

  @override Widget build(BuildContext context)=>Directionality(textDirection:TextDirection.rtl,child:Scaffold(backgroundColor:const Color(0xFF05070D),appBar:AppBar(title:const Text('بيع سيارة',style:TextStyle(fontWeight:FontWeight.w900)),centerTitle:true,backgroundColor:const Color(0xFF080C14)),body:Form(key:formKey,child:ListView(padding:const EdgeInsets.fromLTRB(16,16,16,32),children:[
    const Text('صور السيارة',style:TextStyle(color:Colors.white,fontSize:20,fontWeight:FontWeight.w900)),const SizedBox(height:5),const Text('اختر من صورتين إلى 5 صور',style:TextStyle(color:Colors.white54,fontSize:11)),const SizedBox(height:10),
    SizedBox(height:112,child:ListView.separated(scrollDirection:Axis.horizontal,itemCount:images.length+1,separatorBuilder:(_,__)=>const SizedBox(width:10),itemBuilder:(_,i){if(i==images.length)return InkWell(onTap:chooseImages,borderRadius:BorderRadius.circular(18),child:Container(width:112,decoration:BoxDecoration(color:const Color(0xFF101722),borderRadius:BorderRadius.circular(18),border:Border.all(color:const Color(0xFF149BFF).withOpacity(.45))),child:const Column(mainAxisAlignment:MainAxisAlignment.center,children:[Icon(Icons.add_a_photo_rounded,color:Color(0xFF149BFF),size:30),SizedBox(height:5),Text('إضافة صور',style:TextStyle(color:Colors.white70,fontSize:10))])));return Stack(children:[ClipRRect(borderRadius:BorderRadius.circular(18),child:Image.file(File(images[i].path),width:112,height:112,fit:BoxFit.cover)),Positioned(top:5,left:5,child:GestureDetector(onTap:()=>setState(()=>images.removeAt(i)),child:Container(decoration:const BoxDecoration(color:Colors.black87,shape:BoxShape.circle),padding:const EdgeInsets.all(3),child:const Icon(Icons.close,color:Colors.white,size:17))))]);})),const SizedBox(height:18),
    select(label:'ماركة السيارة',value:brand,items:brands,text:(x)=>x,onChanged:(v)=>setState((){brand=v;model=null;})),
    select(label:'الموديل',value:model,items:brand==null?const<String>[]:(models[brand!]??const<String>[]),text:(x)=>x,onChanged:(v)=>setState(()=>model=v)),
    select(label:'نوعية السيارة',value:bodyType,items:bodyTypes,text:(x)=>x,onChanged:(v)=>setState(()=>bodyType=v)),
    select(label:'سنة الصنع',value:year,items:years,text:(x)=>'$x',onChanged:(v)=>setState(()=>year=v)),
    select(label:'المحافظة',value:city,items:cities,text:(x)=>x,onChanged:(v)=>setState(()=>city=v)),
    select(label:'نوع الوقود',value:fuel,items:fuelTypes,text:(x)=>x,onChanged:(v)=>setState(()=>fuel=v!)),
    select(label:'ناقل الحركة',value:transmission,items:transmissions,text:(x)=>x,onChanged:(v)=>setState(()=>transmission=v!)),
    input(price,'السعر بالدولار الأمريكي',type:TextInputType.number,required:true),
    input(phone,'رقم الهاتف للتواصل',type:TextInputType.phone,required:true),
    input(description,'وصف السيارة',maxLines:4),
    const SizedBox(height:6),const Text('باقة النشر',style:TextStyle(color:Colors.white,fontSize:19,fontWeight:FontWeight.w900)),
    for(final item in const [('عادي',5000),('مميز',15000),('VIP',25000)])RadioListTile<String>(value:item.$1,groupValue:plan,onChanged:(v)=>setState(()=>plan=v!),title:Text('${item.$1} — ${item.$2} د.ع',style:const TextStyle(color:Colors.white70)),activeColor:const Color(0xFFFF176F)),
    const SizedBox(height:10),SizedBox(height:54,child:FilledButton(onPressed:loading?null:submit,style:FilledButton.styleFrom(backgroundColor:const Color(0xFFFF176F),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18))),child:loading?const CircularProgressIndicator(color:Colors.white):const Text('نشر السيارة',style:TextStyle(fontWeight:FontWeight.w900,fontSize:16)))),
  ])));
}
