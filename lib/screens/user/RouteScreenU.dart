// 📦 IMPORTS
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart' as ob;
import 'package:padillaroutea/models/realtimeDB_models/viaje_registro.dart' as rt;
import 'package:padillaroutea/screens/user/IncidentsScreenRegister.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart';
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/services/fcm_service.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/viajes_helper.dart';
import 'package:padillaroutea/services/connectors/objectbox_connector.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:padillaroutea/main.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/data_sync/data_sync.dart';
import 'package:padillaroutea/services/objectbox_services/viajes_registro_helper.dart';

class RouteScreenU extends StatefulWidget {
  final Ruta ruta;
  final Usuario usuario;

  RouteScreenU({required this.ruta, required this.usuario});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  LatLng? _currentPosition;
  DateTime? _startTime;
  DateTime? _endTime;
  final Completer<GoogleMapController> _controller = Completer();
  final List<Map<String, dynamic>> _stopRecords = [];
  final Set<Marker> _markers = {};
  double _totalDistance = 0.0;
  double _averageSpeed = 0.0;

  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();
  final UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final ViajesHelper viajesHelper = ViajesHelper(RealtimeDbHelper());
  final ViajesRegistroHelper viajesObjHelper = ViajesRegistroHelper(objectBox);
  final ParadasHelper _paradasHelper = ParadasHelper(RealtimeDbHelper());

  List<Parada> _paradas = [];
  late final DataSync _taskScheduler;

  @override
  void initState() {
    super.initState();
    _taskScheduler = DataSync(viajesObjHelper, viajesHelper);
    _taskScheduler.startTimer();
    _checkLocationPermissions();
  }

  @override
  void dispose() {
    _taskScheduler.stopTimer();
    super.dispose();
  }

  Future<void> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
      _markers.add(Marker(
        markerId: const MarkerId("ubicacion_actual"),
        position: _currentPosition!,
        infoWindow: const InfoWindow(title: "Ubicación actual"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ));
      await _fetchParadas();
      _mostrarParadasEnMapa();
    } catch (e) {
      print("Error obteniendo ubicación: $e");
    }
  }

  Future<void> _fetchParadas() async {
    List<Parada> todas = await _paradasHelper.getAll();
    setState(() {
      _paradas = todas.where((p) => widget.ruta.paradas.contains(p.nombre)).toList();
    });
  }

  void _mostrarParadasEnMapa() {
    for (int i = 0; i < _paradas.length; i++) {
      final parada = _paradas[i];
      final parts = parada.coordenadas.split(',');
      final lat = double.tryParse(parts[0]);
      final lng = double.tryParse(parts[1]);
      if (lat != null && lng != null) {
        final latLng = LatLng(lat, lng);
        _markers.add(Marker(
          markerId: MarkerId("parada_$i"),
          position: latLng,
          infoWindow: InfoWindow(title: "Parada ${i + 1}", snippet: parada.nombre),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ));
      }
    }
    setState(() {});
  }

  Future<void> _startNavigation() async {
    if (_currentPosition == null || _paradas.isEmpty) return;

    setState(() {
      _startTime = DateTime.now();
      _stopRecords.clear();
      _endTime = null;
    });

    final origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
    final destino = _paradas.last.coordenadas;
    final waypoints = _paradas.sublist(0, _paradas.length - 1).map((p) => p.coordenadas).join('|');

    final uri = Uri.parse("https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destino&travelmode=driving&waypoints=$waypoints");

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

    Future<void> _registerStop() async {
    if (_currentPosition == null) return;

    final DateTime arrivalTime = DateTime.now();
    TextEditingController passengersController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Registrar Parada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Ubicación: $_currentPosition"),
              TextField(
                controller: passengersController,
                decoration: const InputDecoration(labelText: "Cantidad de pasajeros"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
            TextButton(
              onPressed: () {
                int passengers = int.tryParse(passengersController.text) ?? 0;
                DateTime departureTime = DateTime.now();

                _stopRecords.add({
                  "arrivalTime": arrivalTime.toIso8601String(),
                  "departureTime": departureTime.toIso8601String(),
                  "location": {
                    "lat": _currentPosition!.latitude,
                    "lng": _currentPosition!.longitude,
                  },
                  "passengers": passengers,
                });

                _markers.add(Marker(
                  markerId: MarkerId("stop_\${_stopRecords.length}"),
                  position: _currentPosition!,
                  infoWindow: InfoWindow(
                    title: "Parada \${_stopRecords.length}",
                    snippet: "Pasajeros: \$passengers",
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                ));

                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Guardar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IncidentsScreenRegister(
                      usuario: widget.usuario,
                      ruta: widget.ruta,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Incidencia", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
  Future<void> _sendNotification(String message) async {
    try {
      final accessToken = await getAccessToken();
      await sendFCMMessage("Actualización de Ruta", message, "administrativos_y_gerentes", accessToken);
    } catch (e) {
      print("Error al enviar notificación: $e");
    }
  }

  Future<void> _endNavigation() async {
    if (_startTime == null) return;

    _endTime = DateTime.now();
    _sendNotification("La ruta ${widget.ruta.nombre} ha finalizado.");

    final tiempoTotal = _endTime!.difference(_startTime!).inMinutes;

    final registroRealtime = rt.ViajeRegistro(
      idRegistro: DateTime.now().millisecondsSinceEpoch,
      idRuta: widget.ruta.idRuta,
      idVehiculo: widget.usuario.idVehiculo ?? 1,
      idUsuario: widget.usuario.idUsuario,
      paradasRegistro: {
        for (int i = 0; i < _stopRecords.length; i++) i.toString(): _stopRecords[i]
      },
      horaInicio: _startTime!.toIso8601String(),
      horaFinal: _endTime!.toIso8601String(),
      tiempoTotal: tiempoTotal,
      totalPasajeros: _stopRecords.fold(0, (sum, stop) => sum + (stop["passengers"] as int)),
      distanciaRecorrida: _totalDistance.toInt(),
      velocidadPromedio: _averageSpeed.toInt(),
      coordenadas: "-",
    );

    await viajesHelper.setNew(registroRealtime);

    final objectboxRegistro = ob.ViajeRegistro(
      idRuta: widget.ruta.idRuta,
      idVehiculo: widget.usuario.idVehiculo ?? 1,
      idChofer: widget.usuario.idUsuario,
      paradasRegistro: jsonEncode(registroRealtime.paradasRegistro),
      horaInicio: _startTime!.toIso8601String(),
      horaFinal: _endTime!.toIso8601String(),
      tiempoTotal: tiempoTotal,
      totalPasajeros: registroRealtime.totalPasajeros,
      distanciaRecorrida: _totalDistance,
      velocidadPromedio: _averageSpeed,
      coordenadas: "-",
      finalizado: true,
    );

    objectBox.store.box<ob.ViajeRegistro>().put(objectboxRegistro);
    _showSummary(tiempoTotal);
  }

  void _showSummary(int tiempoTotal) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("✨ Felicidades, has terminado el viaje", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Divider(),
              Text("Inicio: $_startTime"),
              Text("Fin: $_endTime"),
              Text("Duración: $tiempoTotal min"),
              Text("Paradas realizadas: ${_stopRecords.length}"),
              for (int i = 0; i < _stopRecords.length; i++)
                Text("Parada ${i + 1}: Pasajeros: ${_stopRecords[i]["passengers"]}, Llegada: ${_stopRecords[i]["arrivalTime"]}, Salida: ${_stopRecords[i]["departureTime"]}"),
              Text("Pasajeros totales: ${_stopRecords.fold(0, (sum, stop) => sum + (stop["passengers"] as int))}"),
              Text("Distancia: ${_totalDistance.toStringAsFixed(2)} m"),
              Text("Velocidad promedio: ${_averageSpeed.toStringAsFixed(2)} m/s"),
              SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Aceptar"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ruta.nombre), backgroundColor: Colors.blueAccent),
      drawer: buildDrawer(context, widget.usuario, _menuLateralChofer, 'Registro de viaje'),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
                    myLocationEnabled: true,
                    onMapCreated: (controller) => _controller.complete(controller),
                    markers: _markers,
                  ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  void _menuLateralChofer(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _startNavigation,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
          child: Text("Iniciar Ruta"),
        ),
        ElevatedButton(
          onPressed: _registerStop,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
          child: Text("Registrar Parada"),
        ),
        ElevatedButton(
          onPressed: _endNavigation,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: Text("Finalizar Ruta"),
        ),
      ],
    );
  }
}