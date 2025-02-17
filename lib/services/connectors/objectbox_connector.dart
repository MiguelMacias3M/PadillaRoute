import 'package:padillaroutea/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; 

class ObjectBox {
  static final ObjectBox _instance = ObjectBox._internal();
  late final Store store;

  factory ObjectBox() => _instance;

  ObjectBox._internal();

  static Future<ObjectBox> create() async {
    final docsdir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsdir.path, "obc-example-1"));
    _instance.store = store;
    return _instance;
  }
}