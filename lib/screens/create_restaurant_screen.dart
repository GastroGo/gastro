import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/values/app_routes.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_strings.dart';
import 'dasboard_screen.dart';
import 'login_screen.dart';

class CreateRestaurant extends StatefulWidget {
  const CreateRestaurant({super.key});

  @override
  _CreateRestaurant createState() => _CreateRestaurant();
}

class _CreateRestaurant extends State<CreateRestaurant> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';
  String place = '';
  int zip = 0;
  String street = '';
  String housenumber = '';

  bool _obscureText = true;

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.createRestaurant),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // Add this
            child: Column(
              children: <Widget>[
                TextFormField(
                  onChanged: (value) {
                    setState(() => email = value.trim());
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
                TextFormField(
                  onChanged: (value) {
                    setState(() => name = value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterName : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.name,
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => place = value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterPlace : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.place,
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => street = value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterStreet : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.street,
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => zip = int.parse(value));
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterZip : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.zip,
                  ),
                ),
                SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => housenumber = value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterHousenumber : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.housenumber,
                  ),
                ),
                SizedBox(height: 6),
                ElevatedButton(
                  child: Text(AppStrings.createRestaurant),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.createRestaurant(email,
                          password, name, place, street, zip, housenumber);
                      if (result == null) {
                        print(AppStrings.couldNot);
                      } else {
                        print(AppStrings.registrationComplete);
                        print(result);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Dashboard(user: result)),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
