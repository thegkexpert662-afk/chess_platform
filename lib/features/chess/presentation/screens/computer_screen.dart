import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class ComputerScreen extends StatelessWidget {
  const ComputerScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Play vs Computer',
    subtitle: 'Training modes are controlled by the platform.',
    icon: Icons.smart_toy_rounded,
    endpoint: '/dashboard',
    section: 'profile',
  );
}
