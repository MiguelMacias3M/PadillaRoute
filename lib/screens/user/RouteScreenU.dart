import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:padillaroutea/screens/user/IncidentsScreenRegister.dart';
import 'package:padillaroutea/services/fcm_service.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';

class RouteScreenU extends StatefulWidget {
  final Ruta ruta;
  final Usuario usuario;

  RouteScreenU({required this.ruta, required this.usuario});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  List<Map<String, dynamic>> _stopRecords = [];
  Set<Marker> _markers = {};
  DateTime? _startTime;
  DateTime? _endTime;
  double _totalDistance = 0.0;
  double _averageSpeed = 0.0;

  final List<LatLng> _fixedStops = [
    LatLng(22.324847, -102.292803),
    LatLng(22.324216, -102.293004),
    LatLng(22.321520, -102.293886),
  ];
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta,
        "Inicialización de RouteScreenU", logsHelper, _logger);
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print("❌ Permisos de ubicación denegados");
          logAction(widget.usuario.correo, Tipo.baja,
              "Permisos de ubicación denegados", logsHelper, _logger);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        logAction(
            widget.usuario.correo,
            Tipo.baja,
            "Permisos de ubicación denegados permanentemente",
            logsHelper,
            _logger);
        print("❌ Permisos de ubicación denegados permanentemente");
        return;
      }
      print("✅ Permisos de ubicación concedidos");
      _getCurrentLocation();
      logAction(widget.usuario.correo, Tipo.alta,
          "Permisos de ubicación concedidos", logsHelper, _logger);
      _getCurrentLocation();
    } catch (e) {
      print("❌ Error en checkLocationPermissions: $e");
      logAction(widget.usuario.correo, Tipo.baja,
          "Error en checkLocationPermissions: $e", logsHelper, _logger);
    }
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
      controller
          .animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));

      _fixedStops.asMap().forEach((index, stop) {
        _markers.add(
          Marker(
            markerId: MarkerId("Fixed_Stop_${index + 1}"),
            position: stop,
            infoWindow: InfoWindow(title: "Parada ${index + 1}"),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      logAction(widget.usuario.correo, Tipo.alta,
          "Ubicación obtenida: $_currentPosition", logsHelper, _logger);
      print("📍 Ubicación obtenida: $_currentPosition");
      setState(() {});
    } catch (e) {
      print("❌ Error obteniendo la ubicación: $e");
      logAction(widget.usuario.correo, Tipo.baja,
          "Error obteniendo la ubicación: $e", logsHelper, _logger);
    }
  }

  Future<void> _startNavigation() async {
    if (_currentPosition == null) {
      logAction(widget.usuario.correo, Tipo.baja,
          "Intento de iniciar ruta sin ubicación", logsHelper, _logger);
      print("⚠️ No se puede iniciar la ruta sin ubicación.");
      return;
    }

    setState(() {
      _startTime = DateTime.now();
      _stopRecords.clear();
      _endTime = null;
    });

    print("🚀 Ruta iniciada a las $_startTime");
    logAction(widget.usuario.correo, Tipo.alta,
        "Ruta iniciada a las $_startTime", logsHelper, _logger);
    // Enviar notificación a los usuarios con roles 'gerente' y 'administrativo' al iniciar la ruta
    _sendNotification("La ruta ${widget.ruta.nombre} ha comenzado.");

    String origin =
        "${_currentPosition!.latitude},${_currentPosition!.longitude}";
    String destination =
        "${_fixedStops.last.latitude},${_fixedStops.last.longitude}";
    String waypoints = _fixedStops
        .map((stop) => "${stop.latitude},${stop.longitude}")
        .join("|");

    String googleMapsUrl = "https://www.google.com/maps/dir/?api=1"
        "&origin=$origin"
        "&destination=$destination"
        "&waypoints=$waypoints"
        "&travelmode=driving";

    print("🔵 URL generada: $googleMapsUrl");

    final uri = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      logAction(widget.usuario.correo, Tipo.alta,
          "Se abrió Google Maps para la ruta", logsHelper, _logger);
    } else {
      print("❌ No se pudo abrir Google Maps.");
      logAction(widget.usuario.correo, Tipo.baja, "Error al abrir Google Maps",
          logsHelper, _logger);
    }
  }

  Future<void> _registerStop() async {
    if (_currentPosition == null) {
      print("⚠️ No se puede registrar una parada sin ubicación.");
      logAction(widget.usuario.correo, Tipo.baja,
          "Intento de registrar parada sin ubicación", logsHelper, _logger);
      return;
    }

    DateTime arrivalTime = DateTime.now();
    TextEditingController passengersController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registrar Parada"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("📍 Parada en ${_currentPosition!}"),
              TextField(
                controller: passengersController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Cantidad de pasajeros"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                logAction(widget.usuario.correo, Tipo.modificacion,
                    "Canceló el registro de parada", logsHelper, _logger);
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                int passengers = int.tryParse(passengersController.text) ?? 0;
                DateTime departureTime = DateTime.now();

                setState(() {
                  _stopRecords.add({
                    "arrivalTime": arrivalTime,
                    "departureTime": departureTime,
                    "location": _currentPosition,
                    "passengers": passengers,
                  });

                  _markers.add(
                    Marker(
                      markerId: MarkerId("User_Stop_${_stopRecords.length}"),
                      position: _currentPosition!,
                      infoWindow: InfoWindow(
                          title: "Parada ${_stopRecords.length}",
                          snippet: "Pasajeros: $passengers"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                    ),
                  );
                });

                Navigator.pop(context);
                logAction(
                    widget.usuario.correo,
                    Tipo.alta,
                    "Registró parada con $passengers pasajeros",
                    logsHelper,
                    _logger);
              },
              child: Text("Guardar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => IncidentsScreenRegister(
                            usuario: widget.usuario,
                            ruta: widget.ruta,
                          )),
                );
                logAction(widget.usuario.correo, Tipo.modificacion,
                    "Reportó incidencia durante la ruta", logsHelper, _logger);
              },
              style: TextButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Incidencia", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _endNavigation() async {
    if (_startTime == null) {
      logAction(widget.usuario.correo, Tipo.baja,
          "Intento de finalizar ruta sin haber iniciado", logsHelper, _logger);
      print("⚠️ No puedes finalizar una ruta que no ha comenzado.");
      return;
    }

    setState(() {
      _endTime = DateTime.now();
    });
// Enviar notificación a los usuarios con roles 'gerente' y 'administrativo' al finalizar la ruta
    _sendNotification("La ruta ${widget.ruta.nombre} ha finalizado.");
    print("🏁 Ruta finalizada a las $_endTime");
    logAction(widget.usuario.correo, Tipo.alta,
        "Ruta finalizada a las $_endTime", logsHelper, _logger);
    _showSummary();
  }

  void _showSummary() {
    Duration totalTime = _endTime!.difference(_startTime!);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Felicidades, has terminado el viaje 🎉"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🕒 Inicio: $_startTime"),
              Text("⏹ Paradas: ${_stopRecords.length}"),
              Text("🏁 Fin: $_endTime"),
              Text("⏳ Tiempo total: ${totalTime.inMinutes} min"),
              Text(
                  "📏 Distancia total: ${_totalDistance.toStringAsFixed(2)} m"),
              Text(
                  "🚀 Velocidad promedio: ${_averageSpeed.toStringAsFixed(2)} m/s"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendNotification(String message) async {
    try {
      // Obtener el accessToken usando la función pública
      final accessToken = await getAccessToken();
      await sendFCMMessage("Actualización de Ruta", message,
          "administrativos_y_gerentes", accessToken);
      print("Notificación enviada: $message");
      logAction(widget.usuario.correo, Tipo.alta,
          "Notificación enviada: $message", logsHelper, _logger);
    } catch (e) {
      print("Error al enviar la notificación: $e");
      logAction(widget.usuario.correo, Tipo.baja,
          "Error al enviar notificación: $e", logsHelper, _logger);
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
        title: Text(widget.ruta.nombre),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: buildDrawer(
          context, widget.usuario, _menuLateralChofer, 'Registro de viaje'),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _currentPosition!, zoom: 15),
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      setState(() {});
                    },
                    markers: _markers,
                  ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _startNavigation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Color de fondo verde
            foregroundColor: Colors.white, // Color de texto blanco
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          child: Text("Iniciar Ruta"),
        ),
        ElevatedButton(
          onPressed: _registerStop,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange, // Color de fondo naranja
            foregroundColor: Colors.white, // Color de texto blanco
          ),
          child: Text("Registrar Parada"),
        ),
        ElevatedButton(
          onPressed: _endNavigation,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Color de fondo rojo
            foregroundColor: const Color.fromARGB(
                255, 255, 255, 255), // Color de texto blanco
          ),
          child: Text("Finalizar Ruta"),
        ),
      ],
    );
  }
}
