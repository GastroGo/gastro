import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return user;
    } catch (e) {
      print(e.toString());
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          print('Wrong password provided for that user.');
        }
      }
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await user?.updateDisplayName('user');

      return user;
    } catch (e) {
      print(e.toString());
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      }
      return null;
    }
  }

  Future createRestaurant(String email, String password, String name,
      String place, String street, int zip, String housenumber) async {
    try {
      // Erstelle einen neuen Benutzer
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await user?.updateDisplayName('restaurant');

      // Erstelle einen neuen Eintrag in der Firebase-Datenbank
      DatabaseReference ref =
          FirebaseDatabase.instance.ref("Restaurants").push();
      await ref.set({
        'daten': {
          'name': name,
          'ort': place,
          'strasse': street,
          'plz': zip,
          'hausnr': housenumber,
          'uid': user?.uid,
          'speisekarte': false
        },
        'speisekarte': {},
        'tische': {}
      });

      return user;
    } catch (e) {
      print(e.toString());
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      }
      return null;
    }
  }

  signOut() {
    User? user = _auth.currentUser;
    if (user != null) {
      _auth.signOut();
    }
  }

  getUid() {
    User? user = _auth.currentUser;
    if (user != null) {
      return user.uid;
    }
  }
}
