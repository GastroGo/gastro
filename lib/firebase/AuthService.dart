import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user == null) {
        throw Exception('Failed to sign in.');
      }
      return user;
    } catch (e) {
      print(e.toString());
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found') {
          throw Exception('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          throw Exception('The password provided is wrong.');
        } else if (e.code == 'account-exists-with-different-credential') {
          throw Exception('An account already exists with a different credential.');
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

      await user?.updateDisplayName('user');  // Ändert Display Name zu 'user'

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

  Future<Map<String, dynamic>> createRestaurant(String email, String password, String name,
      String place, String street, int zip, String housenumber) async {
    try {
      // Erstelle einen neuen Benutzer
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await user?.updateDisplayName('restaurant');  // Ändert Display Name zu 'restaurant'

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

      return {'user': user, 'restaurantId': ref.key};
    } catch (e) {
      print(e.toString());
      if (e is FirebaseAuthException) {
        if (e.code == 'weak-password') {
          print('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      }
      return {'user': null, 'restaurantId': null};
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

  Future<String> getRestaurantId(String uid) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("Restaurants");
    String restaurantId = '';

    try {
      DatabaseEvent event = await ref.orderByChild("daten/uid").equalTo(uid).once();
      DataSnapshot snapshot = event.snapshot;

      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, values) {
        restaurantId = key;
      });
    } catch (error) {
      print('Error fetching restaurant ID: $error');
    }

    return restaurantId;
  }
}
