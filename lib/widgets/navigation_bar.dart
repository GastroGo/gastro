import 'package:flutter/material.dart';
import '../values/app_strings.dart';

class CustomNavigationBar extends StatelessWidget {
  final int currentPageIndex;
  final ValueChanged<int> onTabSelected;

  CustomNavigationBar({required this.currentPageIndex, required this.onTabSelected});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      onDestinationSelected: onTabSelected,
      indicatorColor: Colors.amber,
      selectedIndex: currentPageIndex,
      destinations: const <Widget>[
        NavigationDestination(selectedIcon: Icon(Icons.dashboard),icon: Icon(Icons.dashboard_outlined),label: AppStrings.dashboard),
        NavigationDestination(selectedIcon: Icon(Icons.work),icon: Icon(Icons.work_outline),label: AppStrings.manage),
        NavigationDestination(selectedIcon: Icon(Icons.notifications),icon: Icon(Icons.notifications_outlined),label: AppStrings.notifications),
      ],
    );
  }
}