import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/menuScreenAdmin.dart';
import 'package:padillaroutea/screens/MonitoringScreenManagement.dart';
import 'package:padillaroutea/screens/IncidentsScreenAdmin.dart';
import 'package:padillaroutea/screens/RoutesScreenManagement.dart';
import 'package:padillaroutea/screens/StopScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';
import 'package:padillaroutea/screens/UserScreenRegister.dart';
import 'package:padillaroutea/screens/VehiclesScreenManagement.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';

class UserScreenSelect extends StatefulWidget {
  final Usuario usuario;

  UserScreenSelect({required this.usuario});
  @override
  _UserScreenSelect createState() =>
      _UserScreenSelect();
}

class _UserScreenSelect
    extends State<UserScreenSelect> {
    
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

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
          'Usuarios',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15, top: 10),
            child: Image.asset(
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido al apartado de usuarios, ¿qué te gustaría hacer hoy?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  _optionButton(context, 'Dar de alta usuarios', () async {
                    await _logAction(widget.usuario.correo, Tipo.alta, "Ingresó a la pantalla de registro de usuarios");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserScreenRegister(usuario: widget.usuario,)),
                    );
                  }),
                  _optionButton(context, 'Gestión de usuarios', () async {
                    await _logAction(widget.usuario.correo, Tipo.modifiacion, "Ingresó a la pantalla de gestión de usuarios");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserScreenManagement(usuario: widget.usuario,)),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(BuildContext context, String title, VoidCallback? onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          try {
            if (onPressed != null) {
              onPressed();
            }
          } catch (e) {
            await _logAction(widget.usuario.correo, Tipo.modifiacion, "Error en acción: $title - $e");
          }
        },
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          side: BorderSide(color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Administrador',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'admin@empresa.com',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
             _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin(usuario: widget.usuario)),
            _drawerItem(context, Icons.people, 'Usuarios', UserScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.directions_car, 'Vehículos', VehiclesScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', IncidentsScreenAdmin(usuario: widget.usuario)),
            _drawerItem(context, Icons.local_parking, 'Paradas', StopScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.location_on, 'Monioreo', MonitoringScreenManagement(usuario: widget.usuario)),
            _drawerItem(context, Icons.directions_car, 'Rutas', RoutesScreenManagement(usuario: widget.usuario)),
            Divider(color: Colors.white),
            _drawerItem(context, Icons.exit_to_app, 'Cerrar sesión', LoginScreen()),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () async {
                await _logAction(widget.usuario.correo, Tipo.baja, "Cerró sesión");
                Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        },
      tileColor: Colors.blue.shade800,
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }
}