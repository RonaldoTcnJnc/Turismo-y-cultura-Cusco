import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String?> elegirYGuardar(ImagePicker picker, ImageSource source) async {
  final selected = await picker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 1800,
  );
  if (selected == null) return null;

  final documents = await getApplicationDocumentsDirectory();
  final imagesDirectory = Directory(path.join(documents.path, 'imagenes'));
  await imagesDirectory.create(recursive: true);
  final extension = path.extension(selected.path).isEmpty
      ? '.jpg'
      : path.extension(selected.path);
  final destination = path.join(
    imagesDirectory.path,
    'contenido_${DateTime.now().microsecondsSinceEpoch}$extension',
  );
  return (await File(selected.path).copy(destination)).path;
}
