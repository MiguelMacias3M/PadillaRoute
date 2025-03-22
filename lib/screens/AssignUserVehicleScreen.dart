import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:padillaroutea/services/fcm_service.dart';

class AssignUserVehicleScreen extends StatefulWidget {
  final Ruta rutaSeleccionada;
  final Usuario usuario;

  const AssignUserVehicleScreen({
    required this.rutaSeleccionada,
    required this.usuario,
  });

  @override
  _AssignUserVehicleScreenState createState() =>
      _AssignUserVehicleScreenState();
}

class _AssignUserVehicleScreenState extends State<AssignUserVehicleScreen> {
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _vehicleSearchController =
      TextEditingController();
  String? selectedUser;
  int? selectedUserId;
  String? selectedVehicle;
  int? selectedVehicleId;

  List<Usuario> users = [];
  List<Usuario> filteredUsers = [];
  List<Vehiculo> vehicles = [];
  List<Vehiculo> filteredVehicles = [];

  late VehiculosHelper vehiculosHelper;
  late RutasHelper rutasHelper;
  late UsuariosHelper usuariosHelper;
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    usuariosHelper = UsuariosHelper(RealtimeDbHelper());
    rutasHelper = RutasHelper(RealtimeDbHelper());
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      vehicles = await vehiculosHelper.getAll();
      users = await usuariosHelper.getAll();
      setState(() {
        filteredVehicles = vehicles;
        filteredUsers = users;
      });
    } catch (e) {
      _logger.e("Error al cargar datos: $e");
    }
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where(
              (user) => user.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _filterVehicles(String query) {
    setState(() {
      filteredVehicles = vehicles
          .where((vehicle) =>
              vehicle.placa.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectUser(Usuario user) {
    setState(() {
      selectedUser = user.nombre;
      selectedUserId = user.idUsuario;
      _userSearchController.text = user.nombre;
    });
  }

  void _selectVehicle(Vehiculo vehicle) {
    setState(() {
      selectedVehicle = vehicle.placa;
      selectedVehicleId = vehicle.idVehiculo;
      _vehicleSearchController.text = vehicle.placa;
    });
  }

  Future<void> _assignUserAndVehicle() async {
    if (selectedUserId != null && selectedVehicleId != null) {
      try {
        // Actualizar la ruta
        await rutasHelper.update(widget.rutaSeleccionada.idRuta, {
          "idChofer": selectedUserId,
          "idVehiculo": selectedVehicleId,
        });

        // Actualizar el idVehiculo en el registro del usuario
        await usuariosHelper.update(selectedUserId!, {
          "idVehiculo": selectedVehicleId,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Usuario y vehículo asignados correctamente')),
        );

        // Enviar notificación FCM
        await _sendAssignmentNotification();
        await logAction(
          widget.usuario.correo,
          Tipo.modificacion,
          "Asignó usuario ID $selectedUserId y vehículo ID $selectedVehicleId a la ruta ${widget.rutaSeleccionada.idRuta}",
          logsHelper,
          _logger,
        );

        Navigator.pop(context);
      } catch (e) {
        _logger.e("Error al asignar: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al asignar usuario y vehículo')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un usuario y un vehículo')),
      );
    }
  }

  Future<void> _sendAssignmentNotification() async {
    try {
      // Obtener el FCM Token del usuario seleccionado
      final fcmToken = await usuariosHelper.getUserFCMToken(selectedUserId!);
      
      if (fcmToken != null && fcmToken.isNotEmpty) {
        final accessToken = await getAccessToken();
        
        // Usar la nueva función para enviar la notificación al usuario específico
        await sendFCMMessageToUser(
          "Asignación de Chofer y Vehículo",
          "${selectedUser} se te ha asignado el vehículo ${selectedVehicle} y la ruta a cubrir es: ${widget.rutaSeleccionada.nombre}.",
          fcmToken, // Token FCM del usuario
          accessToken,
        );
      } else {
        print(
            "10- No se encontró el FCM Token para el usuario seleccionado en la pantalla de asignacion.");
      }
    } catch (e) {
      print(
          "11- Error al enviar la notificación de asignación: $e, en la pantalla de asignacion");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asignar Usuario y Vehículo'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Ruta seleccionada
            Text('Ruta seleccionada: ${widget.rutaSeleccionada.nombre}'),
            const SizedBox(height: 15),

            // Buscar usuario
            TextField(
              controller: _userSearchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredUsers[index].nombre),
                    onTap: () => _selectUser(filteredUsers[index]),
                  );
                },
              ),
            ),

            // Buscar vehículo
            TextField(
              controller: _vehicleSearchController,
              onChanged: _filterVehicles,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar vehículo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredVehicles.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredVehicles[index].placa),
                    onTap: () => _selectVehicle(filteredVehicles[index]),
                  );
                },
              ),
            ),

            // Botón de asignación
            ElevatedButton(
              onPressed: _assignUserAndVehicle,
              child: const Text('Asignar Usuario y Vehículo'),
            ),
          ],
        ),
      ),
    );
  }
}
