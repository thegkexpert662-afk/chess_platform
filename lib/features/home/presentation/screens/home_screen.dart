import 'package:flutter/material.dart';

import '../../../chess/presentation/screens/chess_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess Platform')),
      body: Center(
        child: FilledButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ChessScreen(),
              ),
            );
          },
          child: const Text('Play Chess'),
        ),
      ),
    );
  }
}
