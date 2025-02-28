import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MonitoringRouteSceen.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';

class MonitoringScreenManagement extends StatefulWidget {
  @override
  _MonitoringScreenManagementState createState() =>
      _MonitoringScreenManagementState();
}

class _MonitoringScreenManagementState extends State<MonitoringScreenManagement> {
  FirebaseAuthHelper authHelper = FirebaseAuthHelper();
  RutasHelper rutasHelper = RutasHelper(RealtimeDbHelper());
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());

  List<Ruta> rutas = [];
  Map<int, String> usuariosMap = {}; // idUsuario -> Nombre del usuario

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Ruta> fetchedRutas = await rutasHelper.getAll();
      List<Usuario> fetchedUsuarios = await usuariosHelper.getAll();

      // Mapeamos los usuarios para acceder rápido a su nombre por ID
      Map<int, String> usuariosMapTemp = {
        for (var usuario in fetchedUsuarios) usuario.idUsuario: usuario.nombre
      };

      setState(() {
        rutas = fetchedRutas;
        usuariosMap = usuariosMapTemp;
      });
    } catch (e) {
      print("Error cargando datos: $e");
    }
  }

  void _handleLogout(BuildContext context) async {
    await authHelper.logOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monitoreo',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al apartado de monitoreo, aquí puedes monitorear tus rutas',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: rutas.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: rutas.length,
                      itemBuilder: (context, index) {
                        return _routeCard(context, rutas[index]);
                      },
                    ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MonitoringRouteScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: Text(
                  'Monitorear todas las rutas',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Ruta ruta) {
    String usuarioNombre = usuariosMap[ruta.idChofer] ?? "Desconocido";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ruta.nombre,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 5),
            Wrap(
              children: ruta.paradas
                  .map<Widget>((stop) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          stop,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 14),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 5),
            Text(
              'Usuario a cargo: $usuarioNombre',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MonitoringRouteScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Monitorear',
                  style: TextStyle(color: Colors.white),
                ),
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
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.location_on, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Monitoreo',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin()),
            _drawerItem(context, Icons.people, 'Usuarios', UserScreenManagement()),
            _drawerItem(context, Icons.directions_car, 'Vehículos', VehiclesScreenManagement()),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', IncidentsScreenAdmin()),
            _drawerItem(context, Icons.local_parking, 'Paradas', StopScreenManagement()),
            _drawerItem(context, Icons.location_on, 'Monitoreo', MonitoringScreenManagement()),
            const Divider(color: Colors.white),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.white),
              title: Text(
                'Cerrar sesión',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              onTap: () => _handleLogout(context),
              tileColor: Colors.blue.shade800,
              contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget screen) {
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
}
