import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/screens/forgotPasswordScreen.dart'; // Pantalla de recuperación de contraseña
import 'package:padillaroutea/screens/menuScreenAdmin.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/user/RouteScreenManagementU.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  final Logger _logger = Logger();
  FirebaseAuthHelper authHelper = FirebaseAuthHelper();

  final UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());

  Future<void> _handleLogin() async {
    final userEmail = _emailController.text;
    final userPass = _passwordController.text;

    if (userEmail.isEmpty || userPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Some values are missing!!!")));
      return;
    }

    try {
      await authHelper.logIn(userEmail, userPass);
      Usuario? usuario = await usuariosHelper.getByEmail(_emailController.text);

      if (usuario != null) {
        final rolUsuario = usuario.rol;

        Widget nextScreen;
        switch (rolUsuario) {
          case Rol.chofer:
            nextScreen = RouteScreenManagementU(chofer: usuario);
            break;
          case Rol.administrativo:
            nextScreen = MonitoringScreenManagement();
            _subscribeToTopic('administrativos_y_gerentes');
            break;
          case Rol.gerente:
            nextScreen = MenuScreenAdmin();
            _subscribeToTopic('administrativos_y_gerentes');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rol no reconocido")));
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuario no encontrado")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Mover la función fuera de _handleLogin
  Future<void> _subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _logger.i('Usuario suscrito al tema: $topic');
    } catch (e) {
      _logger.e('Error al suscribir al tema: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 150,
              ),
              const SizedBox(height: 20),
              const Text(
                'Iniciar sesión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 183, 255),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.email,
                      color: Color.fromARGB(255, 0, 0, 0)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  prefixIcon: const Icon(Icons.lock,
                      color: Color.fromARGB(255, 0, 0, 0)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordScreen()),
                    );
                  },
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
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
