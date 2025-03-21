import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';

class MonitoringRouteScreen extends StatefulWidget {
  final Usuario usuario;

  MonitoringRouteScreen({required this.usuario});
  @override
  _MonitoringRouteScreenState createState() => _MonitoringRouteScreenState();
}

class _MonitoringRouteScreenState extends State<MonitoringRouteScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Timer? _timer;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _logAction(
        widget.usuario.correo, Tipo.alta, "Pantalla de monitoreo abierta");
    _getCurrentLocation(); // Obtener ubicación actual al iniciar
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _logger.w("Permiso de ubicación denegado");
      print("Permiso de ubicación denegado");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      print("Ubicación actual: $_currentLocation");
      _mapController?.animateCamera(CameraUpdate.newLatLng(
          _currentLocation!)); // Enfocar cámara en la ubicación actual
    });
    _logAction(widget.usuario.correo, Tipo.alta,
        "Ubicación obtenida: $_currentLocation");
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(
          _currentLocation!)); // Enfocar en la ubicación actual
    }
  }

  void _startRealTimeTracking() {
    if (_currentLocation == null) {
      _logger.w("No se puede iniciar el seguimiento sin una ubicación actual.");
      print("No se puede iniciar el seguimiento sin una ubicación actual.");
      return;
    }

    _logAction(widget.usuario.correo, Tipo.alta,
        "Seguimiento en tiempo real iniciado");

    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        // Aquí se puede simular el movimiento del vehículo
        _currentLocation = LatLng(
          _currentLocation!.latitude + 0.0001,
          _currentLocation!.longitude + 0.0001,
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
        print(
            "Nueva ubicación del vehículo: $_currentLocation"); // Mensaje a la consola
      });
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Nueva ubicación del vehículo: $_currentLocation");
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _logAction(
        widget.usuario.correo, Tipo.baja, "Pantalla de monitoreo cerrada");
    super.dispose();
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
        title: Text("Monitoreo de Vehículo en Tiempo Real"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLocation ??
                    LatLng(0, 0), // Utilizar ubicación actual
                zoom: 15,
              ),
              markers: _currentLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId("vehicle"),
                        position: _currentLocation!,
                        infoWindow: InfoWindow(title: "Vehículo en ruta"),
                      ),
                    }
                  : {},
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: _startRealTimeTracking,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            ),
            child: Text("Iniciar Seguimiento",
                style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
