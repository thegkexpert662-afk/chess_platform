import 'package:flutter/material.dart';
import '../../../core/network/app_services.dart';
import '../../data/auth_repository.dart';
import '../../../home/presentation/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState()=>_RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>{
  final username=TextEditingController();
  final email=TextEditingController();
  final password=TextEditingController();
  bool busy=false;

  Future<void> submit() async {
    setState(()=>busy=true);
    try{
      final data=await AuthRepository(apiClient).register(username.text.trim(),email.text.trim(),password.text);
      apiClient.token=data['token'] as String;
      if(!mounted)return;
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder:(_)=>const HomeScreen()),(r)=>false);
    }catch(e){
      if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }finally{if(mounted)setState(()=>busy=false);}
  }

  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Create account')),
    body:Padding(
      padding:const EdgeInsets.all(24),
      child:Column(mainAxisAlignment:MainAxisAlignment.center,children:[
        TextField(controller:username,decoration:const InputDecoration(labelText:'Username')),
        TextField(controller:email,decoration:const InputDecoration(labelText:'Email')),
        TextField(controller:password,obscureText:true,decoration:const InputDecoration(labelText:'Password')),
        const SizedBox(height:20),
        FilledButton(onPressed:busy?null:submit,child:Text(busy?'Creating...':'Create account')),
      ]),
    ),
  );
}
