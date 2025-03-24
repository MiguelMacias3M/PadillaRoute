import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class RouteScreenManagementU extends StatefulWidget {
  final Usuario usuario;

  RouteScreenManagementU({required this.usuario});

  @override
  _RouteScreenManagementUState createState() => _RouteScreenManagementUState();
}

class _RouteScreenManagementUState extends State<RouteScreenManagementU> {
  final RutasHelper rutasHelper = RutasHelper(RealtimeDbHelper());
  final VehiculosHelper vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
  List<Ruta> rutas = [];
  bool isLoading = true;
  Vehiculo? vehiculoAsignado;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta, "Panel de bienvenida abierto",
        logsHelper, _logger);
    _loadRutas();
    _loadVehiculo();
  }

  Future<void> _loadRutas() async {
    try {
      List<Ruta> todasLasRutas = await rutasHelper.getAll();
      List<Ruta> rutasFiltradas = todasLasRutas
          .where((ruta) => ruta.idChofer == widget.usuario.idUsuario)
          .toList();

      setState(() {
        rutas = rutasFiltradas;
        isLoading = false;
      });
      logAction(widget.usuario.correo, Tipo.alta, "Cargó rutas asignadas",
          logsHelper, _logger);
    } catch (e) {
      print("Error cargando rutas: $e");
      _logger.e("Error cargando rutas: $e");
      logAction(widget.usuario.correo, Tipo.baja, "Error cargando rutas: $e",
          logsHelper, _logger);

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadVehiculo() async {
    if (widget.usuario.idVehiculo != null) {
      try {
        Vehiculo? vehiculo =
            await vehiculosHelper.get(widget.usuario.idVehiculo!);
        setState(() {
          vehiculoAsignado = vehiculo;
        });
        logAction(widget.usuario.correo, Tipo.alta, "Cargó vehículo asignado",
            logsHelper, _logger);
      } catch (e) {
        print("Error cargando vehículo: $e");
        _logger.e("Error cargando vehículo: $e");
        logAction(widget.usuario.correo, Tipo.baja,
            "Error cargando vehículo: $e", logsHelper, _logger);
      }
    }
  }

  void _menuLateralChofer(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido, ${widget.usuario.nombre}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: buildDrawer(
          context, widget.usuario, _menuLateralChofer, 'Panel de bienvenida'),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : rutas.isEmpty
                    ? Center(
                        child: Text(
                          'No tienes rutas asignadas',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: rutas.length,
                        itemBuilder: (context, index) {
                          return _routeCard(context, rutas[index]);
                        },
                      ),
          ),
          if (vehiculoAsignado != null) _floatingVehicleInfo(),
        ],
      ),
    );
  }

  Widget _floatingVehicleInfo() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'El vehículo que te fue asignado es:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  '${vehiculoAsignado!.marca} - ${vehiculoAsignado!.modelo} - ${vehiculoAsignado!.placa}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Ruta ruta) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                    color: Colors.white),
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
                                fontSize: 14,
                                color: Colors.white70),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    logAction(widget.usuario.correo, Tipo.alta,
                        "Inició ruta: ${ruta.nombre}", logsHelper, _logger);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RouteScreenU(
                                ruta: ruta,
                                usuario: widget.usuario,
                              )),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text(
                    'Hacer ruta',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
