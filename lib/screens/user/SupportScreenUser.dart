import 'package:flutter/material.dart';
import 'package:padillaroutea/models/realtimeDB_models/usuario.dart';
import 'package:logger/logger.dart';
import 'package:padillaroutea/models/realtimeDB_models/log.dart';
import 'package:padillaroutea/services/realtime_db_services/realtime_db_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/logs_helper.dart';
import 'package:padillaroutea/services/realtime_db_services/usuarios_helper.dart';
import 'package:padillaroutea/screens/user/menulateralChofer.dart'; // importacion del menu lateral
import 'package:padillaroutea/screens/registroDeLogs.dart';

class SupportScreenUser extends StatefulWidget {
  final Usuario usuario;

  SupportScreenUser({required this.usuario});

  @override
  _SupportScreenUserState createState() => _SupportScreenUserState();
}

class _SupportScreenUserState extends State<SupportScreenUser> {
  final TextEditingController _commentController = TextEditingController();
  UsuariosHelper usuariosHelper = UsuariosHelper(RealtimeDbHelper());
  final LogsHelper logsHelper = LogsHelper(RealtimeDbHelper());
  final Logger _logger = Logger();

  void _menuLateralChofer(BuildContext context) {
    // Solo cerrar el Drawer (menú lateral)
    Navigator.pop(context); // Esto cierra el menú lateral
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Soporte',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(width: 8),
            Icon(Icons.headset_mic, color: Colors.blue),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.blue),
      ),
      drawer: buildDrawer(
          context, widget.usuario, _menuLateralChofer, 'Soporte técnico'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bienvenido, nos gustaría saber tu opinión, haznos saber cómo podemos mejorar',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _commentController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comentarios',
                alignLabelWithHint: true,
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  String feedback = _commentController.text;
                  if (feedback.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Gracias por tu comentario!")),
                    );
                    logAction(widget.usuario.correo, Tipo.alta,
                        "Comentario enviado", logsHelper, _logger);

                    _commentController.clear();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text("Por favor, ingresa un comentario.")),
                    );
                    logAction(
                        widget.usuario.correo,
                        Tipo.baja,
                        "Intento fallido de enviar comentario",
                        logsHelper,
                        _logger);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                ),
                child: Text('Guardar', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
