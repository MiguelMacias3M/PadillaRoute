import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/screens/forgotPasswordScreen.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
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
  final FirebaseAuthHelper authHelper = FirebaseAuthHelper();
  final UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());

  Future<void> _handleLogin() async {
    final userEmail = _emailController.text;
    final userPass = _passwordController.text;

    if (userEmail.isEmpty || userPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Some values are missing!!!")));
      _logAction(userEmail, Tipo.baja,
          "Intento de inicio de sesión fallido (campos vacíos)");
      return;
    }

    try {
      await authHelper.logIn(userEmail, userPass);
      Usuario? usuario = await usuariosHelper.getByEmail(userEmail);

      if (usuario != null) {
        final rolUsuario = usuario.rol;
        Widget nextScreen;

        switch (rolUsuario) {
          case Rol.chofer:
            nextScreen = RouteScreenManagementU(chofer: usuario);
            break;
          case Rol.administrativo:
            nextScreen = MenuScreenAdmin(usuario: usuario);

            _subscribeToTopic('administrativos_y_gerentes');
            break;
          case Rol.gerente:
            nextScreen = MenuScreenAdmin(usuario: usuario);
            _subscribeToTopic('administrativos_y_gerentes');
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Rol no reconocido")));
            _logAction(userEmail, Tipo.baja,
                "Inicio de sesión fallido (rol no reconocido)");
            return;
        }

        _logAction(userEmail, Tipo.alta,
            "Inicio de sesión exitoso - Rol: ${rolUsuario.name}");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuario no encontrado")));
        _logAction(userEmail, Tipo.baja,
            "Inicio de sesión fallido (usuario no encontrado)");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      _logger.e("Error en inicio de sesión: $e");
      _logAction(userEmail, Tipo.baja, "Error en inicio de sesión: $e");
    }
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _logger.i('Usuario suscrito al tema: $topic');
      _logAction(_emailController.text, Tipo.modifiacion,
          "Suscripción a tema FCM: $topic");
    } catch (e) {
      _logger.e('Error al suscribir al tema: $e');
      _logAction(
          _emailController.text, Tipo.baja, "Error al suscribir a tema: $e");
    }
  }

  Future<void> _logAction(String email, Tipo tipo, String accion) async {
    final logEntry = Log(
      idLog: DateTime.now().millisecondsSinceEpoch,
      tipo: tipo,
      usuario: email,
      accion: accion,
      fecha: DateTime.now().toIso8601String(),
    );

    try {
      await logsHelper.setNew(logEntry);
      _logger.i("Log registrado: $accion");
    } catch (e) {
      _logger.e("Error al registrar log: $e");
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
