import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/screens/SplashScreen.dart';
import 'package:padillaroutea/screens/forgotPasswordScreen.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/user/RouteScreenManagementU.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:padillaroutea/screens/registroDeLogs.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _isDialogOpen = false;

  final Logger _logger = Logger();
  final FirebaseAuthHelper authHelper = FirebaseAuthHelper();
  final UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      _logger.i('Usuario suscrito al tema: $topic');
      logAction(_emailController.text, Tipo.modificacion,
          "Suscripción a tema FCM: $topic", logsHelper, _logger);
    } catch (e) {
      _logger.e('Error al suscribir al tema: $e');
      logAction(_emailController.text, Tipo.baja,
          "Error al suscribir a tema: $e", logsHelper, _logger);
    }
  }

  Future<void> saveUserFCMToken(int userId) async {
    try {
      String token = await FirebaseMessaging.instance.getToken() ?? "";
      // Guardar el token FCM en la base de datos usando el UsuariosHelper
      await usuariosHelper.updateFCMToken(userId, token);
    } catch (e) {
      print("Error al obtener y guardar el FCM Token: $e");
    }
  }

  Widget _getNextScreenForRole(Rol rolUsuario, Usuario usuario) {
    switch (rolUsuario) {
      case Rol.chofer:
        return RouteScreenManagementU(usuario: usuario);
      case Rol.administrativo:
        _subscribeToTopic('administrativos_y_gerentes');
        return SplashScreenAdmin(usuario: usuario);
      case Rol.gerente:
        _subscribeToTopic('administrativos_y_gerentes');
        return SplashScreenAdmin(usuario: usuario);
    }
  }

  Future<void> _onSuccessfulLogin(Usuario usuario, String email) async {
    final rolUsuario = usuario.rol;
    await saveUserFCMToken(usuario.idUsuario); // Guarda el FCM Token
    Widget nextScreen = _getNextScreenForRole(rolUsuario, usuario);
    logAction(
        email,
        Tipo.alta,
        "Inicio de sesión exitoso - Rol: ${rolUsuario.name}",
        logsHelper,
        _logger);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
  }

  void _showErrorDialog(String messageTitle, String messageDescription) {
    _isDialogOpen = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: Text(messageTitle),
            content: Text(messageDescription),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void _handleAuthException(FirebaseAuthException e, String email) {
    switch (e.code) {
      case 'user-not-found':
        _showErrorDialog("Usuario no encontrado.",
            "No se hayó ningun usuario con esas credenciales.");
      case 'network-request-failed':
        _showErrorDialog("Sin conexión a internet.",
            "Verifica tu conexión e intentalo de nuevo.");
      case 'wrong-password':
        _showErrorDialog(
            "Credenciales invalidas.", "Email o contraseña incorrectos.");
      default:
        _showErrorDialog("Error de inicio de sesión.",
            "Ocurrió un error inesperado. Intenta nuevamente.");
    }
    logAction(
        email, Tipo.baja, "Error en inicio de sesión: $e", logsHelper, _logger);
    _isLoading = false;
  }

  void _handleEmptyFields(String userEmail) {
    _showErrorDialog(
        "Campos vacíos", "Por favor, completa todos los campos obligatorios.");
    logAction(
        userEmail,
        Tipo.baja,
        "Intento de inicio de sesión fallido (campos vacíos)",
        logsHelper,
        _logger);
    setState(() {
      _isLoading = false;
    });
  }

  void _onUsernotFound(String email) {
    _showErrorDialog("Usuario no encontrado.",
        "No se encontró ningun usuario con esas credenciales.");
    logAction(
        email,
        Tipo.baja,
        "Inicio de sesión fallido (usuario no encontrado)",
        logsHelper,
        _logger);
    _isLoading = false;
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final userEmail = _emailController.text;
    final userPass = _passwordController.text;

    if (userEmail.isEmpty || userPass.isEmpty) {
      _handleEmptyFields(userEmail);
      return;
    }

    try {
      await authHelper.logIn(userEmail, userPass);
      Usuario? usuario = await usuariosHelper.getByEmail(_emailController.text);

      if (usuario != null) {
        _onSuccessfulLogin(usuario, userEmail);
      } else {
        _onUsernotFound(userEmail);
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthException(e, userEmail);
    } catch (e) {
      _showErrorDialog("Error inesperado",
          "Ocurrió un error inesperado. Intenta nuevamente.");
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 16, 171, 255),
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4)
                  ],
                ),
              ),
              _buildTextField(
                  _emailController, 'Correo electrónico', Icons.email, false),
              const SizedBox(height: 15),
              _buildTextField(
                  _passwordController, 'Contraseña', Icons.lock, true),
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
              const SizedBox(height: 10),
              _buildLoginButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        prefixIcon: Icon(icon, color: Colors.black),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isLoading ? Colors.grey : Colors.blueAccent,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Iniciar sesión',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }
}
