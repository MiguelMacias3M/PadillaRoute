import 'package:flutter/material.dart';

class IncidentsScreenAdmin extends StatefulWidget {
  @override
  _IncidentsScreenAdminState createState() => _IncidentsScreenAdminState();
}

class _IncidentsScreenAdminState extends State<IncidentsScreenAdmin> {
  final TextEditingController _searchController = TextEditingController();
  List<String> incidents = [
    'Choque - Jorge',
    'Trafico - María',
    'Trafico - Pedro',
    'Vialidad cerrada - Luisa',
    'Choque - Carlos',
    'Trafico - Ana',
  ];
  List<String> filteredIncidents = [];

  @override
  void initState() {
    super.initState();
    filteredIncidents = incidents;
  }

  void _filterIncidents(String query) {
    setState(() {
      filteredIncidents = incidents
          .where((incident) => incident.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Incidencias',
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
              onChanged: _filterIncidents,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Buscar incidente',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredIncidents.length,
                itemBuilder: (context, index) {
                  return _incidentItem(filteredIncidents[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _incidentItem(String incident) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(incident.split(' - ')[0], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Usuario a cargo: ${incident.split(' - ')[1]}'),
        trailing: ElevatedButton(
          onPressed: () {
            _showIncidentDetails(context, incident);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Text('Ver incidencia', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  void _showIncidentDetails(BuildContext context, String incident) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la incidencia'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nombre de la incidencia: Choque'),
              SizedBox(height: 5),
              Text('Usuario a cargo: Juan'),
              SizedBox(height: 5),
              Text('Descripción: Choque frontal'),
              SizedBox(height: 5),
              Text('Hora y fecha: 12:31 12 de febrero 2024'),
              SizedBox(height: 5),
              Text('Ruta: Bajio'),
              SizedBox(height: 5),
              Text('Vehiculo: #108'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
