import 'package:flutter/material.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';
import 'package:padillaroutea/screens/user/SupportScreenUser.dart';

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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 4,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, aquí podrás ver las rutas asignadas para el día de hoy',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade600, Colors.blue.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                route['name'],
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              SizedBox(height: 5),
              Wrap(
                children: route['stops']
                    .map<Widget>((stop) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            stop,
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontSize: 14,
                                color: Colors.white70),
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
                      MaterialPageRoute(
                          builder: (context) => RouteScreenU(routeName: route['name'])),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    'Hacer ruta',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue.shade700,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 35,
                    child: Icon(Icons.person, color: Colors.blue, size: 40),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Usuario Activo',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio', RouteScreenManagementU()),
            _drawerItem(context, Icons.support_agent, 'Soporte', SupportScreenUser()),
            Spacer(),
            _drawerItem(context, Icons.exit_to_app, 'Cerrar sesión', LoginScreen(), color: const Color.fromARGB(255, 255, 255, 255)),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(BuildContext context, IconData icon, String title, Widget? screen, {Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: color),
      ),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        }
      },
    );
  }
}
