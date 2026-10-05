// features/driver/presentation/NavigateRoutePage/Notifications.dart
import 'package:flutter/material.dart';
import 'package:jtrips_app/features/notifications/presentation/notifications_screen.dart';

/// Thin wrapper kept so existing `const Notifications()` call sites keep
/// working. The real screen is shared by every role.
class Notifications extends StatelessWidget {
  const Notifications({super.key});

  @override
  Widget build(BuildContext context) => const NotificationsScreen();
}