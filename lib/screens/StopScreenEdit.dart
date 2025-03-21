import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral

class StopScreenEdit extends StatefulWidget {
  final Parada parada; // Recibir el objeto Parada
  final Usuario usuario;

  StopScreenEdit(
      {required this.parada,
      required this.usuario}); // Constructor con parámetro requerido

  @override
  _StopScreenEditState createState() => _StopScreenEditState();
}

class _StopScreenEditState extends State<StopScreenEdit> {
  late TextEditingController _routeNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  late TextEditingController _coordinatesController;
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
    _startTimeController =
        TextEditingController(text: widget.parada.horaLlegada);
    _endTimeController = TextEditingController(text: widget.parada.horaSalida);
    _coordinatesController =
        TextEditingController(text: widget.parada.coordenadas);

    // Obtener la ubicación actual
    _getCurrentLocation();
    _logAction(widget.usuario.correo, Tipo.modificacion,
        "Pantalla de edición de paradas abierta");
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permiso de ubicación denegado");
        _logger.w("Permiso de ubicación denegado");
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _mapController?.moveCamera(CameraUpdate.newLatLng(_currentLocation!));
        _markers.add(Marker(
          markerId: MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: InfoWindow(title: 'Ubicación Actual'),
        ));
      });
      _logAction(
          widget.usuario.correo, Tipo.modificacion, "Ubicación actual obtenida");
    } catch (e) {
      _logger.e("Error obteniendo ubicación: $e");
      print("Ubicación actual: $_currentLocation");
      _logger.e("Error obteniendo ubicación: $e");
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Error obteniendo ubicación: $e");
    }
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
      _coordinatesController.text =
          "${position.latitude}, ${position.longitude}";
    });
    _logAction(widget.usuario.correo, Tipo.modificacion,
        "Marcador agregado en: ${position.latitude}, ${position.longitude}");
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    try {
      TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (picked != null) {
        setState(() {
          controller.text = picked.format(context);
        });
        _logAction(widget.usuario.correo, Tipo.modificacion,
            "Hora seleccionada: ${controller.text}");
      }
    } catch (e) {
      _logger.e("Error seleccionando la hora: $e");
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Error seleccionando la hora: $e");
    }
  }

  void _saveRoute() async {
    String routeName = _routeNameController.text;
    String startTime = _startTimeController.text;
    String endTime = _endTimeController.text;
    String coordinates = _coordinatesController.text;

    if (routeName.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Por favor, complete todos los campos")),
      );
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Intento fallido de actualización: Campos vacíos");
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
      await ParadasHelper(RealtimeDbHelper())
          .update(widget.parada.idParada, updatedData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ruta actualizada correctamente")),
      );
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Parada actualizada correctamente: $routeName");
      Navigator.pop(context); // Regresar a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al actualizar la ruta: $e")),
      );
      _logger.e("Error al actualizar la parada: $e");
      _logAction(widget.usuario.correo, Tipo.modificacion,
          "Error al actualizar la parada: $e");
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
  
void _menuLateral(BuildContext context) {
  // Solo cerrar el Drawer (menú lateral)
  Navigator.pop(context); // Esto cierra el menú lateral
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Parada"),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Editar Parada'),
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
