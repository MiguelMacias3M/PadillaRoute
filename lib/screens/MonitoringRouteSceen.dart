import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MonitoringRouteScreen extends StatefulWidget {
  @override
  _MonitoringRouteScreenState createState() => _MonitoringRouteScreenState();
}

class _MonitoringRouteScreenState extends State<MonitoringRouteScreen> {
  GoogleMapController? _mapController;
  LatLng _vehiclePosition = LatLng(22.229896, -102.321105);
  Timer? _timer;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _startRealTimeTracking() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        _vehiclePosition = LatLng(
          _vehiclePosition.latitude + 0.0001,
          _vehiclePosition.longitude + 0.0001,
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(_vehiclePosition),
        );
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
                target: _vehiclePosition,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId("vehicle"),
                  position: _vehiclePosition,
                  infoWindow: InfoWindow(title: "Vehículo en ruta"),
                ),
              },
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
