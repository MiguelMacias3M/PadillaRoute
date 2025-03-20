import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/StopScreenEdit.dart';
import 'package:padillaroutea/screens/StopScreenRegister.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class StopScreenManagement extends StatefulWidget {
  final Usuario usuario;

  StopScreenManagement({required this.usuario});
  @override
  _StopScreenManagementState createState() => _StopScreenManagementState();
}

class _StopScreenManagementState extends State<StopScreenManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Parada> stops = [];
  List<Parada> filteredStops = [];
  late ParadasHelper paradasHelper;
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    paradasHelper = ParadasHelper(RealtimeDbHelper());
    _loadStops();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStops();
  }

  Future<void> _loadStops() async {
    try {
      List<Parada> stopList = await paradasHelper.getAll();
      setState(() {
        stops = stopList;
        filteredStops = stopList;
      });
    } catch (e) {
      print("Error loading stops: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar las paradas")),
      );
    }
  }

  void _filterStops(String query) {
    setState(() {
      filteredStops = stops
          .where((stop) =>
              stop.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
          'Gestión de Paradas',
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
              onChanged: _filterStops,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar parada',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredStops.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredStops.length,
                      itemBuilder: (context, index) {
                        return _stopCard(context, filteredStops[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StopScreenRegister(usuario: widget.usuario,)),
          );
          _loadStops();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _stopCard(BuildContext context, Parada parada) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parada.nombre,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blueAccent),
            ),
            SizedBox(height: 5),
            Text('🕒 Hora de llegada: ${parada.horaLlegada}', style: TextStyle(fontSize: 14)),
            Text('🕑 Hora de salida: ${parada.horaSalida}', style: TextStyle(fontSize: 14)),
            Text('📍 Coordenadas: ${parada.coordenadas}', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StopScreenEdit(usuario: widget.usuario, parada: parada)),
                    );
                    _loadStops();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Editar', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    await paradasHelper.delete(parada.idParada);
                    _loadStops();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
