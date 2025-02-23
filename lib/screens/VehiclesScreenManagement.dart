import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenSelect.dart';
import 'package:padillaroutea/screens/VehiclesScreen.dart';
import 'package:padillaroutea/screens/VehiclesScreenEdit.dart';
import 'package:padillaroutea/screens/loginscreen.dart';

class VehiclesScreenManagement extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de vehículos',
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
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.85,
                ),
                itemCount: 6, // Número de vehículos de ejemplo
                itemBuilder: (context, index) {
                  return _vehicleCard(context);
                },
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehiclesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Registrar vehículo',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('#101', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Toyota', style: TextStyle(fontSize: 16, color: Colors.blueAccent)),
            Text('Hilux 2016', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehiclesScreenEdit()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Editar', style: TextStyle(color: Colors.black)),
              ),
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
                    child: Icon(Icons.directions_car, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión de Vehículos',
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
