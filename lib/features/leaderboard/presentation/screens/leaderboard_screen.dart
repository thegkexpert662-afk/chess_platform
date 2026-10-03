import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Leaderboard',
    subtitle: 'Live player ratings and rankings.',
    icon: Icons.leaderboard_rounded,
    endpoint: '/dashboard',
    section: 'leaderboard',
  );
}
