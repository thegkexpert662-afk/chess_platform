import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/app_services.dart';
import '../../data/chess_repository.dart';
import 'online_game_screen.dart';

class OnlineLobbyScreen extends StatefulWidget{
  const OnlineLobbyScreen({super.key});
  @override State<OnlineLobbyScreen> createState()=>_OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen>{
  bool busy=false;
  Timer? timer;

  Future<void> findGame() async{
    setState(()=>busy=true);
    try{
      final data=await ChessRepository(apiClient).joinQueue();
      final id=data['gameId'] as String;
      if(!mounted)return;
      timer?.cancel();
      timer=Timer.periodic(const Duration(seconds:2),(_)=>checkGame(id));
      if(data['status']=='active'){
        openGame(id);
      }else{
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Waiting for opponent...')));
      }
    }catch(e){
      if(mounted){
        setState(()=>busy=false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
      }
    }
  }

  Future<void> checkGame(String id) async{
    try{
      final data=await ChessRepository(apiClient).game(id);
      if(data['game']['status']=='active' && mounted){
        timer?.cancel();
        openGame(id);
      }
    }catch(_){}
  }

  void openGame(String id){
    setState(()=>busy=false);
    Navigator.of(context).push(MaterialPageRoute(builder:(_)=>OnlineGameScreen(gameId:id)));
  }

  @override void dispose(){timer?.cancel();super.dispose();}

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Online Chess')),
    body:Center(child:FilledButton(
      onPressed:busy?null:findGame,
      child:Text(busy?'Finding opponent...':'Find opponent'),
    )),
  );
}
