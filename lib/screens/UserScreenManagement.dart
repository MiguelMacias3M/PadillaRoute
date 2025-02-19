import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/UserScreenEdit.dart';

class UserScreenManagement extends StatefulWidget {
  @override
  _UserScreenManagementState createState() => _UserScreenManagementState();
}

class _UserScreenManagementState extends State<UserScreenManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Usuario> users = [];
  List<Usuario> filteredUsers = [];
  late UsuariosHelper usuariosHelper;

  @override
  void initState() {
    super.initState();
    usuariosHelper = UsuariosHelper(RealtimeDbHelper());
    _loadUsers();
  }

  // Cargar usuarios desde la base de datos
  Future<void> _loadUsers() async {
    List<Usuario> userList = await usuariosHelper.getAll();
    setState(() {
      users = userList;
      filteredUsers = userList;
    });
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
              'assets/logo.png', // Asegúrate de tener el logo en la carpeta assets
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
              onChanged: _filterUsers,
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
                  ? Center(child: CircularProgressIndicator()) // Cargando usuarios
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
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(usuario.nombre + ' ' + usuario.apellidos,
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(usuario.correo),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserScreenEdit()),
          );
        },
      ),
    );
  }
}
