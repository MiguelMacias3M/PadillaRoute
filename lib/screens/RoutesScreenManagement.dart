import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/RoutesScreenEdit.dart';
import 'package:padillaroutea/screens/RoutesScreenRegister.dart';
import 'package:padillaroutea/screens/RoutesScreenAssign.dart';
import 'package:padillaroutea/screens/VehiclesScreenAssign.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';

class RoutesScreenManagement extends StatefulWidget {
  @override
  _RoutesScreenManagementState createState() => _RoutesScreenManagementState();
}

class _RoutesScreenManagementState extends State<RoutesScreenManagement> {
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());
  final UsuariosHelper _usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  List<Ruta> _routes = [];
  Map<int, String> _choferNombres = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
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
    } catch (e) {
      print('Error al cargar rutas: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadChoferes() async {
    _choferNombres.clear();
    for (var ruta in _routes) {
      Usuario? chofer = await _usuariosHelper.get(ruta.idChofer);
      setState(() {
        _choferNombres[ruta.idChofer] = chofer?.nombre ?? 'Sin asignar';
      });
    }
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
      drawer: _buildDrawer(context),
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RoutesScreenRegister()),
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
                _actionButton(
                    context, 'Asignar usuario', Colors.blue, Icons.person_add,
                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RoutesScreenAssign(rutaSeleccionada: ruta),
                    ),
                  ).then((_) => _loadRoutes()); // Recargar al regresar
                }),
                const SizedBox(width: 10),
                _actionButton(context, 'Asignar vehiculo', Colors.green, Icons.car_crash, () {
                  Navigator.push(context, 
                  MaterialPageRoute(
                    builder: (context) => VehiclesScreenAssign(rutaSeleccionada: ruta)
                  ));
                }),
                const SizedBox(width: 10),
                _actionButton(context, 'Editar', Colors.amber, Icons.edit, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutesScreenEdit(
                        routeId: ruta.idRuta,
                        ruta: ruta,
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            child: Text('Gestión de Rutas', style: TextStyle(fontSize: 20)),
          ),
          _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin()),
          _drawerItem(
              context, Icons.exit_to_app, 'Cerrar sesión', LoginScreen()),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
    );
  }
}
