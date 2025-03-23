import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';

class ReportsScreen extends StatefulWidget {
  final Usuario usuario;

  ReportsScreen({required this.usuario});

  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}


class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedFilter = 'Día';
  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _selectedDay;
  int? _selectedMonth;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
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
    }
  }

  void _generateReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('📄 Generando reporte...')),
    );
  }

  Widget _buildFilterInputs() {
    switch (_selectedFilter) {
      case 'Día':
        return Column(
          children: [
            Text("Selecciona un día"),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text(_selectedDay == null
                  ? 'Elegir día'
                  : '📅 ${_selectedDay!.toLocal()}'.split(' ')[0]),
            ),
          ],
        );
      case 'Semana':
        return Column(
          children: [
            Text("Selecciona intervalo de fechas"),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, true),
              child: Text(_startDate == null
                  ? 'Inicio de semana'
                  : '📅 ${_startDate!.toLocal()}'.split(' ')[0]),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _selectDate(context, false),
              child: Text(_endDate == null
                  ? 'Fin de semana'
                  : '📅 ${_endDate!.toLocal()}'.split(' ')[0]),
            ),
          ],
        );
      case 'Mes':
        return DropdownButtonFormField<int>(
          value: _selectedMonth,
          decoration: InputDecoration(labelText: "Selecciona un mes"),
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
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('📊 Generar Reportes'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Selecciona el tipo de filtro:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 10),
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
              onPressed: _generateReport,
              icon: Icon(Icons.picture_as_pdf),
              label: Text('Generar Reporte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
