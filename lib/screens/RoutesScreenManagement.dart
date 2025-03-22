import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/RoutesScreenEdit.dart';
import 'package:padillaroutea/screens/RoutesScreenRegister.dart';
import 'package:padillaroutea/screens/RoutesScreenAssign.dart';
import 'package:padillaroutea/screens/VehiclesScreenAssign.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/screens/AssignUserVehicleScreen.dart';

class RoutesScreenManagement extends StatefulWidget {
  final Usuario usuario;

  RoutesScreenManagement({required this.usuario});
  @override
  _RoutesScreenManagementState createState() => _RoutesScreenManagementState();
}

class _RoutesScreenManagementState extends State<RoutesScreenManagement> {
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());
  final UsuariosHelper _usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  List<Ruta> _routes = [];
  Map<int, String> _choferNombres = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta, "Ingreso a consulta de rutas",
        logsHelper, _logger);
    _loadRoutes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() {
      _loading = true;
    });

    try {
      _routes = await _rutasHelper.getAll();
      await _loadChoferes();
      await logAction(widget.usuario.correo, Tipo.modificacion,
          "Cargó la lista de rutas", logsHelper, _logger);
    } catch (e) {
      print('Error al cargar rutas: $e');
      _logger.e('Error al cargar rutas: $e');
      await logAction(widget.usuario.correo, Tipo.modificacion,
          "Error al cargar rutas", logsHelper, _logger);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadChoferes() async {
    _choferNombres.clear();
    for (var ruta in _routes) {
      try {
        Usuario? chofer = await _usuariosHelper.get(ruta.idChofer);
        setState(() {
          _choferNombres[ruta.idChofer] = chofer?.nombre ?? 'Sin asignar';
        });
      } catch (e) {
        _logger.e("Error al cargar chofer: $e");
      }
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
          'Rutas',
          style: TextStyle(
            color: Colors.blue.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Rutas'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Gestiona todas tus rutas y asigna paradas fácilmente.',
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        final ruta = _routes[index];
                        return _routeCard(context, ruta);
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await logAction(widget.usuario.correo, Tipo.alta,
              "Entró a la pantalla de registro de ruta", logsHelper, _logger);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RoutesScreenRegister(usuario: widget.usuario)),
          ).then((_) => _loadRoutes()); // Recargar al regresar
        },
        backgroundColor: Colors.blue.shade900,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Ruta ruta) {
    String choferNombre = _choferNombres[ruta.idChofer] ?? 'Cargando...';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ruta.nombre,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.blue.shade900),
          ),
          Divider(color: Colors.blue.shade300),
          const SizedBox(height: 8),
          const Text('Paradas asignadas:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: ruta.paradas.map((stop) {
              return Chip(
                label: Text(stop,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold)),
                backgroundColor: Colors.blue.shade200,
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Usuario a cargo: $choferNombre',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 10),
                _actionButton(
                    context, 'Asignar usuario y vehiculo', Colors.green, Icons.car_crash,
                    () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AssignUserVehicleScreen(
                                rutaSeleccionada: ruta,
                                usuario: widget.usuario,
                              )));
                }),
                const SizedBox(width: 10),
                _actionButton(context, 'Editar', Colors.amber, Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutesScreenEdit(
                        routeId: ruta.idRuta,
                        ruta: ruta,
                        usuario: widget.usuario,
                      ),
                    ),
                  ).then((_) => _loadRoutes()); // Recargar al regresar
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context, String text, Color color,
      IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(text,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
