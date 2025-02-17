import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  // Método para enviar la solicitud de recuperación
  Future<void> _sendPasswordResetEmail(BuildContext context) async {
    try {
      final email = _emailController.text.trim();
      
      if (email.isEmpty) {
        // Mostrar un mensaje si no se ingresa un correo
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Por favor, ingresa tu correo')));
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      // Si todo va bien, mostrar un mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Se ha enviado un correo de recuperación a $email')));
      
      // Regresar a la pantalla de login después de enviar el correo
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error desconocido';
      if (e.code == 'user-not-found') {
        errorMessage = 'No hay un usuario registrado con ese correo.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El correo electrónico ingresado no es válido.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Contraseña'),
        backgroundColor: Colors.blue,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ingresa tu correo electrónico para recibir instrucciones de recuperación.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _sendPasswordResetEmail(context), // Llamar al método para enviar el correo
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Enviar Instrucciones',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
