import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class VehiclesScreenAssign extends StatefulWidget {
  final Ruta rutaSeleccionada; // Agregar este parámetro
  final Usuario usuario;

  const VehiclesScreenAssign(
      {required this.rutaSeleccionada,
      required this.usuario}); // Incluir en el constructor

  @override
  _VehiclesScreenAssignState createState() => _VehiclesScreenAssignState();
}

class _VehiclesScreenAssignState extends State<VehiclesScreenAssign> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedVehicle;
  int? selectedVehicleId;
  List<Vehiculo> vehicles = [];
  List<Vehiculo> filteredVehicles = [];

  late VehiculosHelper vehiculosHelper;
  late RutasHelper rutasHelper;

  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    rutasHelper = RutasHelper(RealtimeDbHelper());
    logAction(widget.usuario.correo, Tipo.alta,
        "Ingreso a asignacion de vehiculo", logsHelper, _logger);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      vehicles = await vehiculosHelper.getAll();
      setState(() {
        filteredVehicles = vehicles;
      });
      await logAction(widget.usuario.correo, Tipo.alta,
          "Cargó la lista de vehículos.", logsHelper, _logger);
    } catch (e) {
      _logger.e("Error al cargar vehículos: $e");
      await logAction(widget.usuario.correo, Tipo.alta,
          "Error al cargar vehículos.", logsHelper, _logger);
    }
  }

  void _filterVehicles(String query) {
    setState(() {
      filteredVehicles = vehicles
          .where((vehicle) =>
              vehicle.placa.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
    logAction(widget.usuario.correo, Tipo.modificacion,
        "Filtró vehículos con query: $query", logsHelper, _logger);
  }

  void _selectVehicle(Vehiculo vehicle) {
    setState(() {
      selectedVehicle = vehicle.placa;
      selectedVehicleId =
          vehicle.idVehiculo; // Guardar el ID del vehículo seleccionado
      _searchController.text = vehicle.placa;
      filteredVehicles = vehicles;
    });
    logAction(widget.usuario.correo, Tipo.modificacion,
        "Seleccionó vehículo: ${vehicle.placa}", logsHelper, _logger);
  }

  Future<void> _assignVehicleToRoute() async {
    if (selectedVehicleId != null) {
      try {
        await rutasHelper.update(widget.rutaSeleccionada.idRuta, {
          "idVehiculo":
              selectedVehicleId, // Actualizar solo el campo idVehiculo
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo asignado correctamente')),
        );
        await logAction(
            widget.usuario.correo,
            Tipo.modificacion,
            "Asignó vehículo ID $selectedVehicleId a la ruta ID ${widget.rutaSeleccionada.idRuta}",
            logsHelper,
            _logger);

        Navigator.pop(context);
      } catch (e) {
        _logger.e("Error al asignar vehículo: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al asignar vehículo')),
        );
        await logAction(widget.usuario.correo, Tipo.modificacion,
            "Error al asignar vehículo.", logsHelper, _logger);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo primero')),
      );
      await logAction(widget.usuario.correo, Tipo.baja,
          "Intentó asignar un vehículo sin seleccionar.", logsHelper, _logger);
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
        title: const Text(
          'Asignar vehículo a la ruta',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
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
      drawer: buildDrawer(
          context, widget.usuario, _menuLateral, 'Asignar vehículo a la ruta'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ruta seleccionada:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.rutaSeleccionada.nombre),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _searchController,
              onChanged: _filterVehicles,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Buscar vehículo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: filteredVehicles.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredVehicles.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading:
                              const Icon(Icons.car_repair, color: Colors.blue),
                          title: Text(filteredVehicles[index].marca),
                          subtitle: Text(
                            'Modelo: ${filteredVehicles[index].modelo}\nPlaca: ${filteredVehicles[index].placa}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => _selectVehicle(filteredVehicles[index]),
                        );
                      },
                    )
                  : const Center(child: Text('No se encontraron vehículos')),
            ),
            const SizedBox(height: 10),
            const Text('Vehículo seleccionado:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.car_repair, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text(selectedVehicle ?? 'Ningún vehículo seleccionado'),
                  if (selectedVehicle != null)
                    Text(
                      '\nMarca: ${vehicles.firstWhere((v) => v.placa == selectedVehicle).marca}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _assignVehicleToRoute,
                child: const Text('Asignar Vehículo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
