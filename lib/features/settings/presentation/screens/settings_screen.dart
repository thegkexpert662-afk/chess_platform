import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Settings',
    subtitle: 'Your saved chess preferences.',
    icon: Icons.settings_rounded,
    endpoint: '/dashboard/settings',
    section: 'settings',
  );
}
