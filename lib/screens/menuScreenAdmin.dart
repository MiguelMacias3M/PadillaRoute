import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/RoutesScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenRegister.dart';
import 'package:padillaroutea/screens/UserScreenSelect.dart';
import 'package:padillaroutea/screens/VehiclesScreen.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';

class MenuScreenAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Oculta la flecha de retroceso
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Menú Principal',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: true,
       
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: GridView.count(
          crossAxisCount: 2,
          padding: EdgeInsets.all(20.0),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _menuItem(context, Icons.people, 'Usuarios', screen: UserScreenSelect()),
            _menuItem(context, Icons.directions_bus, 'Rutas', screen: RoutesScreenManagement()),
            _menuItem(context, Icons.location_on, 'Monitorear', screen: MonitoringScreenManagement()),
            _menuItem(context, Icons.directions_car, 'Vehículos', screen: VehiclesScreenManagement()),
            _menuItem(context, Icons.bar_chart, 'Reportes'),
            _menuItem(context, Icons.local_parking, 'Paradas', screen: StopScreenManagement()),
           _menuItem(context, Icons.warning_amber, 'Inciderncias', screen: IncidentsScreenAdmin()),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, {Widget? screen}) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title en desarrollo...')),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.blueAccent),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
