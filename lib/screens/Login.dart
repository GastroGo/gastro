import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/Homepage.dart';
import 'package:gastro/screens/Register.dart';
import 'package:gastro/screens/Dashboard.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                onChanged: (value) {
                  setState(() => email = value);
                },
                validator: (value) => value!.isEmpty ? 'Enter an email' : null,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                },
                validator: (value) =>
                    value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result =
                        await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      print('Could not sign in with those credentials');
                    } else {
                      print('Signed in');
                      print(result);

                      DatabaseReference ref =
                          FirebaseDatabase.instance.ref("Restaurants");
                      ref
                          .orderByChild("daten/uid")
                          .equalTo(result.uid)
                          .once()
                          .then((DatabaseEvent event) {
                        DataSnapshot snapshot = event.snapshot;

                        if (snapshot.value != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Dashboard(user: result)),
                          );
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Homepage(user: result)),
                          );
                        }
                      });
                    }
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text(
                    "Click to register",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
