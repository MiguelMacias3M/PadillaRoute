import 'package:flutter/material.dart';
import 'dart:async';
import 'menuScreenAdmin.dart';

class SplashScreenAdmin extends StatefulWidget {
  @override
  _SplashScreenAdminState createState() => _SplashScreenAdminState();
}

class _SplashScreenAdminState extends State<SplashScreenAdmin> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuScreenAdmin()),
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreenAdmin(),
  ));
}
