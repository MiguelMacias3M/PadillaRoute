import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/paradas_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/parada.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral

class RoutesScreenEdit extends StatefulWidget {
  final int routeId; // Cambiado para recibir el ID de la ruta
  final Ruta ruta; // Recibe la ruta a editar
  final Usuario usuario;

  const RoutesScreenEdit(
      {required this.routeId, required this.ruta, required this.usuario});

  @override
  _RoutesScreenEditState createState() => _RoutesScreenEditState();
}

class _RoutesScreenEditState extends State<RoutesScreenEdit> {
  final TextEditingController _routeNameController = TextEditingController();
  List<Parada> stops = []; // Lista de paradas
  List<Parada> selectedStops = []; // Paradas seleccionadas
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());
  final ParadasHelper _paradasHelper = ParadasHelper(RealtimeDbHelper());

  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  @override
  void initState() {
    print(
        'Parada añadida. Total paradas seleccionadas: ${selectedStops.length}');
    super.initState();
    _logAction(widget.usuario.correo, Tipo.alta, "Ingreso a edicion de rutas");
    _loadStops(); // Cargar las paradas al iniciar
    _initializeSelectedStops(); // Inicializa las paradas seleccionadas
    _routeNameController.text = widget.ruta.nombre; // Cargar nombre de la ruta
  }

  Future<void> _loadStops() async {
    try {
      List<Parada> allStops = await _paradasHelper.getAll();
      setState(() {
        stops = allStops;
      });

      print('Paradas cargadas: ${stops.length}');

      // Inicializar paradas seleccionadas después de cargar las paradas
      _initializeSelectedStops();
      await _logAction(widget.usuario.correo, Tipo.modificacion,
          'Paradas cargadas correctamente');
    } catch (e) {
      print('Error al cargar las paradas: $e');
      _logger.e('Error al cargar las paradas: $e');
      await _logAction(widget.usuario.correo, Tipo.modificacion,
          'Error al cargar las paradas: $e');
    }
  }

  void _initializeSelectedStops() {
    setState(() {
      selectedStops = widget.ruta.paradas.map((nombre) {
        var parada = stops.firstWhere(
          (parada) => parada.nombre == nombre,
          orElse: () => Parada(
            idParada: 0,
            nombre: '',
            horaLlegada: '',
            horaSalida: '',
            coordenadas: '',
          ),
        );
        return parada;
      }).toList();
      print('Paradas seleccionadas inicializadas: ${selectedStops.length}');
    });
  }

  void _addStop() {
    setState(() {
      selectedStops.add(Parada(
        idParada: 0, // ID por defecto
        nombre: '',
        horaLlegada: '',
        horaSalida: '',
        coordenadas: '',
      )); // Añadir un nuevo campo vacío
      print(
          'Parada añadida. Total paradas seleccionadas: ${selectedStops.length}'); // Debug
    });
    _logAction(widget.usuario.correo, Tipo.alta, 'Se agregó una nueva parada');
  }

  void _removeStop(int index) {
    String paradaEliminada = selectedStops[index].nombre;
    setState(() {
      selectedStops.removeAt(index);
      print(
          'Parada eliminada. Total paradas seleccionadas: ${selectedStops.length}'); // Debug
    });
    _logAction(widget.usuario.correo, Tipo.baja,
        'Se eliminó la parada: $paradaEliminada');
  }

  Future<void> _updateRoute() async {
    if (_routeNameController.text.isNotEmpty && selectedStops.isNotEmpty) {
      final validStops =
          selectedStops.where((stop) => stop.nombre.isNotEmpty).toList();
      if (validStops.isNotEmpty) {
        Ruta updatedRuta = Ruta(
          idRuta: widget.ruta.idRuta,
          idChofer: widget.ruta.idChofer,
          idVehiculo: 1,
          nombre: _routeNameController.text,
          origen: validStops.first.nombre,
          destino: validStops.last.nombre,
          paradas: validStops.map((stop) => stop.nombre).toList(),
        );

        try {
          await _rutasHelper.update(updatedRuta.idRuta, updatedRuta.toJson());
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Ruta actualizada con éxito!'),
            backgroundColor: Colors.green,
          ));
          await _logAction(widget.usuario.correo, Tipo.modificacion,
              'Ruta actualizada: ${updatedRuta.nombre}');

          Navigator.pop(context); // Regresar a la pantalla anterior
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error al actualizar la ruta: $e'),
            backgroundColor: Colors.red,
          ));
          await _logAction(widget.usuario.correo, Tipo.modificacion,
              'Error al actualizar la ruta: $e');
        }
      } else {
        await _logAction(widget.usuario.correo, Tipo.modificacion,
            'Error al actualizar la ruta: paradas no seleccionadas');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Por favor, selecciona al menos una parada.'),
          backgroundColor: Colors.orange,
        ));
      }
    } else {
      await _logAction(widget.usuario.correo, Tipo.modificacion,
          'Error al actualizar la ruta: Campos sin completar');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Por favor, completa todos los campos.'),
        backgroundColor: Colors.orange,
      ));
    }
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
  
void _menuLateral(BuildContext context) {
  // Solo cerrar el Drawer (menú lateral)
  Navigator.pop(context); // Esto cierra el menú lateral
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Editar ruta',
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
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Editar ruta'),
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
            const Text(
              'Asignar paradas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: selectedStops.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Parada ${index + 1}'),
                      DropdownButton<Parada>(
                        value: selectedStops[index].idParada != 0
                            ? selectedStops[index]
                            : null,
                        items: stops.map((Parada parada) {
                          return DropdownMenuItem<Parada>(
                            value: parada,
                            child: Text(parada.nombre),
                          );
                        }).toList(),
                        onChanged: (Parada? newValue) {
                          setState(() {
                            selectedStops[index] = newValue ??
                                Parada(
                                  idParada: 0,
                                  nombre: '',
                                  horaLlegada: '',
                                  horaSalida: '',
                                  coordenadas: '',
                                ); // Guardar la parada seleccionada
                            print(
                                'Parada seleccionada en dropdown: ${selectedStops[index].nombre}'); // Debug
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
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: _updateRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Actualizar ruta',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
