import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuthHelper();

  Future<void> createUser(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        throw Exception("The account already exists for that email.");
      }
    } catch (e) {
      throw Exception("An error occurred while creating the account.");
    }
  }

  Future<void> logIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for that user.');
      }
    } catch (e) {
      throw Exception("An error occurred while trying to log in.");
    }
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception("An error occurred while trying to log out.");
    }
  }
}
