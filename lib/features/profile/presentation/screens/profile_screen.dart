import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Profile',
    subtitle: 'Your live rating, statistics and chess identity.',
    icon: Icons.person_rounded,
    endpoint: '/dashboard',
    section: 'profile',
  );
}
