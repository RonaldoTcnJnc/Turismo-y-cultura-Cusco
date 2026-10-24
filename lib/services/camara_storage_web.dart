import 'dart:convert';

import 'package:image_picker/image_picker.dart';

Future<String?> elegirYGuardar(ImagePicker picker, ImageSource source) async {
  final selected = await picker.pickImage(
    source: source,
    imageQuality: 85,
    maxWidth: 1800,
  );
  if (selected == null) return null;
  final mimeType = selected.mimeType ?? 'image/jpeg';
  final bytes = await selected.readAsBytes();
  return 'data:$mimeType;base64,${base64Encode(bytes)}';
}
