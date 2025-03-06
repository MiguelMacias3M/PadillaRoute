import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class RouteScreenU extends StatefulWidget {
  final String routeName;

  RouteScreenU({required this.routeName});

  @override
  _RouteScreenUState createState() => _RouteScreenUState();
}

class _RouteScreenUState extends State<RouteScreenU> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Set<Polyline> _polylines = {};
  String googleMapsApiKey = "TU_API_KEY_AQUI";
  List<LatLng> _stops = [
    LatLng(22.231200, -102.323500), // Parada 1
    LatLng(22.184822, -102.295224), // Parada 2
    LatLng(22.137252, -102.292187), // Parada 2
    LatLng(22.106846, -102.296969), // Parada 2
    LatLng(22.081166, -102.271852), // Parada 2

  ];
  String? _distance;
  String? _duration;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("❌ Permisos de ubicación denegados");
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      print("❌ Permisos de ubicación denegados permanentemente");
      return;
    }
    print("✅ Permisos de ubicación concedidos");
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));

      _startLocationUpdates();
      await _fetchRouteFromGoogleMaps();
    } catch (e) {
      print("❌ Error obteniendo la ubicación: $e");
    }
  }

  void _startLocationUpdates() {
    Geolocator.getPositionStream().listen((Position position) async {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    });
  }

 Future<void> _fetchRouteFromGoogleMaps() async {
  if (_currentPosition == null || _stops.isEmpty) {
    print("⚠️ No se puede calcular la ruta: No hay ubicación actual o paradas definidas.");
    return;
  }

  String origin = "${_currentPosition!.latitude},${_currentPosition!.longitude}";
  String destination = "${_stops.last.latitude},${_stops.last.longitude}";
  String waypoints = _stops.map((stop) => "${stop.latitude},${stop.longitude}").join("|");

  String url =
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=$origin&destination=$destination&waypoints=$waypoints"
      "&mode=driving&alternatives=true&key=AIzaSyAKAfaEcXLH-reGFbTDPJ2e2zseCAzh2-I";

  print("🔵 Solicitando ruta a: $url");

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = jsonDecode(response.body);
    print("📜 Respuesta de la API: ${jsonEncode(data)}");

    if (data['routes'].isEmpty) {
      print("⚠️ La API no devolvió rutas. Verifica tu clave de API y los permisos.");
      return;
    }

    // 🔥 Buscar la ruta con más puntos
    var bestRoute = data['routes'][0]; 
    for (var route in data['routes']) {
      if (route['overview_polyline']['points'].length > bestRoute['overview_polyline']['points'].length) {
        bestRoute = route;
      }
    }

    List<LatLng> routePoints = [];

    if (bestRoute.containsKey('overview_polyline')) {
      String polyline = bestRoute['overview_polyline']['points'];
      routePoints = _decodePolyline(polyline);
    } else {
      print("❌ No se encontró overview_polyline en la respuesta de la API.");
      return;
    }

    print("🟢 Total de puntos en la polilínea general: ${routePoints.length}");

    setState(() {
      _polylines.clear();
      _polylines.add(Polyline(
        polylineId: PolylineId("route"),
        color: Colors.blue,
        width: 5,
        points: routePoints,
      ));
    });

    print("✅ Polilínea agregada al mapa.");
  } else {
    print("❌ Error obteniendo la ruta: ${response.body}");
  }
}



List<LatLng> _decodePolyline(String encoded) {
  List<LatLng> points = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int shift = 0, result = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lat += deltaLat;

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1F) << shift;
      shift += 5;
    } while (byte >= 0x20);
    int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    lng += deltaLng;

    LatLng point = LatLng(lat / 1E5, lng / 1E5);
    points.add(point);
    print("📍 Punto decodificado: $point");
  }

  print("✅ Total puntos decodificados: ${points.length}");
  return points;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routeName),
        backgroundColor: Colors.blueAccent,
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
              myLocationEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setState(() {}); // 🔥 Forzamos que se renderice el mapa
              },
              markers: _stops.map((stop) => Marker(markerId: MarkerId(stop.toString()), position: stop)).toSet(),
              polylines: _polylines,
            ),
    );
  }
}
