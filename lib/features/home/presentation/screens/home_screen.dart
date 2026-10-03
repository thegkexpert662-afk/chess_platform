import 'package:flutter/material.dart';
import '../../../chess/presentation/screens/online_lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Platform')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OnlineLobbyScreen()),
              ),
              child: const Text('Play Online'),
            ),
          ],
        ),
      ),
    );
  }
}
