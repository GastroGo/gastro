import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class Dashboard extends StatefulWidget {
  final User user;
  final String id;

  Dashboard({required this.user, required this.id});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.dashboard),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text(AppStrings.logout),
            onPressed: () async {
              await _auth.signOut();
              NavigationHelper.pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Display Name: ${widget.user.displayName ?? 'Restaurant'}'),
            Text('Email: ${widget.user.email ?? ''}'),
            Text('ID: ${widget.id}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
