import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/screens/RoutesScreenManagement.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';

class RoutesScreenRegister extends StatefulWidget {
  @override
  _RoutesScreenRegisterState createState() => _RoutesScreenRegisterState();
}

class _RoutesScreenRegisterState extends State<RoutesScreenRegister> {
  final TextEditingController _routeNameController = TextEditingController();
  List<Parada> stops = []; // Lista de paradas
  List<Parada?> selectedStops = []; // Paradas seleccionadas
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());
  final ParadasHelper _paradasHelper = ParadasHelper(RealtimeDbHelper());

  @override
  void initState() {
    super.initState();
    _loadStops(); // Cargar las paradas al iniciar
    _initializeDefaultStop(); // Inicializar parada por defecto
  }

  Future<void> _loadStops() async {
    List<Parada> allStops = await _paradasHelper.getAll();
    setState(() {
      stops = allStops;
    });
  }

  void _initializeDefaultStop() {
    setState(() {
      selectedStops = [null]; // Inicializa con una parada vacía
    });
  }

  void _addStop() {
    setState(() {
      selectedStops.add(null); // Añadir un nuevo campo vacío
    });
  }

  void _removeStop(int index) {
    setState(() {
      selectedStops.removeAt(index);
    });
  }

  Future<void> _registerRoute() async {
    if (_routeNameController.text.isNotEmpty && selectedStops.isNotEmpty) {
      // Filtrar paradas seleccionadas que no son nulas
      final validStops = selectedStops.where((stop) => stop != null).toList();
      if (validStops.isNotEmpty) {
        // Crear una nueva ruta
        Ruta nuevaRuta = Ruta(
          idRuta: DateTime.now().millisecondsSinceEpoch,
          idChofer: 1,
          idVehiculo: 1,
          nombre: _routeNameController.text,
          origen: validStops.first!.nombre,
          destino: validStops.last!.nombre,
          paradas: validStops.map((stop) => stop!.nombre).toList(),
        );

        try {
          // Guardar la ruta en la base de datos
          await _rutasHelper.setNew(nuevaRuta);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ruta registrada con éxito!'),
            backgroundColor: Colors.green,
          ));

          // Redirigir a la pantalla de gestión de rutas después del registro
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoutesScreenManagement()),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al registrar la ruta: $e'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, selecciona al menos una parada.'),
          backgroundColor: Colors.orange,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, completa todos los campos.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear rutas',
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
      drawer: _buildDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _routeNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de la ruta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'Asignar paradas',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
            const SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: selectedStops.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Parada ${index + 1}'),
                      DropdownButton<Parada?>(
                        value: selectedStops[index],
                        items: stops.map((Parada parada) {
                          return DropdownMenuItem<Parada?>(
                            value: parada,
                            child: Text(parada.nombre),
                          );
                        }).toList(),
                        onChanged: (Parada? newValue) {
                          setState(() {
                            selectedStops[index] = newValue; // Guardar la parada seleccionada
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeStop(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 234, 0),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _registerRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Registrar ruta',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
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
            const DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                    child: Icon(Icons.directions_bus, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión de Rutas',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', MenuScreenAdmin()),
            const Divider(color: Colors.white),
            _drawerItem(context, Icons.exit_to_app, 'Cerrar sesión', null),
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
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
      tileColor: Colors.blue.shade800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }
}
