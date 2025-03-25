import 'package:padillaroutea/models/realtimeDB_models/incidente_registro.dart';
// import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart';
import 'dart:io';

void generateFile(List<IncidenteRegistro> registroSet, List<String> columnNames,String fileName) async {
  // CREAR ARCHIVO EXCEL
  var excel = Excel.createExcel();
  // RENOMBRAR HOJA POR DEFECTO
  excel.rename('Sheet1', "Pagina1");
  // USAR LA HOJA CREADA POR DEFECTO
  var sheet = excel['Pagina1'];
  // DEFINIR EL ESTILO DE LAS CELDAS HEADER
  CellStyle header = CellStyle(
      bold: true, fontSize: 14, fontFamily: getFontFamily(FontFamily.Arial));
  // DEIFINIR EL ESTILO DE LAS CELAS
  CellStyle field = CellStyle(
      bold: false, fontSize: 12, fontFamily: getFontFamily(FontFamily.Arial));

  // DEFINIR NOMBRE DE LAS COLUMNAS Y SU POSICION
  List<String> indexes =
      List.generate(columnNames.length, (i) => String.fromCharCode(65 + i));

  // IMPRIMIR NOMBRES DE LAS COMLUMNAS
  for (int i = 0; i < indexes.length; i++) {
    var headerCell = sheet.cell(CellIndex.indexByString('${indexes[i]}1'));
    headerCell.cellStyle = header;
    headerCell.value = TextCellValue(columnNames[i]);
  }

  for (int rowIndex = 0; rowIndex < registroSet.length; rowIndex++) {
    IncidenteRegistro incidente = registroSet[rowIndex];
    List<dynamic> rowData = [
      incidente.idRegistro,
      incidente.idUsuario,
      incidente.idVehiculo,
      incidente.descripcion,
      incidente.fecha,
    ];

    for (int colIndex = 0; colIndex < rowData.length; colIndex++) {
      var cell = sheet.cell(CellIndex.indexByString('${indexes[colIndex]}${rowIndex + 2}'));
      cell.cellStyle = field;
      cell.value = TextCellValue(rowData[colIndex].toString());
      print("Valor de la celda: ${cell.value}");
    }
  }

  // DEFINIR RUTA PARA GUARDAR EL ARCHIVO
  Directory? directory =
      Directory('/storage/emulated/0/Padillaroute/Descargas');
  // VERIFICAR SI EL DIRECTORIO EXISTE, SI NO EXISTE CREARLO
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
  // DEFINE NOMBRE DEL ARCHIVO Y LO CONCANTENA CON LA RUTA ANTES MENCIONADA
  String outputPath = p.join(directory.path, fileName);
  // REVISA SI EL ARCHIVO EXISTE, SI EXISTE LO ELIMINA
  File file = File(outputPath);
  if (file.existsSync()) {
    file.deleteSync();
  }

  try {
    // GUARDA LOS CAMBIOS EN LA HOJA DEL ARCHIVO EXCEL
    List<int>? fileBytes = excel.encode();
    // SI LO ANTERIOR FUNCIONA, CREA EL ARCHIVO
    if (fileBytes != null) {
      // CREA EL ARCHIVO Y LO GUARDA EN LA RUTA DEFINIDA
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      // ABRE EL ARCHIVO SI SE CREÓ CORRECTAMENTE
      OpenFile.open(outputPath);
    }
  } catch (e) {
    throw Exception('Error al generar el archivo');
  }
}
