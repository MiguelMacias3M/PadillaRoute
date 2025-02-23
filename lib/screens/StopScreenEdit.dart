import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class StopScreenEdit extends StatefulWidget {
  @override
  _StopScreenEditState createState() => _StopScreenEditState();
}

class _StopScreenEditState extends State<StopScreenEdit> {
  TextEditingController _routeNameController = TextEditingController();
  TextEditingController _startTimeController = TextEditingController();
  TextEditingController _endTimeController = TextEditingController();
  TextEditingController _coordinatesController = TextEditingController();
  
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }
  
  void _addMarker(LatLng position) {
    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: MarkerId(position.toString()),
          position: position,
          infoWindow: InfoWindow(title: 'Parada seleccionada'),
        ),
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
        title: Text("Editar Ruta"),
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
                markers: _markers,
                onTap: _addMarker, // Agrega paradas con un toque
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para guardar la ruta editada
                  print("Ruta Guardada: ${_routeNameController.text}, Coordenadas: ${_coordinatesController.text}");
                },
                child: Text(
                  "Guardar Ruta",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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