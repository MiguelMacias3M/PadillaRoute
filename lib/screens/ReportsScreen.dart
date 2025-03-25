import 'package:padillaroutea/screens/menulateral.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/incidentes_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/file_generator/excel_generator.dart';
import 'package:padillaroutea/models/realtimeDB_models/viaje_registro.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:padillaroutea/screens/registroDeLogs.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required usuario});
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = 'Día';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedDay;
  int? _selectedMonth;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  late RealtimeDbHelper database;
  late DatabaseReference ref;

  Future<DateTime> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        if (_selectedFilter == 'Día') {
          _selectedDay = picked;
        } else if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      print(picked);
      return picked;
      
    } else {
      throw Exception("No date selected");
    }

  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }
    return false;
  }

  Future<List<IncidenteRegistro>> getIncidentes(int year) {
    database = RealtimeDbHelper();
    IncidentesHelper incidentesHelper = IncidentesHelper(database);

    switch (_selectedFilter) {
      case 'Día':
        return incidentesHelper.fetchByDate(_selectedDay!);

      case 'Semana':
        return incidentesHelper.fetchByDateRange(_startDate!, _endDate!);

      case 'Mes':
        return incidentesHelper.fetchByMonth(year, _selectedMonth!);

      default:
        return Future.value([]);
    }
  }

  List<String> getColumnNames(String collection) {
    if (collection == "incidentes_registro") {
      return IncidenteRegistro.getKeys();
    } else if (collection == "viajes_registro") {
      return ViajeRegistro.getKeys();
    } else {
      throw Exception("No se encontró la colección: $collection");
    }
  }

  void _generateReport() async {
    // SOLICITAR PERMISO DE ALMACENAMIENTO
    if (!(await _requestStoragePermission())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('PERMISO DENEGADO. NO SE PUEDE GUARDAR EL ARCHIVO')),
      );
    }

    int year = 2025;
    int month = _selectedMonth ?? 1;
    List<String> columnNames = getColumnNames("incidentes_registro");
    List<IncidenteRegistro> registroSet = await getIncidentes(2025);

    if (registroSet.isEmpty) {
      print("No se hayo nada");
      return;
    }
    generateFile(registroSet, columnNames, "excelTest.xlsx");
        logAction(widget.usuario.correo, Tipo.alta, "Generó reporte", logsHelper,
        _logger);
  }

  Widget _buildFilterInputs() {
    switch (_selectedFilter) {
      case 'Día':
        return Column(
          children: [
            const Text("Selecciona un día"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text(_selectedDay == null
                  ? 'Elegir día'
                  : '📅 ${_selectedDay!.toLocal()}'.split('-')[2].split(' ')[0]),
            ),
          ],
        );
      case 'Semana':
        return Column(
          children: [
            const Text("Selecciona intervalo de fechas"),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text(_startDate == null
                  ? 'Inicio de semana'
                  : '📅 ${_startDate!.toLocal()}'.split('-')[2].split(' ')[0]),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              child: Text(_endDate == null
                  ? 'Fin de semana'
                  : '📅 ${_endDate!.toLocal()}'.split('-')[2].split(' ')[0]),
            ),
          ],
        );
      case 'Mes':
        return DropdownButtonFormField<int>(
          value: _selectedMonth,
          decoration: const InputDecoration(labelText: "Selecciona un mes"),
          items: List.generate(12, (index) {
            return DropdownMenuItem<int>(
              value: index + 1,
              child: Text(
                '${index + 1} - ${_monthName(index + 1)}',
              ),
            );
          }),
          onChanged: (val) {
            setState(() {
              _selectedMonth = val;
            });
          },
        );
      default:
        return Container();
    }
  }

  String _monthName(int month) {
    const List<String> months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📊 Generar Reportes'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Reportes'),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Selecciona el tipo de filtro:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ToggleButtons(
              isSelected: ['Día', 'Semana', 'Mes']
                  .map((e) => _selectedFilter == e)
                  .toList(),
              onPressed: (index) {
                setState(() {
                  _selectedFilter = ['Día', 'Semana', 'Mes'][index];
                  _startDate = null;
                  _endDate = null;
                  _selectedDay = null;
                  _selectedMonth = null;
                });

              },
              borderRadius: BorderRadius.circular(10),
              children: ['Día', 'Semana', 'Mes']
                  .map((e) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(e),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            _buildFilterInputs(),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _generateReport(),
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generar Reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
