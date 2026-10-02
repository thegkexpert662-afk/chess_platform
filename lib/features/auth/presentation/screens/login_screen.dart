import 'package:flutter/material.dart';
import '../../../core/network/app_services.dart';
import '../../data/auth_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=>_LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>{
  final login=TextEditingController();
  final password=TextEditingController();
  bool busy=false;

  Future<void> submit() async {
    setState(()=>busy=true);
    try{
      final data=await AuthRepository(apiClient).login(login.text.trim(),password.text);
      apiClient.token=data['token'] as String;
      if(!mounted)return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder:(_)=>const HomeScreen()),(route)=>false,
      );
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }finally{if(mounted)setState(()=>busy=false);}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Login')),
    body:Padding(
      padding:const EdgeInsets.all(24),
      child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        TextField(controller:login,decoration:const InputDecoration(labelText:'Username or email')),
        TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
        const SizedBox(height:20),
        FilledButton(onPressed:busy?null:submit,child:Text(busy?'Connecting...':'Login')),
      ]),
    ),
  );
}
