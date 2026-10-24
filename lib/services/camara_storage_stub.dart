import 'package:image_picker/image_picker.dart';

Future<String?> elegirYGuardar(ImagePicker picker, ImageSource source) =>
    Future<String?>.error(
      UnsupportedError('La selección de imágenes no está disponible aquí.'),
    );
