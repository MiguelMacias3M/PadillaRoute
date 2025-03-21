import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/UserScreenEdit.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class UserScreenManagement extends StatefulWidget {
  final Usuario usuario;

  UserScreenManagement({required this.usuario});
  @override
  _UserScreenManagementState createState() => _UserScreenManagementState();
}

class _UserScreenManagementState extends State<UserScreenManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> users = [];
  List<Usuario> filteredUsers = [];
  late VehiculosHelper vehiculosHelper;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    usuariosHelper = UsuariosHelper(RealtimeDbHelper());
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    _logAction(
        widget.usuario.correo, Tipo.alta, "Ingreso a consulta de usuarios");
    _loadUsers();
  }

  // Cargar usuarios desde la base de datos
  Future<void> _loadUsers() async {
    try {
      List<Usuario> userList = await usuariosHelper.getAll();
      setState(() {
        users = userList;
        filteredUsers = userList;
      });
      await _logAction(
          widget.usuario.correo, Tipo.alta, "Cargó la lista de usuarios");
    } catch (e) {
      _logger.e("Error al cargar usuarios: $e");
      await _logAction(widget.usuario.correo, Tipo.modificacion,
          "Error al cargar usuarios: $e");
    }
  }

  // Filtrar usuarios por nombre
  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) =>
              user.nombre.toLowerCase().contains(query.toLowerCase()) ||
              user.apellidos.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Obtener el vehículo asignado a un usuario
  Future<Vehiculo?> _getAssignedVehicle(int? idVehiculo) async {
    if (idVehiculo != null) {
      return await vehiculosHelper.get(idVehiculo);
    }
    return null;
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
          'Gestión de Usuarios',
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
              onChanged: (value) {
                _filterUsers(value);
                _logAction(widget.usuario.correo, Tipo.modificacion,
                    "Filtró usuarios con: $value");
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(
                      child: CircularProgressIndicator()) // Cargando usuarios
                  : ListView.builder(
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return _userItem(context, filteredUsers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userItem(BuildContext context, Usuario usuario) {
    return FutureBuilder<Vehiculo?>(
      future: _getAssignedVehicle(usuario.idVehiculo),
      builder: (context, snapshot) {
        String vehicleInfo = 'Sin vehículo asignado';
        if (snapshot.connectionState == ConnectionState.waiting) {
          vehicleInfo = 'Cargando vehículo...';
        } else if (snapshot.hasData) {
          Vehiculo? vehiculo = snapshot.data;
          if (vehiculo != null) {
            vehicleInfo =
                'Vehículo: ${vehiculo.marca} ${vehiculo.modelo} (${vehiculo.placa})';
          }
        }

        return Card(
          margin: EdgeInsets.symmetric(vertical: 10),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                title: Text('${usuario.nombre} ${usuario.apellidos}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(usuario.correo),
                    SizedBox(height: 5),
                    // Mostrar vehículo solo si no es gerente o administrativo
                    if (usuario.rol != Rol.gerente &&
                        usuario.rol != Rol.administrativo)
                      Text(vehicleInfo),
                  ],
                ),
                onTap: () async {
                  await _logAction(widget.usuario.correo, Tipo.modificacion,
                      "Accedió a la edición de usuario: ${usuario.correo}");

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserScreenEdit(
                          usuarioSeleccionado: usuario,
                          usuario: widget.usuario),
                    ),
                  ).then((_) {
                    // Recargar los usuarios después de editar
                    _loadUsers();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
