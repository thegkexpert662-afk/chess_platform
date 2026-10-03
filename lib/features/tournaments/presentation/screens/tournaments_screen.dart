import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class TournamentsScreen extends StatelessWidget {
  const TournamentsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Tournaments',
    subtitle: 'Live tournament data from the server.',
    icon: Icons.emoji_events_rounded,
    endpoint: '/dashboard/tournaments',
    section: 'tournaments',
  );
}
