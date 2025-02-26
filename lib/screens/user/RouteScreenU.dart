import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:padillaroutea/screens/user/IncidentsScreenRegister.dart';

class RouteScreenU extends StatefulWidget {
  final String routeName;

  RouteScreenU({required this.routeName});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  bool _isRouteStarted = false;

  void _showPassengerDialog(BuildContext context) {
    TextEditingController _passengerController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Registro de pasajeros"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Hora de llegada: 12:00"),
              SizedBox(height: 10),
              TextField(
                controller: _passengerController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Num. de personas que subieron",
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IncidentsScreenRegister()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    child: Text("Incidencia", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Parada registrada con ${_passengerController.text} personas.")),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    ),
                    child: Text("Registrar parada", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _startRoute() {
    setState(() {
      _isRouteStarted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Ruta iniciada")),
    );
  }

  void _endRoute() {
    setState(() {
      _isRouteStarted = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Viaje terminado")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(22.229896, -102.321105),
                zoom: 15,
              ),
              myLocationEnabled: true,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: _isRouteStarted ? null : _startRoute,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Text("Iniciar Ruta", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () => _showPassengerDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Text("Registrar Parada", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _isRouteStarted ? _endRoute : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                ),
                child: Text("Terminar Viaje", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
