import 'package:flutter/material.dart';
import '../../../core/network/app_services.dart';
import '../../data/chess_repository.dart';
import 'online_game_screen.dart';

class OnlineLobbyScreen extends StatefulWidget{
  const OnlineLobbyScreen({super.key});
  @override State<OnlineLobbyScreen> createState()=>_OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen>{
  bool busy=false;
  Future<void> findGame() async{
    setState(()=>busy=true);
    try{
      final data=await ChessRepository(apiClient).joinQueue();
      final id=data['gameId'] as String;
      if(!mounted)return;
      Navigator.of(context).push(MaterialPageRoute(builder:(_)=>OnlineGameScreen(gameId:id)));
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Online Chess')),
    body:Center(child:FilledButton(
      onPressed:busy?null:findGame,
      child:Text(busy?'Finding opponent...':'Find opponent'),
    )),
  );
}
