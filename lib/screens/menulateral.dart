import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';

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
                SizedBox(height: 10),
                // Mostrar el título dinámico pasado como parámetro
                Text(
                  tituloPantalla,
                  style: TextStyle(
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
          const Divider(color: Colors.white),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: Colors.white),
            title: Text(
              'Cerrar sesión',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            onTap: () => _menuLateral(context), // Solo cierra el menú
            tileColor: Colors.blue.shade800,
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          ),
        ],
      ),
    ),
  );
}

Widget drawerItem(
    BuildContext context, IconData icon, String title, Widget screen) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(
      title,
      style: TextStyle(fontSize: 16, color: Colors.white),
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen),
      );
    },
    tileColor: Colors.blue.shade800,
    contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
  );
}
