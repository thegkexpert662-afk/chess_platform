import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class ComputerScreen extends StatelessWidget {
  const ComputerScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Play vs Computer',
    subtitle: 'Choose your training mode and improve your game.',
    icon: Icons.smart_toy_rounded,
    items: [
      FeatureItem(Icons.speed, 'Easy', 'Relaxed practice'),
      FeatureItem(Icons.bolt, 'Medium', 'Balanced opponent'),
      FeatureItem(Icons.local_fire_department, 'Hard', 'Serious training'),
    ],
  );
}
