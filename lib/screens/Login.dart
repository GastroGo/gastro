import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/Homepage.dart';

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
                validator: (value) => value!.length < 6 ? 'Enter a password 6+ chars long' : null,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              ElevatedButton(
                child: Text('Login'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      print('Could not sign in with those credentials');
                    } else {
                      print('Signed in');
                      print(result);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Homepage(user: result)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}