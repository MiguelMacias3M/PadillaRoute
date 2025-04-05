import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';
import 'package:padillaroutea/services/data_sync/data_sync.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart'; // menú lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart'
    as ob;
import 'package:padillaroutea/main.dart';
import 'package:padillaroutea/services/objectbox_services/viajes_registro_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/viajes_helper.dart';
import 'package:padillaroutea/services/wifi_connection/wifi_controller.dart';

class RouteScreenManagementU extends StatefulWidget {
  final Usuario usuario;

  const RouteScreenManagementU({super.key, required this.usuario});

  @override
  _RouteScreenManagementUState createState() => _RouteScreenManagementUState();
}

class _RouteScreenManagementUState extends State<RouteScreenManagementU> {
  final RutasHelper rutasHelper = RutasHelper(RealtimeDbHelper());
  final VehiculosHelper vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
  final UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final ViajesRegistroHelper viajesObjHelper = ViajesRegistroHelper(objectBox);
  final ViajesHelper viajesHelper = ViajesHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());

  List<Ruta> rutas = [];
  bool isLoading = true;
  Vehiculo? vehiculoAsignado;

  final Logger _logger = Logger();

  late final DataSync _taskScheduler;

  final WifiController _wifiController = WifiController();
  bool _hasInternet = true;
  bool _isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta, "Panel de bienvenida abierto", logsHelper, _logger);
    _wifiController.connectionStream.listen((status) {
      setState(() => _hasInternet = status);
      if (!_hasInternet && !_isDialogOpen) {
        _showConnectionLostDialog();
      } else if (_hasInternet && _isDialogOpen) {
        Navigator.of(context).pop();
        _isDialogOpen = false;
      }
    });
    _loadRutas();
    _loadVehiculo();
    _taskScheduler = DataSync(viajesObjHelper, viajesHelper);
    _taskScheduler.startTimer();
  }

  @override
  void dispose() {
    _taskScheduler.stopTimer();
    _wifiController.dispose();
    super.dispose();
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
    Navigator.pop(context); // Cerrar menú lateral
  }

  void _showConnectionLostDialog() {
    _isDialogOpen = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Conexión a internet perdida"),
            content: const Text(
                'La sincronización se restablecerá cuando la conexión se recupere.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  _isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }
  // void _saveRegistro() {
  //   final registro = ob.ViajeRegistro(
  //     idRuta: 1,
  //     idVehiculo: widget.usuario.idVehiculo ?? 1,
  //     idChofer: widget.usuario.idUsuario,
  //     paradasRegistro: jsonEncode({"Uno": "Uno"}),
  //     horaInicio: DateTime.now().toIso8601String(),
  //     horaFinal: DateTime.now().toIso8601String(),
  //     tiempoTotal: DateTime.now().millisecond,
  //     totalPasajeros: 12,
  //     distanciaRecorrida: 1.00,
  //     velocidadPromedio: 1.00,
  //     coordenadas: "0.0,0.0",
  //     finalizado: true,
  //   );

  //   viajesObjHelper.saveRegistro(registro);
  // }

  // void _checkDB() {
  //   final resultado = viajesObjHelper.getAllRegistros();
  //   if (resultado.isNotEmpty) {
  //     print(resultado[0].toJson());
  //   } else {
  //     print("DB is empty");
  //   }
  // }

  // void _vaciarDB() {
  //   viajesObjHelper.deleteRegistro();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido, ${widget.usuario.nombre}',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: buildDrawer(
          context, widget.usuario, _menuLateralChofer, 'Panel de bienvenida'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : rutas.isEmpty
                    ? const Center(
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
          // ListView(
          //   children: [
          //     ElevatedButton(
          //         onPressed: _saveRegistro,
          //         style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.blue,
          //             foregroundColor: Colors.blueGrey),
          //         child: const Text("Guardar Regisgtro")),
          //     ElevatedButton(
          //         onPressed: _checkDB,
          //         style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.purple,
          //             foregroundColor: Colors.white),
          //         child: const Text("Revisar DB")),
          //                   ElevatedButton(
          //         onPressed: _checkDB,
          //         style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.red,
          //             foregroundColor: Colors.white),
          //         child: const Text("Vaciar DB"))
          //   ],
          // )
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
                children: ruta.paradas.map<Widget>((stop) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      stop,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  );
                }).toList(),
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
                        ),
                      ),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: Text('Hacer ruta',
                      style: TextStyle(color: Colors.blue.shade800)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
