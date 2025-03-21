import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:geolocator/geolocator.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';

class StopScreenRegister extends StatefulWidget {
  final Usuario usuario;

  StopScreenRegister({required this.usuario});
  @override
  _StopScreenRegisterState createState() => _StopScreenRegisterState();
}

class _StopScreenRegisterState extends State<StopScreenRegister> {
  final TextEditingController _routeNameController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  late ParadasHelper paradasHelper;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    paradasHelper = ParadasHelper(RealtimeDbHelper());
    _logAction(
        widget.usuario.correo, Tipo.alta, "Ingreso a registro de paradas");
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Permiso de ubicación denegado");
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
      print("Ubicación actual: $_currentLocation");
      _logAction(widget.usuario.correo, Tipo.modifiacion,
          "Ubicación obtenida: $_currentLocation");
    } catch (e) {
      _logger.e("Error obteniendo la ubicación: $e");
      _logAction(
          widget.usuario.correo, Tipo.baja, "Error obteniendo ubicación");
    }
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
    _logAction(widget.usuario.correo, Tipo.modifiacion,
        "Marcador agregado en: $position");
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
        _logAction(widget.usuario.correo, Tipo.modifiacion,
            "Hora seleccionada: ${controller.text}");
      }
    } catch (e) {
      _logger.e("Error seleccionando hora: $e");
      _logAction(widget.usuario.correo, Tipo.baja, "Error seleccionando hora");
    }
  }

  Future<void> _registerStop() async {
    String nombreParada = _routeNameController.text.trim();
    String horaInicio = _startTimeController.text.trim();
    String horaFin = _endTimeController.text.trim();
    String coordenadas = _coordinatesController.text.trim();

    if (nombreParada.isEmpty ||
        horaInicio.isEmpty ||
        horaFin.isEmpty ||
        coordenadas.isEmpty) {
      _showMessage('Por favor, completa todos los campos.');
      _logAction(widget.usuario.correo, Tipo.baja,
          "Intento fallido de registro: Campos vacíos");
      return;
    }

    Parada nuevaParada = Parada(
      idParada: DateTime.now().millisecondsSinceEpoch,
      nombre: nombreParada,
      horaLlegada: horaInicio,
      horaSalida: horaFin,
      coordenadas: coordenadas,
    );

    try {
      await paradasHelper.setNew(nuevaParada);
      _showMessage('Parada registrada exitosamente.');
      _logAction(
          widget.usuario.correo, Tipo.alta, "Parada registrada: $nombreParada");
      _clearFields();
    } catch (e) {
      _logger.e("Error registrando parada: $e");
      _logAction(widget.usuario.correo, Tipo.baja, "Error registrando parada");
    }
  }

  void _clearFields() {
    _routeNameController.clear();
    _startTimeController.clear();
    _endTimeController.clear();
    _coordinatesController.clear();
    setState(() {
      _markers.clear();
    });
    _logAction(widget.usuario.correo, Tipo.modifiacion, "Campos limpiados");
  }

  void _showMessage(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
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
