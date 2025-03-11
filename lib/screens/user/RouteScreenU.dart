import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteScreenU extends StatefulWidget {
  final String routeName;

  RouteScreenU({required this.routeName});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  
  // 🔥 Lista de 3 paradas fijas
  final List<LatLng> _fixedStops = [
    LatLng(22.324847, -102.292803), // Parada 1
    LatLng(22.324216, -102.293004), // Parada 2
    LatLng(22.321520, -102.293886), // Parada 3
  ];

  List<LatLng> _userStops = []; // 🔥 Paradas agregadas por el usuario
  Set<Marker> _markers = {}; // 🔥 Marcadores en el mapa
  DateTime? _startTime;
  List<Map<String, dynamic>> _stopRecords = [];
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

      // 🔥 Agregar marcadores de las 3 paradas fijas al mapa
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
      setState(() {}); // 🔥 Para actualizar los marcadores en el mapa
    } catch (e) {
      print("❌ Error obteniendo la ubicación: $e");
    }
  }

  /// **Iniciar Ruta con las 3 Paradas Fijas**
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

    // 🔥 Generar URL con paradas fijas como waypoints
    String origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
    String destination = "${_fixedStops.last.latitude},${_fixedStops.last.longitude}";
    String waypoints = _fixedStops.map((stop) => "${stop.latitude},${stop.longitude}").join("|");

    String googleMapsUrl =
        "https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination"
        "&waypoints=$waypoints&travelmode=driving";

    final uri = Uri.parse(googleMapsUrl);
    if (await canLaunch(uri.toString())) {
      await launch(uri.toString());
    } else {
      print("❌ No se pudo abrir Google Maps.");
    }
  }

  /// **Registrar Parada Adicional**
  Future<void> _registerStop() async {
    if (_currentPosition == null) {
      print("⚠️ No se puede registrar una parada sin ubicación.");
      return;
    }

    setState(() {
      LatLng stop = _currentPosition!;
      _userStops.add(stop);
      _stopRecords.add({
        "time": DateTime.now(),
        "location": stop,
      });

      // 🔥 Agregar marcador de parada adicional al mapa
      _markers.add(
        Marker(
          markerId: MarkerId("User_Stop_${_userStops.length}"),
          position: stop,
          infoWindow: InfoWindow(title: "Parada Extra ${_userStops.length}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    });

    print("⏸ Parada registrada: ${_stopRecords.last}");
  }

  /// **Finalizar Ruta**
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

  /// **Mostrar Resumen de la Ruta**
  void _showSummary() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Resumen de la Ruta"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🕒 Inicio: $_startTime"),
              Text("⏹ Paradas Fijas: ${_fixedStops.length}"),
              Text("🟢 Paradas ehcas en la ruta: ${_stopRecords.length}"),
              ..._stopRecords.map((stop) => Text("⏸ ${stop['time']}")),
              Text("🏁 Fin: $_endTime"),
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
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
                    initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
                    myLocationEnabled: true,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      setState(() {});
                    },
                    markers: _markers, // 🔥 Mostrar todas las paradas en el mapa
                  ),
          ),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// **Botones de Control**
  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
            onPressed: _startNavigation,
            icon: Icon(Icons.navigation),
            label: Text("Iniciar Ruta"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          ),
          ElevatedButton.icon(
            onPressed: _registerStop,
            icon: Icon(Icons.add_location),
            label: Text("Agregar Parada"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          ElevatedButton.icon(
            onPressed: _endNavigation,
            icon: Icon(Icons.stop),
            label: Text("Finalizar Ruta"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
