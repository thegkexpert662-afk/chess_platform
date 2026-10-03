import 'package:flutter/material.dart';

class AdvancedFeatureScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<FeatureItem> items;
  const AdvancedFeatureScreen({super.key, required this.title, required this.subtitle, required this.icon, required this.items});
  @override State<AdvancedFeatureScreen> createState()=>_AdvancedFeatureScreenState();
}
class _AdvancedFeatureScreenState extends State<AdvancedFeatureScreen> with SingleTickerProviderStateMixin {
  late final AnimationController c;
  static const bg=Color(0xFF120D08), panel=Color(0xFF21150C), gold=Color(0xFFD6A84F), cream=Color(0xFFF5E7C9), muted=Color(0xFFB9A78A);
  @override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(milliseconds:700))..forward();}
  @override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:bg,
    appBar:AppBar(backgroundColor:bg,foregroundColor:cream,elevation:0,title:Row(children:[Icon(widget.icon,color:gold),const SizedBox(width:10),Text(widget.title,style:const TextStyle(fontWeight:FontWeight.w900))])),
    body: FadeTransition(opacity:CurvedAnimation(parent:c,curve:Curves.easeOut),child: ListView(padding:const EdgeInsets.fromLTRB(18,10,18,30),children:[
      Container(padding:const EdgeInsets.all(22),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF432D17),panel]),borderRadius:BorderRadius.circular(24),border:Border.all(color:gold.withValues(alpha:.3))),child:Row(children:[Container(width:58,height:58,decoration:BoxDecoration(color:gold.withValues(alpha:.15),borderRadius:BorderRadius.circular(18)),child:Icon(widget.icon,color:gold,size:31)),const SizedBox(width:15),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.title,style:const TextStyle(color:cream,fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(widget.subtitle,style:const TextStyle(color:muted,fontSize:11))]))])),
      const SizedBox(height:18),
      ...widget.items.asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:10),child: _item(e.value))),
    ]));
  Widget _item(FeatureItem x)=>Material(color:panel,borderRadius:BorderRadius.circular(18),child:InkWell(onTap:()=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(x.message??'Coming soon'))),borderRadius:BorderRadius.circular(18),child:Padding(padding:const EdgeInsets.all(17),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:gold.withValues(alpha:.1),borderRadius:BorderRadius.circular(13)),child:Icon(x.icon,color:gold)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x.title,style:const TextStyle(color:cream,fontWeight:FontWeight.w800)),const SizedBox(height:3),Text(x.subtitle,style:const TextStyle(color:muted,fontSize:10))])),const Icon(Icons.chevron_right_rounded,color:muted)])));
}
class FeatureItem {final IconData icon;final String title;final String subtitle;final String? message;const FeatureItem(this.icon,this.title,this.subtitle,[this.message]);}
