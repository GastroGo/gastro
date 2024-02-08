import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/Homepage.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.register),
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
                validator: (value) => value!.isEmpty ? AppStrings.enterAnEmail : null,
                decoration: const InputDecoration(
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
                decoration: const InputDecoration(
                  labelText: AppStrings.password,
                ),
              ),
              ElevatedButton(
                child: const Text(AppStrings.register),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.registerWithEmailAndPassword(
                        email, password);
                    if (result == null) {
                      print(AppStrings.couldNot);
                    } else {
                      print(AppStrings.registrationComplete);
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
                    NavigationHelper.pop(context);
                  },
                  child: const Text(
                    AppStrings.iHaveAnAccount,
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () {
                    NavigationHelper.pushNamed(AppRoutes.createRestaurant);
                  },
                  child: const Text(
                    AppStrings.createRestaurant,
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
