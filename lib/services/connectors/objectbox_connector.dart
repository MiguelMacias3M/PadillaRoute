import 'package:padillaroutea/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ObjectBox {
  late final Store store;

  ObjectBox._create(this.store) {}

  static Future<ObjectBox> create() async {
    final docsdir = await getApplicationDocumentsDirectory();
    final store = await openStore(directory: p.join(docsdir.path, "obc-example-1"));
    return ObjectBox._create(store);
  }
}
