import 'package:flutter/material.dart';

class ChessBoard extends StatelessWidget {
  const ChessBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8,
        ),
        itemCount: 64,
        itemBuilder: (context, index) {
          final row = index ~/ 8;
          final column = index % 8;
          final isLight = (row + column).isEven;

          return ColoredBox(
            color: isLight
                ? const Color(0xFFF0D9B5)
                : const Color(0xFFB58863),
          );
        },
      ),
    );
  }
}
