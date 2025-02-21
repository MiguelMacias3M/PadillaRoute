import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart';


class StopScreenManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de Paradas',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
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
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar parada',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _stopCard(context, 'Bajio', 'C. Arellano Randel #102, Bajio, Rincon de Romos', '14:00', '14:05', '5 min'),
                  _stopCard(context, 'Saltillito', 'C. Arellano Randel #102, Bajio, Rincon de Romos', '14:00', '14:05', '5 min'),
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
            MaterialPageRoute(builder: (context) => StopScreenManagement()),
          );
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _stopCard(BuildContext context, String stopName, String address, String arrival, String departure, String wait) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              stopName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent),
            ),
            SizedBox(height: 5),
            Text('📍 Dirección: $address', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('🕒 Hora de llegada: $arrival', style: TextStyle(fontSize: 14)),
            Text('🕑 Hora de salida: $departure', style: TextStyle(fontSize: 14)),
            Text('⏳ Tiempo de espera: $wait', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StopScreenManagement()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Editar', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
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
                    child: Icon(Icons.local_parking, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión de paradas',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin()),
            _drawerItem(context, Icons.people, 'Usuarios', UserScreenManagement()),
            _drawerItem(context, Icons.directions_car, 'Vehículos', VehiclesScreenManagement()),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', IncidentsScreenAdmin()),
             _drawerItem(context, Icons.local_parking, 'Paradas', StopScreenManagement()),
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
