import 'package:image_picker/image_picker.dart';

import 'camara_storage_stub.dart'
    if (dart.library.io) 'camara_storage_io.dart'
    if (dart.library.js_interop) 'camara_storage_web.dart'
    as storage;

class CamaraService {
  CamaraService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> elegirYGuardar(ImageSource source) =>
      storage.elegirYGuardar(_picker, source);
}
