import 'package:flutter/material.dart';

import '../widgets/chess_board.dart';

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chess')),
      body: const SafeArea(
        child: Center(
          child: ChessBoard(),
        ),
      ),
    );
  }
}
