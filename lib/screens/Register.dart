import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/CreateRestaurant.dart';
import 'package:gastro/screens/Homepage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gastro/screens/Login.dart';

class Register extends StatefulWidget {
  @override
  _RegsiterState createState() => _RegsiterState();
}

class _RegsiterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text('Register'),
        centerTitle: true,
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
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),
              ElevatedButton(
                child: const Text('Register'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.registerWithEmailAndPassword(
                        email, password);
                    if (result == null) {
                      print('Could not sign in with those credentials');
                    } else {
                      print('Registered');
                      print(result);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Homepage(user: result)),
                      );
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
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  child: const Text(
                    "Click to login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CreateRestaurant()),
                    );
                  },
                  child: const Text(
                    "Create Restaurant",
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
