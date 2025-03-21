import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral

class VehiclesScreen extends StatefulWidget {
  final Usuario usuario;

  VehiclesScreen({required this.usuario});
  @override
  _VehiclesScreenState createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _plateController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  // Instancia del helper para la BD
  final VehiculosHelper _vehiculosHelper = VehiculosHelper(RealtimeDbHelper());

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
        title: Text(
          'Vehículos',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Vehículos'),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al apartado de vehículos, registra tu flotilla',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            _inputField('Marca', _brandController),
            SizedBox(height: 10),
            _inputField('Modelo', _modelController),
            SizedBox(height: 10),
            _inputField('Num. Combi', _numberController,
                inputType: TextInputType.number),
            SizedBox(height: 10),
            _inputField('Placa', _plateController),
            SizedBox(height: 10),
            _inputField('Capacidad', _capacityController,
                inputType: TextInputType.number),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _registerVehicle,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Guardar',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller,
      {TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  void _registerVehicle() async {
    // Validar que los campos no estén vacíos
    if (_brandController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _numberController.text.isEmpty ||
        _plateController.text.isEmpty ||
        _capacityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Todos los campos son obligatorios')),
      );
      return;
    }

    // Convertir valores
    int idVehiculo =
        DateTime.now().millisecondsSinceEpoch; // ID único basado en tiempo
    int capacidad = int.tryParse(_capacityController.text) ?? 0;
    int numeroSerie = int.tryParse(_numberController.text) ?? 0;

    // Crear objeto Vehiculo
    Vehiculo vehiculo = Vehiculo(
      idVehiculo: idVehiculo,
      placa: _plateController.text,
      marca: _brandController.text,
      modelo: _modelController.text,
      capacidad: capacidad,
      numeroSerie: numeroSerie,
      estatus: Estatus.activo, // Se registra como activo por defecto
    );

    try {
      // Guardar en Firebase
      await _vehiculosHelper.setNew(vehiculo);
      await _logAction(widget.usuario.correo, Tipo.alta,
          "Registro de vehículo: ${vehiculo.placa}");

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vehículo registrado correctamente')),
      );

      // Limpiar los campos
      _brandController.clear();
      _modelController.clear();
      _numberController.clear();
      _plateController.clear();
      _capacityController.clear();
    } catch (e) {
      _logger.e("Error al registrar vehículo: $e");
      await _logAction(widget.usuario.correo, Tipo.modificacion,
          "Error al registrar vehículo: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar vehículo')),
      );
    }
  }
}
