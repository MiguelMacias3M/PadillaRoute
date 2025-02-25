import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/MenuScreenAdmin.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';

class RoutesScreenRegister extends StatefulWidget {
  @override
  _RoutesScreenRegisterState createState() => _RoutesScreenRegisterState();
}

class _RoutesScreenRegisterState extends State<RoutesScreenRegister> {
  final TextEditingController _routeNameController = TextEditingController();
  List<String> stops = ['Saucillo', 'Bajío', 'Rincón']; // Opciones de paradas
  List<String> selectedStops = ['Saucillo', 'Bajío', 'Rincón'];
  final RutasHelper _rutasHelper = RutasHelper(RealtimeDbHelper());

  void _addStop() {
    setState(() {
      selectedStops.add('');
    });
  }

  void _removeStop(int index) {
    setState(() {
      selectedStops.removeAt(index);
    });
  }

  Future<void> _registerRoute() async {
    if (_routeNameController.text.isNotEmpty && selectedStops.isNotEmpty) {
      // Crear una nueva ruta
      Ruta nuevaRuta = Ruta(
        idRuta: DateTime.now().millisecondsSinceEpoch, // Generar un ID único
        idChofer: 1, // Asigna un ID de chofer apropiado
        nombre: _routeNameController.text,
        origen: selectedStops.first, // Puedes ajustar esto según tu lógica
        destino: selectedStops.last, // Puedes ajustar esto según tu lógica
        paradas: selectedStops,
      );

      try {
        // Guardar la ruta en la base de datos
        await _rutasHelper.setNew(nuevaRuta);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Ruta registrada con éxito!'),
          backgroundColor: Colors.green,
        ));
        // Reiniciar el formulario
        _routeNameController.clear();
        setState(() {
          selectedStops = ['Saucillo', 'Bajío', 'Rincón']; // Reiniciar paradas
        });
      } catch (e) {
        // Manejar errores
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al registrar la ruta: $e'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      // Manejar el caso de campos vacíos
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Por favor, completa todos los campos.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Crear rutas',
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
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(20.0),
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
            SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: Text(
                'Asignar paradas',
                style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontWeight: FontWeight.bold, fontSize: 17 ),
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: ListView.builder(
                itemCount: selectedStops.length,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Parada ${index + 1}'),
                      DropdownButton<String>(
                        value: selectedStops[index].isNotEmpty ? selectedStops[index] : null,
                        items: stops.map((String stop) {
                          return DropdownMenuItem<String>(
                            value: stop,
                            child: Text(stop),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedStops[index] = newValue ?? '';
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _removeStop(index),
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addStop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 234, 0),
                  shape: CircleBorder(),
                  padding: EdgeInsets.all(15),
                ),
                child: Icon(Icons.add, color: const Color.fromARGB(255, 0, 0, 0)),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: _registerRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
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
            DrawerHeader(
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
            Divider(color: Colors.white),
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
        style: TextStyle(fontSize: 16, color: Colors.white),
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
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
    );
  }
}
