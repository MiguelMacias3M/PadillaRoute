import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MonitoringRouteSceen.dart';
import 'package:padillaroutea/services/firebase_auth/firebase_auth_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class MonitoringScreenManagement extends StatefulWidget {
  final Usuario usuario;

  MonitoringScreenManagement({required this.usuario});
  @override
  _MonitoringScreenManagementState createState() =>
      _MonitoringScreenManagementState();
}

class _MonitoringScreenManagementState
    extends State<MonitoringScreenManagement> {
  FirebaseAuthHelper authHelper = FirebaseAuthHelper();
  RutasHelper rutasHelper = RutasHelper(RealtimeDbHelper());
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  List<Ruta> rutas = [];
  Map<int, String> usuariosMap = {}; // idUsuario -> Nombre del usuario

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta, "Ingreso a monitoreo",
        logsHelper, _logger);

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      List<Ruta> fetchedRutas = await rutasHelper.getAll();
      List<Usuario> fetchedUsuarios = await usuariosHelper.getAll();

      // Mapeamos los usuarios para acceder rápido a su nombre por ID
      Map<int, String> usuariosMapTemp = {
        for (var usuario in fetchedUsuarios) usuario.idUsuario: usuario.nombre
      };

      setState(() {
        // Filtramos solo las rutas con usuario asignado
        rutas = fetchedRutas
            .where((ruta) => usuariosMapTemp.containsKey(ruta.idChofer))
            .toList();
        usuariosMap = usuariosMapTemp;
      });
      logAction(widget.usuario.correo, Tipo.modificacion,
          "Datos de monitoreo cargados", logsHelper, _logger);
    } catch (e) {
      print("Error cargando datos: $e");
      _logger.e("Error cargando datos: $e");
    }
  }

  void _menuLateral(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Monitoreo',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Monitoreo'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al apartado de monitoreo, aquí puedes monitorear tus rutas',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: rutas.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: rutas.length,
                      itemBuilder: (context, index) {
                        return _routeCard(context, rutas[index]);
                      },
                    ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MonitoringRouteScreen(usuario: widget.usuario)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: Text(
                  'Monitorear todas las rutas',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Ruta ruta) {
    String usuarioNombre = usuariosMap[ruta.idChofer] ?? "Desconocido";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ruta.nombre,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 5),
            Wrap(
              children: ruta.paradas
                  .map<Widget>((stop) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          stop,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 14),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 5),
            Text(
              'Usuario a cargo: $usuarioNombre',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MonitoringRouteScreen(usuario: widget.usuario)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Monitorear',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
