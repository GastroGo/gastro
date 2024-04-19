import 'package:flutter/material.dart';

import '../values/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.black,
      color: Colors.white70,
      margin: const EdgeInsets.all(8.0),
      child: SizedBox.expand(
        child: Center(
          child: Text('Notifications', style: AppTheme.titleLarge.copyWith(color: Colors.black)),
        )
      ),
    );
  }
}