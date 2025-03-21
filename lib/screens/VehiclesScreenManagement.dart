import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/VehiclesScreen.dart';
import 'package:padillaroutea/screens/VehiclesScreenEdit.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral

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
  
void _menuLateral(BuildContext context) {
  // Solo cerrar el Drawer (menú lateral)
  Navigator.pop(context); // Esto cierra el menú lateral
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
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Gestión de vehículos'),
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
}
