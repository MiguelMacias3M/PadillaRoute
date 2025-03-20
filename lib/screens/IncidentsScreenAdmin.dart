import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:padillaroutea/services/realtime_db_services/incidentes_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class IncidentsScreenAdmin extends StatefulWidget {
  final Usuario usuario;

  IncidentsScreenAdmin({required this.usuario});
  @override
  _IncidentsScreenAdminState createState() => _IncidentsScreenAdminState();
}

class _IncidentsScreenAdminState extends State<IncidentsScreenAdmin> {
  final TextEditingController _searchController = TextEditingController();
  List<IncidenteRegistro> incidents = [];
  List<IncidenteRegistro> filteredIncidents = [];
  late IncidentesHelper incidentesHelper;
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    incidentesHelper = IncidentesHelper(RealtimeDbHelper());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadIncidents(); // Se llama cada vez que la pantalla se reconstruye
    _logAction(widget.usuario.correo, Tipo.alta, "El usuario ha ingresado a la pantalla de incidencias");
  }

  // Cargar incidentes desde la base de datos
  Future<void> _loadIncidents() async {
    List<IncidenteRegistro> incidentList = await incidentesHelper.getAll();
    setState(() {
      incidents = incidentList;
      filteredIncidents = incidentList;
    });
  _logAction(widget.usuario.correo, Tipo.modifiacion, "Se han cargado las incidencias");
  }

  // Filtrar incidentes por descripción
  void _filterIncidents(String query) {
    setState(() {
      filteredIncidents = incidents
          .where((incident) =>
              incident.descripcion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  _logAction(widget.usuario.correo, Tipo.modifiacion, "Filtrado de incidencias realizado");
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
            TextField(
              controller: _searchController,
              onChanged: _filterIncidents,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar incidente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredIncidents.isEmpty
                  ? Center(child: CircularProgressIndicator()) // Cargando incidentes
                  : ListView.builder(
                      itemCount: filteredIncidents.length,
                      itemBuilder: (context, index) {
                        return _incidentItem(filteredIncidents[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _incidentItem(IncidenteRegistro incidente) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(incidente.descripcion, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('ID Usuario: ${incidente.idUsuario}'),
        trailing: ElevatedButton(
          onPressed: () {
            _showIncidentDetails(context, incidente);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text('Ver incidencia', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, IncidenteRegistro incidente) {
  _logAction(widget.usuario.correo, Tipo.modifiacion, "Visualización de detalles de incidencia ID: ${incidente.idRegistro}");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la incidencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Registro: ${incidente.idRegistro}'),
              SizedBox(height: 5),
              Text('ID Usuario: ${incidente.idUsuario}'),
              SizedBox(height: 5),
              Text('Descripción: ${incidente.descripcion}'),
              SizedBox(height: 5),
              Text('Fecha: ${incidente.fecha}'),
              SizedBox(height: 5),
              Text('ID Vehículo: ${incidente.idVehiculo}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              _logAction(widget.usuario.correo, Tipo.baja, "Cierre de detalles de incidencia ID: ${incidente.idRegistro}");
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
