
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';
import 'package:padillaroutea/services/data_sync/data_sync.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart';
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart' as ob;
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
  final ParadasHelper paradasHelper = ParadasHelper(RealtimeDbHelper());
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
      List<Ruta> rutasFiltradas = todasLasRutas.where((ruta) => ruta.idChofer == widget.usuario.idUsuario).toList();
      setState(() {
        rutas = rutasFiltradas;
        isLoading = false;
      });
      logAction(widget.usuario.correo, Tipo.alta, "Cargó rutas asignadas", logsHelper, _logger);
    } catch (e) {
      _logger.e("Error cargando rutas: $e");
      logAction(widget.usuario.correo, Tipo.baja, "Error cargando rutas: $e", logsHelper, _logger);
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadVehiculo() async {
    if (widget.usuario.idVehiculo != null) {
      try {
        Vehiculo? vehiculo = await vehiculosHelper.get(widget.usuario.idVehiculo!);
        setState(() {
          vehiculoAsignado = vehiculo;
        });
        logAction(widget.usuario.correo, Tipo.alta, "Cargó vehículo asignado", logsHelper, _logger);
      } catch (e) {
        _logger.e("Error cargando vehículo: $e");
        logAction(widget.usuario.correo, Tipo.baja, "Error cargando vehículo: $e", logsHelper, _logger);
      }
    }
  }

  void _menuLateralChofer(BuildContext context) {
    Navigator.pop(context);
  }

  void _showConnectionLostDialog() {
    _isDialogOpen = true;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Conexión a internet perdida"),
            content: const Text('La sincronización se restablecerá cuando la conexión se recupere.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _isDialogOpen = false;
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  Future<void> _showParadasInfo(Ruta ruta) async {
    List<Parada> todas = await paradasHelper.getAll();
    List<Parada> paradasRuta = todas.where((p) => ruta.paradas.contains(p.nombre)).toList();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Paradas de la ruta"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: paradasRuta.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              Parada p = paradasRuta[index];
              return ListTile(
                title: Text(p.nombre),
                subtitle: Text("Llega: ${p.horaLlegada}, Sale: ${p.horaSalida}"),
              );
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Cerrar"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${widget.usuario.nombre}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateralChofer, 'Panel de bienvenida'),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : rutas.isEmpty
                    ? const Center(
                        child: Text('No tienes rutas asignadas',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('El vehículo que te fue asignado es:',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_bus, color: Colors.white),
                const SizedBox(width: 10),
                Text('${vehiculoAsignado!.marca}, con el número: ${vehiculoAsignado!.numeroSerie}.',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
      margin: const EdgeInsets.symmetric(vertical: 10),
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
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ruta.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              const SizedBox(height: 5),
              Wrap(
                children: ruta.paradas
                    .map((stop) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(stop,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline, fontSize: 14, color: Colors.white70)),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
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
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: Text('Hacer ruta', style: TextStyle(color: Colors.blue.shade800)),
                  ),
                  ElevatedButton(
                    onPressed: () => _showParadasInfo(ruta),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                    child: const Text('Más información'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
