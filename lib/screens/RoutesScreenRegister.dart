import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/RoutesScreenManagement.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class RoutesScreenRegister extends StatefulWidget {
  final Usuario usuario;

  RoutesScreenRegister({required this.usuario});
  @override
  _RoutesScreenRegisterState createState() => _RoutesScreenRegisterState();
}

class _RoutesScreenRegisterState extends State<RoutesScreenRegister> {
  final TextEditingController _routeNameController = TextEditingController();
  List<Parada> stops = []; // Lista de paradas
  List<Parada?> selectedStops = []; // Paradas seleccionadas
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());
  final ParadasHelper _paradasHelper = ParadasHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    logAction(widget.usuario.correo, Tipo.alta, "Ingreso a registro de rutas",
        logsHelper, _logger);
    _loadStops(); // Cargar las paradas al iniciar
    _initializeDefaultStop(); // Inicializar parada por defecto
  }

  Future<void> _loadStops() async {
    try {
      List<Parada> allStops = await _paradasHelper.getAll();
      setState(() {
        stops = allStops;
      });
      logAction(widget.usuario.correo, Tipo.alta,
          "Cargó las paradas disponibles", logsHelper, _logger);
    } catch (e) {
      logAction(widget.usuario.correo, Tipo.alta, "Error al cargar paradas: $e",
          logsHelper, _logger);
    }
  }

  void _initializeDefaultStop() {
    setState(() {
      selectedStops = [null]; // Inicializa con una parada vacía
    });
    logAction(widget.usuario.correo, Tipo.alta,
        "Inicializó la selección de paradas", logsHelper, _logger);
  }

  void _addStop() {
    setState(() {
      selectedStops.add(null); // Añadir un nuevo campo vacío
    });
    logAction(widget.usuario.correo, Tipo.alta,
        "Agregó un nuevo campo de parada", logsHelper, _logger);
  }

  void _removeStop(int index) {
    setState(() {
      selectedStops.removeAt(index);
    });
    logAction(widget.usuario.correo, Tipo.baja,
        "Eliminó la parada en el índice $index", logsHelper, _logger);
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
          logAction(
              widget.usuario.correo,
              Tipo.alta,
              "Registró una nueva ruta: ${nuevaRuta.nombre}",
              logsHelper,
              _logger);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ruta registrada con éxito!'),
            backgroundColor: Colors.green,
          ));

          // Redirigir a la pantalla de gestión de rutas después del registro
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    RoutesScreenManagement(usuario: widget.usuario)),
          );
        } catch (e) {
          logAction(widget.usuario.correo, Tipo.alta,
              "Error al registrar ruta: $e", logsHelper, _logger);
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

  void _menuLateral(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
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
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Crear rutas'),
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
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 17),
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
                            selectedStops[index] =
                                newValue; // Guardar la parada seleccionada
                          });
                          logAction(
                              widget.usuario.correo,
                              Tipo.modificacion,
                              "Seleccionó la parada ${newValue?.nombre}",
                              logsHelper,
                              _logger);
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
                child:
                    const Icon(Icons.add, color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _registerRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
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
}
