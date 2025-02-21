import 'package:flutter/material.dart';

class RoutesScreenAssign extends StatefulWidget {
  @override
  _RoutesScreenAssignState createState() => _RoutesScreenAssignState();
}

class _RoutesScreenAssignState extends State<RoutesScreenAssign> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedUser;
  List<String> users = [
    'Jorge Manuel Lopez',
    'Bruno Martinez',
    'Carlos Ramirez',
    'Maria Gonzalez',
    'Ana Fernandez'
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

  void _selectUser(String user) {
    setState(() {
      selectedUser = user;
      _searchController.text = user;
      filteredUsers = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Asignar rutas',
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
                          title: Text(filteredUsers[index]),
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
            SizedBox(height: 15),
            Text('Ruta asignada', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Chip(label: Text('Rincón noche')),
            SizedBox(height: 15),
            Text('Horario', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Chip(label: Text('20:00')),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Asignar ruta',
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
