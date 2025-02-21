import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class StopScreenRegister extends StatefulWidget {
  @override
  _StopScreenRegisterState createState() => _StopScreenRegisterState();
}

class _StopScreenRegisterState extends State<StopScreenRegister> {
  TextEditingController _routeNameController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _coordinatesController = TextEditingController();
  
  Marker? _marker;
  GoogleMapController? _mapController;
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  
  void _addMarker(LatLng position) {
    setState(() {
      _marker = Marker(
        markerId: MarkerId("selected_location"),
        position: position,
        infoWindow: InfoWindow(title: 'Parada seleccionada'),
      );
      _coordinatesController.text = "${position.latitude}, ${position.longitude}";
    });
  }
  
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Ruta"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(labelText: "Nombre de la Ruta"),
            ),
            GestureDetector(
              onTap: () => _selectTime(context, _startTimeController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _startTimeController,
                  decoration: InputDecoration(labelText: "Hora de Inicio"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context, _endTimeController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _endTimeController,
                  decoration: InputDecoration(labelText: "Hora de Fin"),
                ),
              ),
            ),
            TextField(
              controller: _coordinatesController,
              decoration: InputDecoration(labelText: "Coordenadas"),
              readOnly: true,
            ),
            SizedBox(height: 10),
            Expanded(
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: LatLng(-12.0464, -77.0428), // Coordenadas iniciales
                  zoom: 12,
                ),
                markers: _marker != null ? {_marker!} : {},
                onTap: _addMarker, // Agrega solo una parada
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para registrar la ruta
                  print("Ruta Registrada: ${_routeNameController.text}");
                },
                child: Text("Registrar Ruta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 0, 166, 255),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
