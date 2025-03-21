import 'package:flutter/material.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';

class UserScreenRegister extends StatefulWidget {
  final Usuario usuario;

  UserScreenRegister({required this.usuario});
  @override
  _UserScreenRegisterState createState() => _UserScreenRegisterState();
}

class _UserScreenRegisterState extends State<UserScreenRegister> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false; // 🔥 Variable para controlar la carga
  String? _selectedRole;
  final UsuariosHelper _usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _registerUser() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nombre = _nameController.text.trim();
    final apellidos = _lastNameController.text.trim();
    final telefonoText = _phoneController.text.trim();

    if (email.isEmpty ||
        password.isEmpty ||
        nombre.isEmpty ||
        apellidos.isEmpty ||
        telefonoText.isEmpty) {
      _showSnackbar("⚠️ Todos los campos son obligatorios.", Colors.amber);
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showSnackbar("⚠️ Correo electrónico inválido.", Colors.amber);
      return;
    }

    setState(() {
      _isLoading = true; // 🔥 Mostrar la barra de carga
    });

    try {
      final telefono = int.parse(telefonoText);

      final rolEnum = Rol.values.firstWhere(
        (r) =>
            r.toString().split('.').last.toLowerCase() ==
            (_selectedRole ?? 'chofer').toLowerCase(),
        orElse: () => Rol.chofer,
      );

      final usuario = Usuario(
        idUsuario: DateTime.now().millisecondsSinceEpoch,
        nombre: nombre,
        apellidos: apellidos,
        telefono: telefono,
        correo: email,
        contrasena: password,
        rol: rolEnum,
        activo: true,
        idVehiculo: 1,
      );

      await _usuariosHelper.setNew(usuario);
      await _logAction(email, Tipo.alta, "Registro de usuario exitoso");

      _showSnackbar("✅ Usuario registrado exitosamente.", Colors.green);

      // 🔥 Limpiar campos después de registro exitoso
      _nameController.clear();
      _lastNameController.clear();
      _phoneController.clear();
      _emailController.clear();
      _passwordController.clear();
      setState(() {
        _selectedRole = null;
      });
    } catch (e) {
      await _logAction(email, Tipo.alta, "Error al registrar usuario: $e");
      _showSnackbar("❌ Error al registrar usuario: $e", Colors.red);
    }

    setState(() {
      _isLoading = false; // 🔥 Ocultar la barra de carga
    });
  }

  Widget _inputField(String label, TextEditingController controller,
      {bool isPassword = false, TextInputType inputType = TextInputType.text}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _roleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedRole,
      decoration: InputDecoration(
        labelText: 'Rol',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      items: ['Chofer', 'Administrativo', 'Gerente'].map((role) {
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

  Future<void> _logAction(String correo, Tipo tipo, String accion) async {
    final logEntry = Log(
      idLog: DateTime.now().millisecondsSinceEpoch,
      tipo: tipo,
      usuario: correo,
      accion: accion,
      fecha: DateTime.now().toIso8601String(),
    );

    try {
      await logsHelper.setNew(logEntry);
      _logger.i("Log registrado: $accion");
    } catch (e) {
      _logger.e("Error al registrar log: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Usuario'),
        backgroundColor: Colors.blue,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingrese los datos del usuario:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
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
            _inputField('Contraseña', _passwordController, isPassword: true),
            SizedBox(height: 10),
            _roleDropdown(),
            SizedBox(height: 20),

            // 🔥 Indicador de carga
            if (_isLoading)
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      "Registrando usuario...",
                      style: TextStyle(fontSize: 16, color: Colors.blue),
                    ),
                  ],
                ),
              ),

            // 🔥 Botón deshabilitado mientras se registra el usuario
            Center(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isLoading ? Colors.grey : Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _isLoading ? 'Registrando...' : 'Registrar usuario',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
