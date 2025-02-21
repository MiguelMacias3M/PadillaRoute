import 'package:flutter/material.dart';

class StopScreenManagement extends StatefulWidget {
  @override
  _StopScreenManagementState createState() => _StopScreenManagementState();
}

class _StopScreenManagementState extends State<StopScreenManagement> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> stops = [
    {
      'name': 'Bajío',
      'address': 'C. Arellano Randel #102, Bajío, Rincón de Romos',
      'arrival': '14:00',
      'departure': '14:05',
      'wait': '5 min'
    },
    {
      'name': 'Saltillito',
      'address': 'C. Arellano Randel #102, Bajío, Rincón de Romos',
      'arrival': '14:00',
      'departure': '14:05',
      'wait': '5 min'
    }
  ];
  List<Map<String, String>> filteredStops = [];

  @override
  void initState() {
    super.initState();
    filteredStops = stops;
  }

  void _filterStops(String query) {
    setState(() {
      filteredStops = stops
          .where((stop) => stop['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de paradas',
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
              controller: _searchController,
              onChanged: _filterStops,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar parada',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStops.length,
                itemBuilder: (context, index) {
                  return _stopCard(filteredStops[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _stopCard(Map<String, String> stop) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(stop['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 5),
            Text('Dirección: ${stop['address']}',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text('Hora de llegada: ${stop['arrival']}', style: TextStyle(fontSize: 14)),
            Text('Hora de salida: ${stop['departure']}', style: TextStyle(fontSize: 14)),
            Text('Espera: ${stop['wait']}', style: TextStyle(fontSize: 14)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                  child: Text('Editar', style: TextStyle(color: Colors.black)),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Eliminar', style: TextStyle(color: Colors.white)),
                ),
              ],
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
                    child: Icon(Icons.local_parking, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Gestión de Paradas',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', null),
            _drawerItem(context, Icons.directions_bus, 'Rutas', null),
            _drawerItem(context, Icons.warning_amber, 'Incidencias', null),
            _drawerItem(context, Icons.settings, 'Configuración', null),
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
