import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/RoutesScreenEdit.dart';
import 'package:padillaroutea/screens/RoutesScreenRegister.dart';
import 'package:padillaroutea/screens/RoutesScreenAssign.dart';

class RoutesScreenManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Rutas',
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gestiona todas tus rutas y asigna paradas fácilmente.',
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView(
                children: [
                  _routeCard(context, 'Ruta Rincón', ['Rincón', 'Saltillito', 'Concha'], 'Jorge'),
                  _routeCard(context, 'Ruta Rincón Noche', ['Chayote', 'Alamitos', 'El barranco'], 'Bruno'),
                  _routeCard(context, 'Ruta Cosío', ['Cosío', 'Bajío', 'Saucillo'], 'José'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoutesScreenRegister()),
          );
        },
        backgroundColor: Colors.blue.shade900,
        child: Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _routeCard(BuildContext context, String routeName, List<String> stops, String user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            routeName,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade900),
          ),
          Divider(color: Colors.blue.shade300),
          SizedBox(height: 8),
          Text('Paradas asignadas:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: stops.map((stop) {
              return Chip(
                label: Text(stop, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.blue.shade200,
              );
            }).toList(),
          ),
          SizedBox(height: 8),
          Text(
            'Usuario a cargo: $user',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(context, 'Asignar usuario', Colors.blue, Icons.person_add, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutesScreenAssign()),
                );
              }),
              _actionButton(context, 'Editar', Colors.amber, Icons.edit, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutesScreenEdit()),
                );
              }),
              _actionButton(context, 'Eliminar', Colors.red, Icons.delete, () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String text, Color color, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    child: Icon(Icons.directions_bus, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión de Rutas',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', null),
            _drawerItem(context, Icons.people, 'Usuarios', null),
            _drawerItem(context, Icons.directions_car, 'Vehículos', null),
            Divider(color: Colors.white),
            _drawerItem(context, Icons.exit_to_app, 'Cerrar sesión', null),
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
