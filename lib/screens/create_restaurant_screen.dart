import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/values/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        title: const Text(AppStrings.createRestaurant),
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
                TextFormField(
                  onChanged: (value) {
                    setState(() => name = value);
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterName : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.name,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => place = value);
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterPlace : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.place,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => street = value);
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterStreet : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.street,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => zip = int.parse(value));
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterZip : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.zip,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  onChanged: (value) {
                    setState(() => housenumber = value);
                    _checkInput();
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.pleaseEnterHousenumber : null,
                  decoration: const InputDecoration(
                    labelText: AppStrings.housenumber,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _isButtonDisabled ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      dynamic result = await _auth.createRestaurant(email,
                          password, name, place, street, zip, housenumber);
                      if (result['user'] == null) {
                        print(AppStrings.couldNot);
                      } else {
                        print(AppStrings.registrationComplete);
                        print(result);
                        String restaurantId = await _auth.getRestaurantId(result.uid);
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.setString('restaurantId', restaurantId);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Dashboard(user: result['user'], id: result['restaurantId'])),
                        );
                      }
                    }
                  },
                  child: const Text(AppStrings.createRestaurant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
