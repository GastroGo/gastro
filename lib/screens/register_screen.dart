import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/home_screen.dart';
import 'package:gastro/values/app_theme.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_routes.dart';
import '../values/app_strings.dart';

class Register extends StatefulWidget {
  @override
  _RegsiterState createState() => _RegsiterState();
}

class _RegsiterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool _obscureText = true;
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
        title: const Text(AppStrings.register),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    setState(() => email = value.trim());
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.enterAnEmail : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.email,
                  ),
                ),
                const SizedBox(height: 6),
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
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result = await _auth
                                .registerWithEmailAndPassword(email, password);
                            if (result == null) {
                              print(AppStrings.couldNot);
                            } else {
                              print(AppStrings.registrationComplete);
                              print(result);
                              NavigationHelper.pop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Homepage(user: result)),
                              );
                            }
                          }
                        },
                  child: const Text(AppStrings.register),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InkWell(
                    onTap: () {
                      NavigationHelper.pop(context);
                    },
                    child: Text(
                      AppStrings.iHaveAnAccount,
                      style: AppTheme.bodySmall.copyWith(color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InkWell(
                    onTap: () {
                      NavigationHelper.pushNamed(AppRoutes.createRestaurant);
                    },
                    child: Text(
                      AppStrings.createRestaurant,
                      style: AppTheme.bodySmall.copyWith(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
