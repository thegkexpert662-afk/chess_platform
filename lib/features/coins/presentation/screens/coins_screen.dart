import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Coins',
    subtitle: 'Your live virtual chess rewards wallet.',
    icon: Icons.monetization_on_rounded,
    endpoint: '/dashboard/coins',
    section: 'coins',
  );
}
