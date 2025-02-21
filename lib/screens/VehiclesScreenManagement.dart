import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/vehiculo.dart';
import 'package:padillaroutea/services/realtime_db_services/vehiculos_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/screens/VehiclesScreenEdit.dart';

class VehiclesScreenManagement extends StatefulWidget {
  @override
  _VehiclesScreenManagementState createState() => _VehiclesScreenManagementState();
}

class _VehiclesScreenManagementState extends State<VehiclesScreenManagement> {
  List<Vehiculo> vehiculos = [];
  late VehiculosHelper vehiculosHelper;

  @override
  void initState() {
    super.initState();
    vehiculosHelper = VehiculosHelper(RealtimeDbHelper());
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    List<Vehiculo> vehicleList = await vehiculosHelper.getAll();
    setState(() {
      vehiculos = vehicleList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Gestión de vehículos',
          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: vehiculos.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: vehiculos.length,
                      itemBuilder: (context, index) {
                        return _vehicleCard(context, vehiculos[index]);
                      },
                    ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/vehicles_register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Registrar vehículo',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleCard(BuildContext context, Vehiculo vehiculo) {
  Color getStatusColor(Estatus estatus) {
    switch (estatus) {
      case Estatus.activo:
        return Colors.green;
      case Estatus.inactivo:
        return Colors.red;
      case Estatus.mantenimiento:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 3,
    child: Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vehiculo.marca,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            vehiculo.modelo,
            style: TextStyle(fontSize: 16, color: Colors.blueAccent),
          ),
          SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.circle, color: getStatusColor(vehiculo.estatus), size: 14),
              SizedBox(width: 5),
              Text(
                vehiculo.estatus.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(vehiculo.estatus),
                ),
              ),
            ],
          ),
          Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VehiclesScreenEdit(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Editar',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
