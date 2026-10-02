import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/home/presentation/screens/home_screen.dart';

class ChessPlatformApp extends StatelessWidget {
  const ChessPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
