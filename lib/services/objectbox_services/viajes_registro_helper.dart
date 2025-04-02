import 'package:padillaroutea/services/connectors/objectbox_connector.dart';
import 'package:padillaroutea/models/objectBox_models/viaje_registro.dart';
import 'package:objectbox/objectbox.dart';

class ViajesRegistroHelper {
  ObjectBox objectBox;
  late Box<ViajeRegistro> box;
  
  ViajesRegistroHelper(this.objectBox) {
    box = objectBox.store.box<ViajeRegistro>();
  }

  void saveRegistro(ViajeRegistro registro) {
    box.put(registro);
  }

  void deleteRegistro() {
    box.removeAll();
  }

  ViajeRegistro? getRegistro(int id) {
    final registro = box.get(id);
    return registro;
  }

  List<ViajeRegistro> getAllRegistros() {
    return box.getAll();
  }
}