import 'package:flutter/material.dart';
import '../../data/dashboard_repository.dart';

class AdvancedFeatureScreen extends StatefulWidget {
  final String title, subtitle, endpoint, section;
  final IconData icon;
  const AdvancedFeatureScreen({super.key,required this.title,required this.subtitle,required this.icon,required this.endpoint,required this.section});
  @override State<AdvancedFeatureScreen> createState()=>_AdvancedFeatureScreenState();
}
class _AdvancedFeatureScreenState extends State<AdvancedFeatureScreen> with SingleTickerProviderStateMixin {
  final api=DashboardRepository();
  late final AnimationController c;
  late Future<Map<String,dynamic>> future;
  static const bg=Color(0xFF120D08),panel=Color(0xFF21150C),gold=Color(0xFFD6A84F),cream=Color(0xFFF5E7C9),muted=Color(0xFFB9A78A);
  @override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(milliseconds:600))..forward();future=_load();}
  Future<Map<String,dynamic>> _load(){switch(widget.endpoint){case '/dashboard/coins':return api.coins();case '/dashboard/notifications':return api.notifications();case '/dashboard/tournaments':return api.tournaments();case '/dashboard/settings':return api.settings();case '/dashboard/computer':return api.computer();default:return api.dashboard();}}
  Future<void> _reload()async{setState(()=>future=_load());}
  List<FeatureItem> _items(Map<String,dynamic> d){
    final out=<FeatureItem>[];
    if(widget.section=='profile'){final u=Map<String,dynamic>.from(d['user']??{}),s=Map<String,dynamic>.from(d['stats']??{});out.add(FeatureItem(Icons.star_rounded,'Rating','${u['rating']??0}'));out.add(FeatureItem(Icons.bar_chart_rounded,'Games','${s['games']??0} total'));out.add(FeatureItem(Icons.trending_up_rounded,'Record','${s['wins']??0} wins • ${s['losses']??0} losses • ${s['draws']??0} draws'));}
    else if(widget.section=='coins'){final w=Map<String,dynamic>.from(d['wallet']??{});out.add(FeatureItem(Icons.account_balance_wallet_rounded,'Balance','${w['coin_balance']??0} coins'));for(final x in List<Map<String,dynamic>>.from((d['transactions']??[]).map((e)=>Map<String,dynamic>.from(e))).take(8)){out.add(FeatureItem((x['amount']??0)>=0?Icons.add_circle_outline:Icons.remove_circle_outline,x['reason']?.toString()??'Transaction','${x['amount']??0} coins'));}}
    else if(widget.section=='notifications'){for(final x in List<Map<String,dynamic>>.from((d['notifications']??[]).map((e)=>Map<String,dynamic>.from(e)))){out.add(FeatureItem(Icons.notifications_rounded,x['title']?.toString()??'Notification',x['message']?.toString()??'',x['is_read']==true?'Read':'Unread'));}if(out.isEmpty)out.add(const FeatureItem(Icons.done_all,'All clear','No notifications yet'));}
    else if(widget.section=='tournaments'){for(final x in List<Map<String,dynamic>>.from((d['tournaments']??[]).map((e)=>Map<String,dynamic>.from(e)))){out.add(FeatureItem(x['status']=='live'?Icons.live_tv:Icons.upcoming,x['name']?.toString()??'Tournament','${x['players']??0}/${x['max_players']??0} players',x['joined']==true?'Joined':x['status']?.toString()));}if(out.isEmpty)out.add(const FeatureItem(Icons.event_busy,'No tournaments','None scheduled'));}
    else if(widget.section=='leaderboard'){final xs=List<Map<String,dynamic>>.from((d['leaderboard']??[]).map((e)=>Map<String,dynamic>.from(e)));for(var i=0;i<xs.length;i++){final x=xs[i];out.add(FeatureItem(Icons.emoji_events_rounded,'#${i+1} ${x['username']??'Player'}','Rating ${x['rating']??0}'));}}
    else if(widget.section=='games'){for(final x in List<Map<String,dynamic>>.from((d['recentGames']??[]).map((e)=>Map<String,dynamic>.from(e)))){out.add(FeatureItem(Icons.history_rounded,'${x['white_username']??'?'} vs ${x['black_username']??'?'}','${x['status']??''} • ${x['result']??'pending'}'));}if(out.isEmpty)out.add(const FeatureItem(Icons.sports_esports_rounded,'No games','Your games will appear here'));}
    else if(widget.section=='settings'){final s=Map<String,dynamic>.from(d['settings']??{});out.add(FeatureItem(Icons.volume_up,'Sound',s['sound_enabled']==true?'Enabled':'Disabled'));out.add(FeatureItem(Icons.notifications_active,'Notifications',s['notifications_enabled']==true?'Enabled':'Disabled'));out.add(FeatureItem(Icons.palette,'Board theme',s['board_theme']?.toString()??'Not configured'));out.add(FeatureItem(Icons.extension,'Piece style',s['piece_style']?.toString()??'Not configured'));}
    else if(widget.section=='computer'){for(final x in List<Map<String,dynamic>>.from((d['modes']??[]).map((e)=>Map<String,dynamic>.from(e)))){out.add(FeatureItem(Icons.smart_toy_rounded,x['name']?.toString()??'Mode',x['description']?.toString()??''));}out.add(FeatureItem(Icons.timer,'Time controls',(d['timeControls']??[]).join(' • ')));}
    return out;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: cream,
        elevation: 0,
        title: Row(
          children: [
            Icon(widget.icon, color: gold),
            const SizedBox(width: 10),
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: gold),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: _reload,
                child: const Text('Unable to load • Retry'),
              ),
            );
          }

          final items = _items(snapshot.data ?? <String, dynamic>{});

          return RefreshIndicator(
            onRefresh: _reload,
            color: gold,
            backgroundColor: panel,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF432D17),
                        panel,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: gold.withValues(alpha: .3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(widget.icon, color: gold, size: 34),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: cream,
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...items.map((x) => _item(x)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _item(FeatureItem x)=>Padding(padding:const EdgeInsets.only(bottom:10),child:Material(color:panel,borderRadius:BorderRadius.circular(18),child:Padding(padding:const EdgeInsets.all(17),child:Row(children:[Icon(x.icon,color:gold),const SizedBox(width:13),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x.title,style:const TextStyle(color:cream,fontWeight:FontWeight.w800)),Text(x.subtitle,style:const TextStyle(color:muted,fontSize:10))])),if(x.message!=null)Text(x.message!,style:const TextStyle(color:gold,fontSize:9))]))));
}
class FeatureItem{final IconData icon;final String title,subtitle;final String? message;const FeatureItem(this.icon,this.title,this.subtitle,[this.message]);}
