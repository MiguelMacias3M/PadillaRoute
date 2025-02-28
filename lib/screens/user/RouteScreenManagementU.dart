import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/ruta.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/screens/user/RouteScreenU.dart';
import 'package:padillaroutea/screens/user/SupportScreenUser.dart';
import 'package:padillaroutea/services/realtime_db_services/rutas_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/loginscreen.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';

class RouteScreenManagementU extends StatefulWidget {
  final Usuario chofer;

  RouteScreenManagementU({required this.chofer});

  @override
  _RouteScreenManagementUState createState() => _RouteScreenManagementUState();
}

class _RouteScreenManagementUState extends State<RouteScreenManagementU> {
  final RutasHelper rutasHelper = RutasHelper(RealtimeDbHelper());
  final VehiculosHelper vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
  List<Ruta> rutas = [];
  bool isLoading = true;
  Vehiculo? vehiculoAsignado;

  @override
  void initState() {
    super.initState();
    _loadRutas();
    _loadVehiculo();
  }

  Future<void> _loadRutas() async {
    try {
      List<Ruta> todasLasRutas = await rutasHelper.getAll();
      List<Ruta> rutasFiltradas = todasLasRutas
          .where((ruta) => ruta.idChofer == widget.chofer.idUsuario)
          .toList();

      setState(() {
        rutas = rutasFiltradas;
        isLoading = false;
      });
    } catch (e) {
      print("Error cargando rutas: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadVehiculo() async {
    if (widget.chofer.idVehiculo != null) {
      try {
        Vehiculo? vehiculo =
            await vehiculosHelper.get(widget.chofer.idVehiculo!);
        setState(() {
          vehiculoAsignado = vehiculo;
        });
      } catch (e) {
        print("Error cargando vehículo: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bienvenido, ${widget.chofer.nombre}',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : rutas.isEmpty
                    ? Center(
                        child: Text(
                          'No tienes rutas asignadas',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      )
                    : ListView.builder(
                        itemCount: rutas.length,
                        itemBuilder: (context, index) {
                          return _routeCard(context, rutas[index]);
                        },
                      ),
          ),
          if (vehiculoAsignado != null) _floatingVehicleInfo(),
        ],
      ),
    );
  }

  Widget _floatingVehicleInfo() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'El vehículo que te fue asignado es:',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_bus, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  '${vehiculoAsignado!.marca} - ${vehiculoAsignado!.modelo} - ${vehiculoAsignado!.placa}',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeCard(BuildContext context, Ruta ruta) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                ruta.nombre,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white),
              ),
              SizedBox(height: 5),
              Wrap(
                children: ruta.paradas
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
                          builder: (context) =>
                              RouteScreenU(routeName: ruta.nombre)),
                    );
                  },
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
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
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
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
                    widget.chofer.nombre,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            _drawerItem(context, Icons.home, 'Inicio',
                RouteScreenManagementU(chofer: widget.chofer)),
            _drawerItem(
                context, Icons.support_agent, 'Soporte', SupportScreenUser()),
            Spacer(),
            _drawerItem(
                context, Icons.exit_to_app, 'Cerrar sesión', LoginScreen()),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, IconData icon, String title, Widget screen) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: TextStyle(fontSize: 16, color: Colors.white)),
      onTap: () => Navigator.push(
          context, MaterialPageRoute(builder: (context) => screen)),
    );
  }
}
