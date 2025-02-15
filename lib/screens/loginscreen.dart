import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:padillaroutea/screens/forgotPasswordScreen.dart'; // Pantalla de recuperación de contraseña
import 'package:padillaroutea/screens/SplashScreen.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart'; 

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Función para iniciar sesión
  Future<void> _login() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Si el login es exitoso, navega al menú
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuScreenAdmin()),
      );
    } on FirebaseAuthException catch (e) {
      // Si hay un error, muestra un mensaje
      String errorMessage = 'Error desconocido';
      if (e.code == 'user-not-found') {
        errorMessage = 'No se encontró un usuario con este correo electrónico.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'La contraseña es incorrecta.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Asegúrate de tener esta imagen en la carpeta assets
                height: 150,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.email, color: const Color.fromARGB(255, 0, 0, 0)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: Icon(Icons.lock, color: const Color.fromARGB(255, 0, 0, 0)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _login, // Llama a la función _login
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
