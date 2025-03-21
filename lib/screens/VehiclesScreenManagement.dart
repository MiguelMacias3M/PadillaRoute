import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/VehiclesScreen.dart';
import 'package:padillaroutea/screens/VehiclesScreenEdit.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class VehiclesScreenManagement extends StatefulWidget {
  final Usuario usuario;

  VehiclesScreenManagement({required this.usuario});
  @override
  _VehiclesScreenManagementState createState() =>
      _VehiclesScreenManagementState();
}

class _VehiclesScreenManagementState extends State<VehiclesScreenManagement> {
  List<Vehiculo> vehiculos = [];
  late VehiculosHelper vehiculosHelper;
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    _logAction(widget.usuario.correo, Tipo.alta, "Ingreso a consulta de vehiculos");
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
  try{
    List<Vehiculo> vehicleList = await vehiculosHelper.getAll();
    setState(() {
      vehiculos = vehicleList;
    });
  await _logAction(widget.usuario.correo, Tipo.alta, 'Cargó los vehículos');
    } catch (e) {
      _logger.e("Error al cargar vehículos: $e");
      await _logAction(widget.usuario.correo, Tipo.baja, 'Error al cargar los vehículos');
    }
  }

  Future<void> _logAction(String correo, Tipo tipo, String accion) async {
    final logEntry = Log(
      idLog: DateTime.now().millisecondsSinceEpoch,
      tipo: tipo,
      usuario: correo,
      accion: accion,
      fecha: DateTime.now().toIso8601String(),
    );

    try {
      await logsHelper.setNew(logEntry);
      _logger.i("Log registrado: $accion");
    } catch (e) {
      _logger.e("Error al registrar log: $e");
    }
  }

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
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: vehiculos.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: vehiculos.length,
                      itemBuilder: (context, index) {
                        return _vehicleCard(context, vehiculos[index]);
                      },
                    ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VehiclesScreen(usuario: widget.usuario)),
                  );
                _logAction(widget.usuario.correo, Tipo.alta, 'Registró un nuevo vehículo');
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

  Widget _vehicleCard(BuildContext context, Vehiculo vehiculo) {
    Color getStatusColor(Estatus estatus) {
      switch (estatus) {
        case Estatus.activo:
          return Colors.green;
        case Estatus.inactivo:
          return Colors.red;
        case Estatus.mantenimiento:
          return Colors.orange;
        default:
          return Colors.grey;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              vehiculo.marca,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              vehiculo.modelo,
              style: TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.circle,
                    color: getStatusColor(vehiculo.estatus), size: 14),
                SizedBox(width: 5),
                Text(
                  vehiculo.estatus.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: getStatusColor(vehiculo.estatus),
                  ),
                ),
              ],
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VehiclesScreenEdit(vehiculo: vehiculo, usuario: widget.usuario),
                    ),
                  );
                _logAction(widget.usuario.correo, Tipo.modificacion, 'Editó el vehículo ${vehiculo.marca}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Editar',
                  style: TextStyle(color: Colors.black),
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
            _drawerItem(context, Icons.home, 'Inicio',
                MenuScreenAdmin(usuario: widget.usuario)),
            _drawerItem(context, Icons.people, 'Usuarios', UserScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.directions_car, 'Vehículos', VehiclesScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', IncidentsScreenAdmin(usuario: widget.usuario)),
            _drawerItem(context, Icons.local_parking, 'Paradas', StopScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.location_on, 'Monioreo', MonitoringScreenManagement(usuario: widget.usuario)),
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
