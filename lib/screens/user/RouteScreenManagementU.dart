import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';

class RouteScreenManagementU extends StatelessWidget {
  final List<Map<String, dynamic>> routes = [
    {
      'name': 'Ruta Rincón',
      'stops': ['Rincón', 'Saltitrillo', 'Concha'],
    },
    {
      'name': 'Ruta Rincón Noche',
      'stops': ['Rincón', 'Saltitrillo', 'Concha'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, aquí podrás ver las rutas asignadas para el día de hoy',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: routes.length,
                itemBuilder: (context, index) {
                  return _routeCard(context, routes[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Map<String, dynamic> route) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.blue, width: 1),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route['name'],
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            ),
            SizedBox(height: 5),
            Wrap(
              children: route['stops']
                  .map<Widget>((stop) => Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          stop,
                          style: TextStyle(decoration: TextDecoration.underline, fontSize: 14),
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RouteScreenU(routeName: route['name'])),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: Text(
                  'Hacer ruta',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
