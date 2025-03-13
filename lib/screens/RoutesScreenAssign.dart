import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';

class RoutesScreenAssign extends StatefulWidget {
  final Ruta rutaSeleccionada;

  RoutesScreenAssign({required this.rutaSeleccionada});

  @override
  _RoutesScreenAssignState createState() => _RoutesScreenAssignState();
}

class _RoutesScreenAssignState extends State<RoutesScreenAssign> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedUser;
  int? selectedUserId;
  List<Usuario> users = [];
  List<Usuario> filteredUsers = [];

  late UsuariosHelper usuariosHelper;
  late RutasHelper rutasHelper;
  late VehiculosHelper vehiculosHelper;

  @override
  void initState() {
    super.initState();
    usuariosHelper = UsuariosHelper(RealtimeDbHelper());
    rutasHelper = RutasHelper(RealtimeDbHelper());
    _fetchData();
  }

  Future<void> _fetchData() async {
    users = await usuariosHelper.getAll();
    setState(() {
      filteredUsers = users;
    });
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user.nombre.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _selectUser(Usuario user) {
    setState(() {
      selectedUser = user.nombre;
      selectedUserId = user.idUsuario; // Guardar el ID del usuario seleccionado
      _searchController.text = user.nombre;
      filteredUsers = users;
    });
  }

  Future<void> _assignUserToRoute() async {
    if (selectedUserId != null) {
      try {
        await rutasHelper.update(widget.rutaSeleccionada.idRuta, {
          "idChofer": selectedUserId, // Actualizar solo el campo idChofer
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario asignado correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar usuario')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona un usuario primero')),
      );
    }
  }

    Future<void> _assignVehicleToRoute() async {
    if (selectedUserId != null) {
      try {
        await rutasHelper.update(widget.rutaSeleccionada.idRuta, {
          "idChofer": selectedUserId, // Actualizar solo el campo idChofer
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vehículo asignada correctamente')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al asignar vehículo')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona un vehículo primero')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Asignar usuario a ruta',
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
            Text(
              'Ruta seleccionada:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(widget.rutaSeleccionada.nombre),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _searchController,
              onChanged: _filterUsers,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 5),
            Expanded(
              child: filteredUsers.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(filteredUsers[index].nombre),
                          onTap: () => _selectUser(filteredUsers[index]),
                        );
                      },
                    )
                  : Center(child: Text('No se encontraron usuarios')),
            ),
            SizedBox(height: 10),
            Text('Usuario seleccionado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, color: Colors.blue),
                  SizedBox(width: 10),
                  Text(selectedUser ?? 'Ningún usuario seleccionado'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _assignUserToRoute,
                child: Text('Asignar Usuario'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
