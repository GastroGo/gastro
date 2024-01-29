import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gastro/firebase/AuthService.dart';
import 'package:gastro/screens/Homepage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Dashboard.dart';
import 'Login.dart';
import 'Register.dart';

class CreateRestaurant extends StatefulWidget {
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
        title: Text('Create Restaurant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Form(
          key: _formKey,
    child: SingleChildScrollView(  // Add this
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
              TextFormField(
                onChanged: (value) {
                  setState(() => name = value);
                },
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                decoration: InputDecoration(
                  labelText: 'Restaurant Name',
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() => place = value);
                },
                validator: (value) => value!.isEmpty ? 'Enter a place' : null,
                decoration: InputDecoration(
                  labelText: 'Place',
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() => street = value);
                },
                validator: (value) => value!.isEmpty ? 'Enter a street' : null,
                decoration: InputDecoration(
                  labelText: 'Street',
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() => zip = int.parse(value));
                },
                validator: (value) => value!.isEmpty ? 'Enter a zip' : null,
                decoration: InputDecoration(
                  labelText: 'Zip',
                ),
              ),
              TextFormField(
                onChanged: (value) {
                  setState(() => housenumber = value);
                },
                validator: (value) => value!.isEmpty ? 'Enter a housenumber' : null,
                decoration: InputDecoration(
                  labelText: 'Housenumber',
                ),
              ),
              ElevatedButton(
                child: Text('Create Restaurant'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    dynamic result = await _auth.createRestaurant(email, password, name, place, street, zip, housenumber);
                    if (result == null) {
                      print('Could not sign in with those credentials');
                    } else {
                      print('Restaurant created');
                      print(result);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Dashboard(user: result)),
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
                      MaterialPageRoute(builder: (context) => Register()),
                    );
                  },
                  child: Text("Click to register", style: TextStyle(fontSize: 18),),
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