import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/ReportsScreen.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';

FirebaseAuthHelper authHelper = FirebaseAuthHelper();

void _logout(BuildContext context) async {
  try {
    await authHelper.logOut();
    Navigator.pushReplacementNamed(context, '/');
  } catch (_) {

  }
}

void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("¿Desea cerrar sesión?"),
      content: const Text("¿Está seguro de que desea cerrar sesión?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            _logout(context);
          },
          child: const Text("Cerrar sesión"),
        ),
      ],
    ),
  );
}

Widget drawerItem(
    BuildContext context, IconData icon, String title, Widget screen) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(
      title,
      style: const TextStyle(fontSize: 16, color: Colors.white),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    },
    tileColor: Colors.blue.shade800,
    contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  );
}

Widget _drawerLogoutItem(BuildContext context) {
  return ListTile(
      leading: const Icon(Icons.exit_to_app, color: Colors.white),
      title: const Text( 'Cerrar sesión',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () => _showLogoutConfirmationDialog(context), // Solo cierra el menú
      tileColor: Colors.blue.shade800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  );
}

Widget buildDrawer(BuildContext context, dynamic usuario, Function _menuLateral,
    String tituloPantalla) {
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
                // Usar CircleAvatar para colocar fondo blanco circular alrededor de la imagen
                CircleAvatar(
                  backgroundColor: Colors.white, // Fondo blanco
                  radius: 35, // Radio del círculo
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png', // Cargar la imagen
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover, // Ajuste de la imagen al círculo
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Mostrar el título dinámico pasado como parámetro
                Text(
                  tituloPantalla,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          drawerItem(
              context, Icons.home, 'Inicio', MenuScreenAdmin(usuario: usuario)),
          drawerItem(context, Icons.people, 'Usuarios',
              UserScreenManagement(usuario: usuario)),
          drawerItem(context, Icons.directions_car, 'Vehículos',
              VehiclesScreenManagement(usuario: usuario)),
          drawerItem(context, Icons.warning_amber, 'Incidencias',
              IncidentsScreenAdmin(usuario: usuario)),
          drawerItem(context, Icons.local_parking, 'Paradas',
              StopScreenManagement(usuario: usuario)),
          drawerItem(context, Icons.location_on, 'Monitoreo',
              MonitoringScreenManagement(usuario: usuario)),
          drawerItem(context, Icons.report, 'Reportes',
              ReportsScreen(usuario: usuario)),
          const Divider(color: Colors.white),
          _drawerLogoutItem(context)
        ],
      ),
    ),
  );
}