import 'package:flutter/material.dart';
import '../../../chess/presentation/screens/online_lobby_screen.dart';
import '../../../chess/presentation/screens/computer_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../coins/presentation/screens/coins_screen.dart';
import '../../../leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../../games/presentation/screens/my_games_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../../tournaments/presentation/screens/tournaments_screen.dart';
import '../../data/dashboard_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final api = DashboardRepository();
  late final AnimationController _controller;
  late Future<Map<String,dynamic>> _future;

  static const bg=Color(0xFF120D08), panel=Color(0xFF21150C), panel2=Color(0xFF302015);
  static const gold=Color(0xFFD6A84F), cream=Color(0xFFF5E7C9), muted=Color(0xFFB9A78A);

  @override void initState(){super.initState(); _controller=AnimationController(vsync:this,duration:const Duration(milliseconds:700))..forward(); _future=api.dashboard();}
  @override void dispose(){_controller.dispose();super.dispose();}
  void _refresh(){setState(()=>_future=api.dashboard());}
  void _open(Widget page)=>Navigator.of(context).push(PageRouteBuilder(pageBuilder:(_,a,__ )=>page,transitionsBuilder:(_,a,__,child)=>FadeTransition(opacity:a,child:child),transitionDuration:const Duration(milliseconds:280))).then((_)=>_refresh());

  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:bg,
    body:SafeArea(child:FutureBuilder<Map<String,dynamic>>(
      future:_future,
      builder:(context,snapshot){
        if(snapshot.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator(color:gold));
        if(snapshot.hasError)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
          const Icon(Icons.cloud_off_rounded,color:gold,size:42),const SizedBox(height:12),
          const Text('Unable to load your dashboard',style:TextStyle(color:cream,fontWeight:FontWeight.w800)),
          const SizedBox(height:8),TextButton(onPressed:_refresh,child:const Text('Retry')),
        ]));
        final d=snapshot.data!;
        final user=Map<String,dynamic>.from(d['user']??{});
        final stats=Map<String,dynamic>.from(d['stats']??{});
        final wallet=Map<String,dynamic>.from(d['wallet']??{});
        final notifications=List<Map<String,dynamic>>.from((d['notifications']??[]).map((e)=>Map<String,dynamic>.from(e)));
        final unread=notifications.where((n)=>n['is_read']==false).length;
        final games=List<Map<String,dynamic>>.from((d['recentGames']??[]).map((e)=>Map<String,dynamic>.from(e)));
        return FadeTransition(opacity:CurvedAnimation(parent:_controller,curve:Curves.easeOut),child:RefreshIndicator(
          onRefresh:()async=>_refresh(),color:gold,backgroundColor:panel,
          child:ListView(padding:const EdgeInsets.fromLTRB(18,14,18,30),children:[
            Row(children:[
              Container(width:46,height:46,decoration:BoxDecoration(gradient:const LinearGradient(colors:[gold,Color(0xFF9D7128)]),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.emoji_events_rounded,color:Color(0xFF21150C),size:27)),
              const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('CHESS PLATFORM',style:TextStyle(color:cream,fontSize:18,fontWeight:FontWeight.w900,letterSpacing:1.5)),Text('KOPERSAY TECHNOLOGY',style:TextStyle(color:gold,fontSize:8,fontWeight:FontWeight.w800,letterSpacing:2.4))])),
              _iconButton(Icons.notifications_none_rounded,()=>_open(const NotificationsScreen()),badge:unread),
              const SizedBox(width:6),_iconButton(Icons.settings_outlined,()=>_open(const SettingsScreen())),
            ]),
            const SizedBox(height:18),
            GestureDetector(onTap:()=>_open(const ProfileScreen()),child:Container(
              padding:const EdgeInsets.all(16),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF3A2818),panel]),borderRadius:BorderRadius.circular(22),border:Border.all(color:gold.withValues(alpha:.28))),
              child:Row(children:[const CircleAvatar(radius:27,backgroundColor:cream,child:Icon(Icons.person_rounded,color:Color(0xFF2B1B10),size:31)),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                const Text('Welcome back',style:TextStyle(color:muted,fontSize:11)),Text(user['username']?.toString()??'Player',style:const TextStyle(color:cream,fontSize:19,fontWeight:FontWeight.w900)),const SizedBox(height:3),
                Text('Rating ${user['rating']??1200}  •  ${stats['games']??0} games',style:const TextStyle(color:gold,fontSize:11,fontWeight:FontWeight.w700)),
              ])),_coinPill((wallet['coin_balance']??0).toString())]),
            )),
            const SizedBox(height:16),_statsRow(stats),const SizedBox(height:18),_heroCard(),
            const SizedBox(height:18),const Text('PLAY',style:TextStyle(color:muted,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:2)),const SizedBox(height:9),
            Row(children:[Expanded(child:_actionCard(Icons.flash_on_rounded,'Quick Game','Fast online match',gold,()=>_open(const OnlineLobbyScreen()),large:true)),const SizedBox(width:10),Expanded(child:_actionCard(Icons.smart_toy_rounded,'Computer','Practice & improve',Color(0xFFB89562),()=>_open(const ComputerScreen()),large:true))]),
            const SizedBox(height:18),const Text('DISCOVER',style:TextStyle(color:muted,fontSize:11,fontWeight:FontWeight.w900,letterSpacing:2)),const SizedBox(height:9),
            GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:1.55,children:[
              _actionCard(Icons.emoji_events_rounded,'Tournaments','Live from server',gold,()=>_open(const TournamentsScreen())),
              _actionCard(Icons.leaderboard_rounded,'Leaderboard','Live ratings',Color(0xFFB78D4C),()=>_open(const LeaderboardScreen())),
              _actionCard(Icons.history_rounded,'My Games','${games.length} recent games',Color(0xFF9E8158),()=>_open(const MyGamesScreen())),
              _actionCard(Icons.monetization_on_rounded,'Coins','${wallet['coin_balance']??0} available',gold,()=>_open(const CoinsScreen())),
            ]),
          ]),
        ));
      },
    )),
  );

  Widget _statsRow(Map<String,dynamic> s)=>Row(children:[_stat('${s['wins']??0}','Wins'),const SizedBox(width:7),_stat('${s['losses']??0}','Losses'),const SizedBox(width:7),_stat('${s['draws']??0}','Draws')]);
  Widget _stat(String value,String label)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:13),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(14),border:Border.all(color:gold.withValues(alpha:.12))),child:Column(children:[Text(value,style:const TextStyle(color:cream,fontSize:18,fontWeight:FontWeight.w900)),Text(label,style:const TextStyle(color:muted,fontSize:9))])));
  Widget _heroCard()=>Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(colors:[Color(0xFF4A3219),Color(0xFF24170D)]),border:Border.all(color:gold.withValues(alpha:.5))),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('READY FOR YOUR NEXT MOVE?',style:TextStyle(color:cream,fontSize:17,fontWeight:FontWeight.w900)),const SizedBox(height:6),const Text('Challenge a player and climb the rating ladder.',style:TextStyle(color:muted,fontSize:11)),const SizedBox(height:14),FilledButton.icon(onPressed:()=>_open(const OnlineLobbyScreen()),icon:const Icon(Icons.play_arrow_rounded),label:const Text('PLAY ONLINE'),style:FilledButton.styleFrom(backgroundColor:gold,foregroundColor:Color(0xFF24170D)))])),const Icon(Icons.auto_awesome_rounded,color:gold,size:64)]));
  Widget _actionCard(IconData icon,String title,String subtitle,Color accent,VoidCallback onTap,{bool large=false})=>Material(color:Colors.transparent,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(18),child:Container(padding:EdgeInsets.all(large?16:13),decoration:BoxDecoration(color:panel,borderRadius:BorderRadius.circular(18),border:Border.all(color:accent.withValues(alpha:.2))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.center,children:[Icon(icon,color:accent,size:large?30:25),const SizedBox(height:8),Text(title,style:const TextStyle(color:cream,fontSize:14,fontWeight:FontWeight.w900)),const SizedBox(height:2),Text(subtitle,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(color:muted,fontSize:9))]))));
  Widget _iconButton(IconData icon,VoidCallback onTap,{int badge=0})=>Stack(clipBehavior:Clip.none,children:[Material(color:panel2,borderRadius:BorderRadius.circular(13),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(13),child:Padding(padding:const EdgeInsets.all(10),child:Icon(icon,color:cream,size:21)))),if(badge>0)Positioned(right:-2,top:-4,child:Container(width:17,height:17,alignment:Alignment.center,decoration:const BoxDecoration(color:Color(0xFFB42A2A),shape:BoxShape.circle),child:Text('$badge',style:const TextStyle(color:Colors.white,fontSize:9,fontWeight:FontWeight.w900))))]);
  Widget _coinPill(String value)=>Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),decoration:BoxDecoration(color:const Color(0x332D220F),borderRadius:BorderRadius.circular(13),border:Border.all(color:gold.withValues(alpha:.35))),child:Row(children:[const Icon(Icons.monetization_on_rounded,color:gold,size:18),const SizedBox(width:5),Text(value,style:const TextStyle(color:cream,fontWeight:FontWeight.w900))]));
}
