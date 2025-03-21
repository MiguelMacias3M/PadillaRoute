import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/RoutesScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenSelect.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class MenuScreenAdmin extends StatelessWidget {
  final Usuario usuario;
  final Logger _logger = Logger();
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());

  MenuScreenAdmin({required this.usuario, Key? key}) : super(key: key) {
    logAction(usuario.correo, Tipo.alta, "Acceso al menú principal", logsHelper,
        _logger);
  }

  void _menuLateral(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Menú Principal',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        centerTitle: true,
      ),
      drawer: buildDrawer(context, usuario, _menuLateral, 'Menú Principal'),
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
          padding: const EdgeInsets.all(20.0),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          children: [
            _menuItem(context, Icons.people, 'Usuarios',
                screen: UserScreenSelect(usuario: usuario)),
            _menuItem(context, Icons.directions_bus, 'Rutas',
                screen: RoutesScreenManagement(usuario: usuario)),
            _menuItem(context, Icons.location_on, 'Monitorear',
                screen: MonitoringScreenManagement(usuario: usuario)),
            _menuItem(context, Icons.directions_car, 'Vehículos',
                screen: VehiclesScreenManagement(usuario: usuario)),
            //_menuItem(context, Icons.bar_chart, 'Reportes'),
            _menuItem(context, Icons.local_parking, 'Paradas',
                screen: StopScreenManagement(usuario: usuario)),
            _menuItem(context, Icons.warning_amber, 'Incidencias',
                screen: IncidentsScreenAdmin(usuario: usuario)),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title,
      {Widget? screen}) {
    return GestureDetector(
      onTap: () {
        if (screen != null) {
          logAction(usuario.correo, Tipo.modificacion, "Accedió a $title",
              logsHelper, _logger);
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
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 60, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
