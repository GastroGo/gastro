import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'Login.dart';

class Dashboard extends StatefulWidget {
  final User user;

  Dashboard({required this.user});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final AuthService _auth = AuthService();

  Future<void> setRestaurantDisplayName() async {
    try {
      await widget.user.updateDisplayName('restaurant');
      print('Display name set to restaurant');
      // Reload the user to get the updated user object with the new display name
      await widget.user.reload();
      setState(() {});
    } catch (e) {
      print('Error setting display name: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.person),
            label: Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: setRestaurantDisplayName,
              child: Text('Set Display Name to Restaurant'),
            ),
          ],
        ),
      ),
    );
  }
}
