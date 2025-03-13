import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';

class VehiclesScreenAssign extends StatefulWidget {
  final Ruta rutaSeleccionada; // Agregar este parámetro

  const VehiclesScreenAssign({required this.rutaSeleccionada}); // Incluir en el constructor

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

  @override
  void initState() {
    super.initState();
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    rutasHelper = RutasHelper(RealtimeDbHelper());
    _fetchData();
  }

  Future<void> _fetchData() async {
    vehicles = await vehiculosHelper.getAll();
    setState(() {
      filteredVehicles = vehicles;
    });
  }

  void _filterVehicles(String query) {
    setState(() {
      filteredVehicles = vehicles
          .where((vehicle) => vehicle.placa.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectVehicle(Vehiculo vehicle) {
    setState(() {
      selectedVehicle = vehicle.placa;
      selectedVehicleId = vehicle.idVehiculo; // Guardar el ID del vehículo seleccionado
      _searchController.text = vehicle.placa;
      filteredVehicles = vehicles;
    });
  }

  Future<void> _assignVehicleToRoute() async {
    if (selectedVehicleId != null) {
      try {
        await rutasHelper.update(widget.rutaSeleccionada.idRuta, {
          "idVehiculo": selectedVehicleId, // Actualizar solo el campo idVehiculo
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehículo asignado correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al asignar vehículo')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un vehículo primero')),
      );
    }
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
                          leading: const Icon(Icons.car_repair, color: Colors.blue),
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
            const Text('Vehículo seleccionado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
