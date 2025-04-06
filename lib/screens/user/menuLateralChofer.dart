import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/user/RouteScreenManagementU.dart';
import 'package:padillaroutea/screens/user/SupportScreenUser.dart';
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

Widget _drawerItem(BuildContext context, IconData icon, String title, Widget screen) {
  return ListTile(
    leading: Icon(icon, color: Colors.white),
    title: Text(title,
        style: const TextStyle(fontSize: 16, color: Colors.white)),
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screen))
  );
}

Widget _drawerLogoutItem(BuildContext context) {
  return ListTile(
      leading: const Icon(Icons.logout, color: Colors.white),
      title: const Text("Salir",
          style: TextStyle(fontSize: 16, color: Colors.white)),
      onTap: () => _showLogoutConfirmationDialog(context));
}

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
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 35,
                  child: Icon(Icons.person, color: Colors.blue, size: 40),
                ),
                const SizedBox(height: 10),
                Text(
                  usuario.nombre,
                  style: const TextStyle(
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
          const Spacer(),
          const Divider(color: Colors.white),
          _drawerLogoutItem(context)
        ],
      ),
    ),
  );
}


