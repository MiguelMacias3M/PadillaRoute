import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/UserScreenManagement.dart';

class UserScreenManagement extends StatefulWidget {
  @override
  _UserScreenManagementState createState() => _UserScreenManagementState();
}

class _UserScreenManagementState extends State<UserScreenManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<String> users = [
    'Manuel Catorena Mejia',
    'Juan Pérez',
    'Ana López',
    'Carlos Ramírez',
    'María González'
  ];
  List<String> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    filteredUsers = users;
  }

  void _filterUsers(String query) {
    setState(() {
      filteredUsers = users
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
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
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  return _userItem(filteredUsers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userItem(String userName) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(userName, style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gestión de $userName en desarrollo...')),
          );
        },
      ),
    );
  }
}
