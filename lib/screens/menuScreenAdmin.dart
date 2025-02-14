import 'package:flutter/material.dart';

class MenuScreenAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menú Principal',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15, top: 10),
            child: Image.asset(
              'assets/logoU.png', // Asegúrate de tener el logo en la carpeta assets
              height: 60,
            ),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20.0),
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          _menuItem(context, Icons.people, 'Usuarios'),
          _menuItem(context, Icons.directions_bus, 'Rutas'),
          _menuItem(context, Icons.location_on, 'Monitorear'),
          _menuItem(context, Icons.directions_car, 'Vehículos'),
          _menuItem(context, Icons.bar_chart, 'Reportes'),
          _menuItem(context, Icons.local_parking, 'Paradas'),
          _menuItem(context, Icons.warning, 'Incidencias'),
        ],
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title seleccionado')));
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.black),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
