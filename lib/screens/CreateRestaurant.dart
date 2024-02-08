import 'package:flutter/material.dart';
import 'package:gastro/firebase/AuthService.dart';

import '../utils/helpers/navigation_helper.dart';
import '../values/app_strings.dart';
import 'Dashboard.dart';
import 'Login.dart';

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
                    setState(() => email = value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? AppStrings.enterAnEmail : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.email,
                  ),
                ),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    setState(() => password = value);
                  },
                  validator: (value) => value!.length < 6
                      ? AppStrings.pleaseEnterPassword
                      : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.password,
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() => name = value);
                  },
                  validator: (value) => value!.isEmpty ? AppStrings.pleaseEnterName : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.name,
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    setState(() => place = value);
                  },
                  validator: (value) => value!.isEmpty ? AppStrings.pleaseEnterPlace : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.place,
                  ),
                ),
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
                TextFormField(
                  onChanged: (value) {
                    setState(() => zip = int.parse(value));
                  },
                  validator: (value) => value!.isEmpty ? AppStrings.pleaseEnterZip : null,
                  decoration: InputDecoration(
                    labelText: AppStrings.zip,
                  ),
                ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: InkWell(
                    onTap: () {
                      NavigationHelper.popUntil(context, (AppRoutes.login) => false);
                    },
                    child: Text(
                      AppStrings.iHaveAnAccount,
                      style: TextStyle(fontSize: 18),
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
