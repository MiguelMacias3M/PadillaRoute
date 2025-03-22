import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/user/RouteScreenManagementU.dart';
import 'package:padillaroutea/screens/user/SupportScreenUser.dart';

Widget buildDrawer(BuildContext context, dynamic usuario,
    Function _menuLateralChofer, String tituloPantalla) {
  return Drawer(
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                SizedBox(height: 10),
                Text(
                  usuario.nombre,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          _drawerItem(context, Icons.home, 'Inicio',
              RouteScreenManagementU(usuario: usuario)),
          _drawerItem(context, Icons.support_agent, 'Soporte',
              SupportScreenUser(usuario: usuario)),
          Spacer(),
        ],
      ),
    ),
  );
}

Widget _drawerItem(
    BuildContext context, IconData icon, String title, Widget screen) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
    onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => screen)),
  );
}
