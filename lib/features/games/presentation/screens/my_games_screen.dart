import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class MyGamesScreen extends StatelessWidget {
  const MyGamesScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'My Games',
    subtitle: 'Your live match history.',
    icon: Icons.history_rounded,
    endpoint: '/dashboard',
    section: 'games',
  );
}
