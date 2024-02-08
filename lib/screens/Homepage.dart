import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';

class Homepage extends StatefulWidget {
  final User user;

  Homepage({required this.user});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
              NavigationHelper.pushReplacementNamed(
                AppRoutes.login,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Display Name: ${widget.user.displayName ?? 'Guest'}'),
            Text('Email: ${widget.user.email ?? ''}'),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
