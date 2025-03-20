import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:padillaroutea/screens/user/IncidentsScreenRegister.dart';

class RouteScreenU extends StatefulWidget {
  final String routeName;

  RouteScreenU({required this.routeName});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  List<LatLng> _trackedRoute = [];
  double _totalDistance = 0.0;
  double _averageSpeed = 0.0;

  final List<LatLng> _fixedStops = [
    LatLng(22.324847, -102.292803),
    LatLng(22.324216, -102.293004),
    LatLng(22.321520, -102.293886),
  ];

  List<Map<String, dynamic>> _stopRecords = [];
  Set<Marker> _markers = {};
  DateTime? _startTime;
  DateTime? _endTime;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Permisos de ubicación denegados");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("❌ Permisos de ubicación denegados permanentemente");
      return;
    }
    print("✅ Permisos de ubicación concedidos");
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

      _fixedStops.asMap().forEach((index, stop) {
        _markers.add(
          Marker(
            markerId: MarkerId("Fixed_Stop_${index + 1}"),
            position: stop,
            infoWindow: InfoWindow(title: "Parada ${index + 1}"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      });

      print("📍 Ubicación obtenida: $_currentPosition");
      setState(() {});
    } catch (e) {
      print("❌ Error obteniendo la ubicación: $e");
    }
  }

 Future<void> _startNavigation() async {
  if (_currentPosition == null) {
    print("⚠️ No se puede iniciar la ruta sin ubicación.");
    return;
  }

  setState(() {
    _startTime = DateTime.now();
    _stopRecords.clear();
    _endTime = null;
  });

  print("🚀 Ruta iniciada a las $_startTime");

  String origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
  String destination = "${_fixedStops.last.latitude},${_fixedStops.last.longitude}";

  // Formatear los waypoints correctamente
  String waypoints = _fixedStops.map((stop) => "${stop.latitude},${stop.longitude}").join("|");

  // Construcción de la URL para Google Maps
  String googleMapsUrl =
      "https://www.google.com/maps/dir/?api=1"
      "&origin=$origin"
      "&destination=$destination"
      "&waypoints=$waypoints"
      "&travelmode=driving";

  print("🔵 URL generada: $googleMapsUrl");

  final uri = Uri.parse(googleMapsUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    print("❌ No se pudo abrir Google Maps.");
  }
}

  Future<void> _registerStop() async {
    if (_currentPosition == null) {
      print("⚠️ No se puede registrar una parada sin ubicación.");
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
              onPressed: () => Navigator.pop(context),
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
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: Text("Guardar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IncidentsScreenRegister()),
                );
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
      print("⚠️ No puedes finalizar una ruta que no ha comenzado.");
      return;
    }

    setState(() {
      _endTime = DateTime.now();
    });

    print("🏁 Ruta finalizada a las $_endTime");
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
              ..._stopRecords.map((stop) => Text(
                  "📍 ${stop['location']} - 🕓 Llegada: ${stop['arrivalTime']} - 🚀 Salida: ${stop['departureTime']} - 👥 Pasajeros: ${stop['passengers']}")),
              Text("🏁 Fin: $_endTime"),
              Text("⏳ Tiempo total: ${totalTime.inMinutes} min"),
              Text("📏 Distancia total: ${_totalDistance.toStringAsFixed(2)} m"),
              Text("🚀 Velocidad promedio: ${_averageSpeed.toStringAsFixed(2)} m/s"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.routeName), backgroundColor: Colors.blueAccent),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
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
          foregroundColor: const Color.fromARGB(255, 255, 255, 255), // Color de texto blanco
        ),
        child: Text("Finalizar Ruta"),
      ),
    ],
  );
}

}
