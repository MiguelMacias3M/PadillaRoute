import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';

class VehiclesScreenEdit extends StatefulWidget {
  final Vehiculo vehiculo;
final Usuario usuario;
  VehiclesScreenEdit({required this.vehiculo, required this.usuario});

  @override
  _VehiclesScreenEditState createState() => _VehiclesScreenEditState();
}

class _VehiclesScreenEditState extends State<VehiclesScreenEdit> {
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _numeroCombiController;
  late TextEditingController _placaController;
  late TextEditingController _capacidadController;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  String? _selectedStatus;
  final List<String> _statusOptions = ['Activo', 'Inactivo', 'Mantenimiento'];

  @override
  void initState() {
    super.initState();
    _marcaController = TextEditingController(text: widget.vehiculo.marca);
    _modeloController = TextEditingController(text: widget.vehiculo.modelo);
    _numeroCombiController =
        TextEditingController(text: widget.vehiculo.numeroSerie.toString());
    _placaController = TextEditingController(text: widget.vehiculo.placa);
    _capacidadController =
        TextEditingController(text: widget.vehiculo.capacidad.toString());

    _selectedStatus = _statusOptions.firstWhere(
      (status) => status.toLowerCase() == widget.vehiculo.estatus.name,
      orElse: () => 'Activo',
    );
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroCombiController.dispose();
    _placaController.dispose();
    _capacidadController.dispose();
    _logAction(widget.usuario.correo, Tipo.alta, "Ingreso a edicion de vehiculos");
    super.dispose();
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
        title: Text(
          'Editar Vehículo',
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
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField('Marca', _marcaController),
            SizedBox(height: 10),
            _inputField('Modelo', _modeloController),
            SizedBox(height: 10),
            _inputField('Num. Combi', _numeroCombiController,
                inputType: TextInputType.number),
            SizedBox(height: 10),
            _inputField('Placa', _placaController),
            SizedBox(height: 10),
            _inputField('Capacidad', _capacidadController,
                inputType: TextInputType.number),
            SizedBox(height: 10),
            _statusDropdown(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Guardar cambios',
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

  Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Estado',
        border: OutlineInputBorder(),
      ),
      items: _statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: TextStyle(
                color: status == 'Activo'
                    ? Colors.green
                    : status == 'Inactivo'
                        ? Colors.red
                        : Colors.orange),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }

  void _saveChanges() async {
    try {
      final vehiculosHelper = VehiculosHelper(RealtimeDbHelper());

      final updatedVehicle = {
        'marca': _marcaController.text,
        'modelo': _modeloController.text,
        'numeroSerie': int.tryParse(_numeroCombiController.text) ?? 0,
        'placa': _placaController.text,
        'capacidad': int.tryParse(_capacidadController.text) ?? 0,
        'estatus': _selectedStatus?.toLowerCase(),
      };

      print("Datos a actualizar: $updatedVehicle");

      await vehiculosHelper.update(widget.vehiculo.idVehiculo, updatedVehicle);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cambios guardados correctamente')),
      );
      await _logAction(widget.usuario.correo, Tipo.modificacion, 'Modificó vehículo ${widget.vehiculo.idVehiculo}');


      Navigator.pop(context);
    } catch (e) {
      print("Error al actualizar: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    await _logAction(widget.usuario.correo, Tipo.modificacion, 'Error al modificar vehículo ${widget.vehiculo.idVehiculo}: $e');
    }
  }
}

// --- Actualización del onPressed en la lista de vehículos ---
void navigateToEditScreen(BuildContext context, Vehiculo vehiculo, Usuario usuario) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => VehiclesScreenEdit(vehiculo: vehiculo, usuario: usuario),
    ),
  );
}
