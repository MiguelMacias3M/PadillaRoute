import 'package:flutter/material.dart';

class UserScreenRegister extends StatefulWidget {
  @override
  _UserScreenRegisterState createState() => _UserScreenRegisterState();
}

class _UserScreenRegisterState extends State<UserScreenRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _selectedRole; // Variable para el rol seleccionado

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
            Text(
              'Ingrese los datos del usuario:',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 15),
            _inputField('Nombre', _nameController),
            SizedBox(height: 10),
            _inputField('Apellidos', _lastNameController),
            SizedBox(height: 10),
            _inputField('Teléfono', _phoneController, inputType: TextInputType.phone),
            SizedBox(height: 10),
            _inputField('Correo', _emailController, inputType: TextInputType.emailAddress),
            SizedBox(height: 10),
            _inputField('Contraseña', _passwordController, isPassword: true),
            SizedBox(height: 10),
            _roleDropdown(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes agregar la lógica para registrar el usuario
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Usuario registrado exitosamente')),
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
                  'Registrar usuario',
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
      items: ['Administrador', 'Administrativo', 'Chofer'].map((role) {
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
}
