import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenRegister.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
//Commit de prueba
class UserScreenSelect extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Usuarios',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15, top: 10),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al apartado de usuarios, ¿qué te gustaría hacer hoy?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  _optionButton(context, 'Dar de alta usuarios', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserScreenRegister()),
                    );
                  }),
                  _optionButton(context, 'Gestión de usuarios', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserScreenManagement()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(BuildContext context, String title, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          side: BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Administrador',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'admin@empresa.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
             _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin()),
            _drawerItem(context, Icons.people, 'Usuarios', UserScreenManagement()),
            _drawerItem(context, Icons.directions_car, 'Vehículos', VehiclesScreenManagement()),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', IncidentsScreenAdmin()),
            _drawerItem(context, Icons.local_parking, 'Paradas', StopScreenManagement()),
            _drawerItem(context, Icons.location_on, 'Monioreo', MonitoringScreenManagement()),
            Divider(color: Colors.white),
            _drawerItem(context, Icons.exit_to_app, 'Cerrar sesión', LoginScreen()),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      tileColor: Colors.blue.shade800,
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }
}