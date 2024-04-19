import 'package:flutter/material.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _buildSquareButton(AppStrings.menu, Icons.menu, context, AppRoutes.menu),
          _buildSquareButton(AppStrings.tables, Icons.table_chart, context, AppRoutes.tables),
          _buildSquareButton(AppStrings.employees, Icons.people, context, AppRoutes.employees),
          _buildSquareButton(AppStrings.qrcodes, Icons.qr_code, context, AppRoutes.qrcodes),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String title, IconData icon, BuildContext context, String routeName) {
    return Card(
      color: Colors.amber, // Change this to your preferred color
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          NavigationHelper.pushNamed(routeName);
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 70.0, color: Colors.black87), // Change the icon color if needed
              Text(
                title,
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.black87), // Change the text color if needed
              ),
            ],
          ),
        ),
      ),
    );
  }
}