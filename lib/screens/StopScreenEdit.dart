import 'package:flutter/material.dart'; 
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class StopScreenEdit extends StatefulWidget {
  final Parada parada; // Recibir el objeto Parada
  final Usuario usuario;

  StopScreenEdit({required this.parada, required this.usuario}); // Constructor con parámetro requerido

  @override
  _StopScreenEditState createState() => _StopScreenEditState();
}

class _StopScreenEditState extends State<StopScreenEdit> {
  late TextEditingController _routeNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _coordinatesController;
  final UsuariosHelper _usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los datos de la parada
    _routeNameController = TextEditingController(text: widget.parada.nombre);
    _startTimeController = TextEditingController(text: widget.parada.horaLlegada);
    _endTimeController = TextEditingController(text: widget.parada.horaSalida);
    _coordinatesController = TextEditingController(text: widget.parada.coordenadas);

    // Obtener la ubicación actual
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

  @override
  void dispose() {
    _routeNameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _coordinatesController.dispose();
    super.dispose();
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

  void _saveRoute() async {
    String routeName = _routeNameController.text;
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;
    String coordinates = _coordinatesController.text;

    if (routeName.isEmpty || startTime.isEmpty || endTime.isEmpty || coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, complete todos los campos")),
      );
      return;
    }

    // Crear un mapa con los datos a actualizar
    Map<String, dynamic> updatedData = {
      'nombre': routeName,
      'horaLlegada': startTime,
      'horaSalida': endTime,
      'coordenadas': coordinates,
    };

    try {
      // Llamar al método update del ParadasHelper
      await ParadasHelper(RealtimeDbHelper()).update(widget.parada.idParada, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ruta actualizada correctamente")),
      );
      Navigator.pop(context); // Regresar a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar la ruta: $e")),
      );
    }
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
        title: Text("Editar Parada"),
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
                  decoration: InputDecoration(labelText: "Hora de Llegada"),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _selectTime(context, _endTimeController),
              child: AbsorbPointer(
                child: TextField(
                  controller: _endTimeController,
                  decoration: InputDecoration(labelText: "Hora de Salida"),
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
                onTap: _addMarker,
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _saveRoute,
                child: Text(
                  "Guardar Cambios",
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
