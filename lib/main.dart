import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gastro/screens/Dashboard.dart';
import 'package:gastro/screens/Homepage.dart';
import 'firebase_options.dart';
import 'package:gastro/screens/Login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(App());
}

class App extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> _getUserData(User? user) async {
    if (user == null) {
      return false;
    } else {
      DatabaseReference ref = FirebaseDatabase.instance.ref("Restaurants");
      DatabaseEvent event =
          await ref.orderByChild("daten/uid").equalTo(user.uid).once();
      DataSnapshot snapshot = event.snapshot;
      return snapshot.value != null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Gastro Go!',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: Login(), // Set the Login widget as the home screen
            );
          } else {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Gastro Go!',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
                useMaterial3: true,
              ),
              home: FutureBuilder(
                future: _getUserData(user),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return snapshot.data
                          ? Dashboard(user: user)
                          : Homepage(user: user);
                    }
                  }
                },
              ),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}
