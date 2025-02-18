import 'package:flutter/material.dart';

class VehiclesScreenEdit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar datos',
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
            _buildTextField('Marca'),
            SizedBox(height: 10),
            _buildTextField('Modelo'),
            SizedBox(height: 10),
            _buildTextField('Num. Combi'),
            SizedBox(height: 10),
            _buildTextField('Placa'),
            SizedBox(height: 10),
            _buildTextField('Capacidad'),
            SizedBox(height: 10),
            Row(
              children: [
                Text('Estado:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(width: 10),
                Expanded(child: _buildDropdownField(['Disponible', 'No disponible', 'Taller'])),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 40, 198, 255),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Guardar cambios',
                  style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 255, 255, 255)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<String> options) {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      items: options.map((String option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: (value) {},
    );
  }
}
