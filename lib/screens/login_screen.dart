import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/dasboard_screen.dart';
import 'package:gastro/screens/home_screen.dart';
import 'package:gastro/values/app_theme.dart';

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
  bool _obscureText = true;
  bool _isLoading = false;
  bool _isButtonDisabled = true;

  void _checkInput() {
    if (email.isNotEmpty && password.isNotEmpty) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
                  setState(() => email = value.trim());
                  _checkInput();
                },
                validator: (value) =>
                    value!.isEmpty ? AppStrings.enterAnEmail : null,
                decoration: InputDecoration(
                  labelText: AppStrings.email,
                ),
              ),
              SizedBox(height: 6),
              TextFormField(
                obscureText: _obscureText,
                onChanged: (value) {
                  setState(() => password = value);
                  _checkInput();
                },
                validator: (value) =>
                    value!.length < 6 ? AppStrings.pleaseEnterPassword : null,
                decoration: InputDecoration(
                  labelText: AppStrings.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : FilledButton(
                      child: Text(AppStrings.login),
                      onPressed: _isButtonDisabled ? null : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });
                          dynamic result = await _auth
                              .signInWithEmailAndPassword(email, password);
                          if (result == null) {
                            setState(() {
                              _isLoading = false; // Setzen Sie _isLoading auf false, wenn der Anmeldevorgang abgeschlossen ist
                            });
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
                                .then((DatabaseEvent event) async {
                              DataSnapshot snapshot = event.snapshot;

                              if (snapshot.value != null) {
                                String restaurantId = await _auth.getRestaurantId(result.uid);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Dashboard(user: result, id: restaurantId)),
                                );
                              } else {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Homepage(user: result)),
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
                    style: AppTheme.bodySmall.copyWith(color: Colors.black),
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
