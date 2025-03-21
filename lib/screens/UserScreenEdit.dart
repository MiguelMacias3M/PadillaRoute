import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';

import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/screens/menulateral.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class UserScreenEdit extends StatefulWidget {
  final Usuario usuarioSeleccionado;
  final Usuario usuario;

  UserScreenEdit({required this.usuarioSeleccionado, required this.usuario});

  @override
  _UserScreenEditState createState() => _UserScreenEditState();
}

class _UserScreenEditState extends State<UserScreenEdit> {
  late TextEditingController _nameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  String? _selectedRole;
  final List<String> _roleOptions = ['Chofer', 'Administrativo', 'Gerente'];

  String? _selectedStatus;
  final List<String> _statusOptions = ['Activo', 'Inactivo'];

  @override
  void initState() {
    super.initState();
    logAction(
        widget.usuario.correo,
        Tipo.alta,
        "Ingreso a edición del usuario ${widget.usuarioSeleccionado.toJson()}",
        logsHelper,
        _logger);

    print(
        "Datos del usuario recibidos: ${widget.usuarioSeleccionado.toJson()}"); // Imprime el objeto Usuario completo

    _nameController =
        TextEditingController(text: widget.usuarioSeleccionado.nombre);
    _lastNameController =
        TextEditingController(text: widget.usuarioSeleccionado.apellidos);
    _phoneController = TextEditingController(
        text: widget.usuarioSeleccionado.telefono.toString());
    _emailController =
        TextEditingController(text: widget.usuarioSeleccionado.correo);
    _passwordController = TextEditingController(text: '••••••••'); // Encriptado

    _selectedRole = _roleOptions.firstWhere(
      (role) => role.toLowerCase() == widget.usuarioSeleccionado.rol.name,
      orElse: () => 'Chofer', // Valor por defecto en caso de error
    );

    _selectedStatus = widget.usuarioSeleccionado.activo ? 'Activo' : 'Inactivo';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _menuLateral(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
  }

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
              'assets/logo.png',
              height: 40,
            ),
          ),
        ],
      ),
      drawer: buildDrawer(context, widget.usuario, _menuLateral, 'Usuarios'),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _inputField('Nombre', _nameController),
            SizedBox(height: 10),
            _inputField('Apellidos', _lastNameController),
            SizedBox(height: 10),
            _inputField('Teléfono', _phoneController,
                inputType: TextInputType.phone),
            SizedBox(height: 10),
            _inputField('Correo', _emailController,
                inputType: TextInputType.emailAddress),
            SizedBox(height: 10),
            _inputField('Contraseña: encriptado', _passwordController,
                isPassword: true),
            SizedBox(height: 10),
            _roleDropdown(),
            SizedBox(height: 10),
            _statusDropdown(),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _saveChanges,
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

  Widget _inputField(String label, TextEditingController controller,
      {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
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
            style: TextStyle(
                color: status == 'Activo' ? Colors.green : Colors.red),
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

  void _saveChanges() async {
    try {
      final usuariosHelper = UsuariosHelper(RealtimeDbHelper());

      final updatedUser = {
        'nombre': _nameController.text,
        'apellidos': _lastNameController.text,
        'telefono': int.tryParse(_phoneController.text) ?? 0,
        'correo': _emailController.text,
        'rol': _selectedRole?.toLowerCase(),
        'activo': _selectedStatus == 'Activo',
      };

      _logger.i("Intentando actualizar usuario: $updatedUser");

      print(
          "Datos a actualizar: $updatedUser"); // Imprime los datos que se van a actualizar

      await usuariosHelper.update(
          widget.usuarioSeleccionado.idUsuario, updatedUser);
      await logAction(widget.usuarioSeleccionado.correo, Tipo.modificacion,
          "Usuario actualizado", logsHelper, _logger);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cambios guardados correctamente')),
      );

      Navigator.pop(context); // Regresar a UserScreenManagement.dart
    } catch (e) {
      _logger.e("Error al actualizar usuario: $e");
      await logAction(widget.usuarioSeleccionado.correo, Tipo.modificacion,
          "Error al actualizar usuario: $e", logsHelper, _logger);

      print("Error al actualizar: $e"); // Imprime el error

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar: $e')),
      );
    }
  }
}
