import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseAuthHelper();

  Future<String> createUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user!.uid; // Retorna el UID del usuario creado
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception("La contraseña es demasiado débil.");
      } else if (e.code == 'email-already-in-use') {
        throw Exception("El correo ya está registrado.");
      }
      throw Exception("Error al crear la cuenta.");
    }
  }
}
