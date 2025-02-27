import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MonitoringRouteScreen extends StatefulWidget {
  @override
  _MonitoringRouteScreenState createState() => _MonitoringRouteScreenState();
}

class _MonitoringRouteScreenState extends State<MonitoringRouteScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Obtener ubicación actual al iniciar
  }

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Permiso de ubicación denegado");
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      print("Ubicación actual: $_currentLocation");
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!)); // Enfocar cámara en la ubicación actual
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLng(_currentLocation!)); // Enfocar en la ubicación actual
    }
  }

  void _startRealTimeTracking() {
    if (_currentLocation == null) {
      print("No se puede iniciar el seguimiento sin una ubicación actual.");
      return;
    }

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
        print("Nueva ubicación del vehículo: $_currentLocation"); // Mensaje a la consola
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
                target: _currentLocation ?? LatLng(0, 0), // Utilizar ubicación actual
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
            child: Text("Iniciar Seguimiento", style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
