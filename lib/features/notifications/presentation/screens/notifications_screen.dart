import 'package:flutter/material.dart';
import '../../../home/presentation/screens/advanced_feature_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});
  @override
  Widget build(BuildContext context) => const AdvancedFeatureScreen(
    title: 'Notifications',
    subtitle: 'Live game and platform alerts.',
    icon: Icons.notifications_rounded,
    endpoint: '/dashboard/notifications',
    section: 'notifications',
  );
}
