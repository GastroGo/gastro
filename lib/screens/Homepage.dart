import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'Login.dart';

class Homepage extends StatefulWidget {
  final User user;

  Homepage({required this.user});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final AuthService _auth = AuthService();

  Future<void> setUserDisplayName() async {
    try {
      await widget.user.updateDisplayName('user');
      print('Display name set to user');
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
        title: Text('Homepage'),
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
            Text('Display Name: ${widget.user.displayName ?? 'Guest'}'),
            Text('Email: ${widget.user.email ?? ''}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: setUserDisplayName,
              child: Text('Set Display Name to User'),
            ),
          ],
        ),
      ),
    );
  }
}
