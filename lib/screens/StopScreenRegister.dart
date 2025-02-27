import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:geolocator/geolocator.dart';

class StopScreenRegister extends StatefulWidget {
  @override
  _StopScreenRegisterState createState() => _StopScreenRegisterState();
}

class _StopScreenRegisterState extends State<StopScreenRegister> {
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();

  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  late ParadasHelper paradasHelper;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    paradasHelper = ParadasHelper(RealtimeDbHelper());
    _getCurrentLocation();
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
      _mapController?.moveCamera(CameraUpdate.newLatLng(_currentLocation!));
      _markers.add(Marker(
        markerId: MarkerId('current_location'),
        position: _currentLocation!,
        infoWindow: InfoWindow(title: 'Ubicación Actual'),
      ));
    });
    print("Ubicación actual: $_currentLocation");
  }

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

  Future<void> _registerStop() async {
    String nombreParada = _routeNameController.text.trim();
    String horaInicio = _startTimeController.text.trim();
    String horaFin = _endTimeController.text.trim();
    String coordenadas = _coordinatesController.text.trim();

    if (nombreParada.isEmpty || horaInicio.isEmpty || horaFin.isEmpty || coordenadas.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      return;
    }

    Parada nuevaParada = Parada(
      idParada: DateTime.now().millisecondsSinceEpoch,
      nombre: nombreParada,
      horaLlegada: horaInicio,
      horaSalida: horaFin,
      coordenadas: coordenadas,
    );

    await paradasHelper.setNew(nuevaParada);
    _showMessage('Parada registrada exitosamente.');
    _clearFields();
  }

  void _clearFields() {
    _routeNameController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _coordinatesController.clear();
    setState(() {
      _markers.clear();
    });
  }

  void _showMessage(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Registrar Parada"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(labelText: "Nombre de la Parada"),
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
                  target: _currentLocation ?? LatLng(-12.0464, -77.0428),
                  zoom: 12,
                ),
                markers: _markers,
                onTap: _addMarker, // Agrega paradas con un toque
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _registerStop,
                child: Text(
                  "Registrar Parada",
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
