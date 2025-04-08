import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:padillaroutea/services/realtime_db_services/incidentes_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:intl/intl.dart';


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
    logAction(
        widget.usuario.correo,
        Tipo.alta,
        "El usuario ha ingresado a la pantalla de incidencias",
        logsHelper,
        _logger);
  }

  // Cargar incidentes desde la base de datos
  Future<void> _loadIncidents() async {
    List<IncidenteRegistro> incidentList = await incidentesHelper.getAll();
    setState(() {
      incidents = incidentList;
      filteredIncidents = incidentList;
    });
    logAction(widget.usuario.correo, Tipo.modificacion,
        "Se han cargado las incidencias", logsHelper, _logger);
  }

  // Filtrar incidentes por descripción
  void _filterIncidents(String query) {
    setState(() {
      filteredIncidents = incidents
          .where((incident) =>
              incident.descripcion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    logAction(widget.usuario.correo, Tipo.modificacion,
        "Filtrado de incidencias realizado", logsHelper, _logger);
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
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Incidencias'),
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
                  ? Center(
                      child: CircularProgressIndicator()) // Cargando incidentes
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
    return FutureBuilder<Usuario?>(
      future: UsuariosHelper(RealtimeDbHelper()).get(incidente.idUsuario),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(incidente.descripcion,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Cargando usuario...'),
              trailing: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10),
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(incidente.descripcion,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Usuario no encontrado'),
            ),
          );
        }

        final usuario = snapshot.data!;
        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            title: Text(incidente.descripcion,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(usuario.nombre),
              ],
            ),
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
              child:
                  Text('Ver incidencia', style: TextStyle(color: Colors.white)),
            ),
          ),
        );
      },
    );
  }

  void _showIncidentDetails(BuildContext context, IncidenteRegistro incidente) {
    logAction(
        widget.usuario.correo,
        Tipo.modificacion,
        "Visualización de detalles de incidencia ID: ${incidente.idRegistro}",
        logsHelper,
        _logger);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<Usuario?>(
          future: UsuariosHelper(RealtimeDbHelper()).get(incidente.idUsuario),
          builder: (context, snapshot) {
            final usuario = snapshot.data;
            final fechaHora = DateTime.parse(incidente.fecha);

            return AlertDialog(
              title: Text('Detalles de la incidencia'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Num. Registro: ${incidente.idRegistro}.'),
                  SizedBox(height: 5),
                  Text(
                      'Usuario: ${snapshot.connectionState == ConnectionState.waiting ? 'Cargando...' : usuario?.nombre ?? 'No encontrado'}.'),
                  SizedBox(height: 5),
                  Text('Descripción: ${incidente.descripcion}.'),
                  SizedBox(height: 5),
                  Text('Fecha: ${DateFormat('yyyy-MM-dd').format(fechaHora)}  a las: ${DateFormat('HH:mm:ss').format(fechaHora)} hrs.'),
                  SizedBox(height: 5),
                  Text('ID Vehículo: ${incidente.idVehiculo}'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    logAction(
                        widget.usuario.correo,
                        Tipo.baja,
                        "Cierre de detalles de incidencia ID: ${incidente.idRegistro}",
                        logsHelper,
                        _logger);
                  },
                  child: Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
