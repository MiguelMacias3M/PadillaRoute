import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:padillaroutea/services/realtime_db_services/incidentes_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';

class IncidentsScreenRegister extends StatefulWidget {
  @override
  _IncidentsScreenRegisterState createState() =>
      _IncidentsScreenRegisterState();
}

class _IncidentsScreenRegisterState extends State<IncidentsScreenRegister> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  late IncidentesHelper incidentesHelper;

  @override
  void initState() {
    super.initState();
    incidentesHelper = IncidentesHelper(RealtimeDbHelper());
  }

  Future<void> _guardarIncidencia() async {
    String nombre = _nombreController.text.trim();
    String descripcion = _descripcionController.text.trim();

    if (nombre.isEmpty || descripcion.isEmpty) {
      _mostrarMensaje('Por favor, completa todos los campos.');
      return;
    }

    IncidenteRegistro nuevoIncidente = IncidenteRegistro(
      idRegistro: DateTime.now().millisecondsSinceEpoch,
      idUsuario: 1, // Reemplazar con el ID del usuario autenticado si aplica
      descripcion: descripcion,
      fecha: DateTime.now().toString(),
      idVehiculo: 1, // Reemplazar con el ID del vehículo si aplica
    );

    await incidentesHelper.setNew(nuevoIncidente);
    _mostrarMensaje('Incidencia registrada exitosamente.');
    _nombreController.clear();
    _descripcionController.clear();
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incidencias',
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
            Text(
              'Ruta Rincón',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField('Nombre de la incidencia', _nombreController),
            SizedBox(height: 20),
            _buildDescriptionField('Descripción', _descripcionController),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _guardarIncidencia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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

  Widget _buildTextField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDescriptionField(
      String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
