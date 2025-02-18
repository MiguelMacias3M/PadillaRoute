import 'package:flutter/material.dart';

class UserScreenEdit extends StatefulWidget {
  @override
  _UserScreenEditState createState() => _UserScreenEditState();
}

class _UserScreenEditState extends State<UserScreenEdit> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole = 'Chofer'; // Rol inicial
  final List<String> _roleOptions = ['Chofer', 'Administrativo', 'Gerente'];
  
  String? _selectedStatus = 'Activo'; // Estado inicial
  final List<String> _statusOptions = ['Activo', 'Inactivo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Usuarios',
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
              'assets/logo.png', // Asegúrate de tener el logo en la carpeta assets
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
            _inputField('Nombre', _nameController),
            SizedBox(height: 10),
            _inputField('Apellidos', _lastNameController),
            SizedBox(height: 10),
            _inputField('Teléfono', _phoneController, inputType: TextInputType.phone),
            SizedBox(height: 10),
            _inputField('Correo', _emailController, inputType: TextInputType.emailAddress),
            SizedBox(height: 10),
            _inputField('Contraseña: encriptado', _passwordController, isPassword: true),
            SizedBox(height: 10),
            _roleDropdown(),
            SizedBox(height: 10),
            _statusDropdown(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cambios guardados correctamente')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Guardar cambios',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para los campos de texto
  Widget _inputField(String label, TextEditingController controller, {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  // Widget para el selector de roles
  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rol',
        border: OutlineInputBorder(),
      ),
      items: _roleOptions.map((role) {
        return DropdownMenuItem(
          value: role,
          child: Text(role),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
    );
  }

  // Widget para el selector de estado del usuario
  Widget _statusDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Estado del usuario',
        border: OutlineInputBorder(),
      ),
      items: _statusOptions.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(
            status,
            style: TextStyle(color: status == 'Activo' ? Colors.green : Colors.red),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }
}
