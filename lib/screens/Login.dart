import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/Dashboard.dart';
import 'package:gastro/screens/Homepage.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

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
        title: Text(AppStrings.login),
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
                validator: (value) => value!.isEmpty ? AppStrings.enterAnEmail : null,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                ),
              ),
              TextFormField(
                obscureText: true,
                onChanged: (value) {
                  setState(() => password = value);
                },
                validator: (value) =>
                    value!.length < 6 ? AppStrings.pleaseEnterPassword : null,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                ),
              ),
              ElevatedButton(
                child: Text(AppStrings.login),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result =
                        await _auth.signInWithEmailAndPassword(email, password);
                    if (result == null) {
                      print(AppStrings.couldNot);
                    } else {
                      print(AppStrings.loggedIn);
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
                    NavigationHelper.pushNamed(AppRoutes.register);
                  },
                  child: Text(
                    AppStrings.doNotHaveAnAccount,
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
