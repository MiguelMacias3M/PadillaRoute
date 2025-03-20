import 'package:flutter/material.dart';
import 'dart:async';
import 'menuScreenAdmin.dart';
import 'MonitoringScreenManagement.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';

class SplashScreenAdmin extends StatefulWidget {
  final Usuario usuario;

  SplashScreenAdmin({required this.usuario});

  @override
  _SplashScreenAdminState createState() => _SplashScreenAdminState();
}

class _SplashScreenAdminState extends State<SplashScreenAdmin> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Widget nextScreen;

      // Decidir a qué pantalla ir dependiendo del rol del usuario
      if (widget.usuario.rol == Rol.administrativo) {
        nextScreen = MonitoringScreenManagement(usuario: widget.usuario);
      }else {
        nextScreen = MenuScreenAdmin(usuario: widget.usuario); // Pantalla por defecto
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Asegúrate de tener esta imagen en la carpeta assets
              height: 200,
            ),
            SizedBox(height: 20),
            Text(
              'Bienvenido a PadillaRoute',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 183, 234),
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}

