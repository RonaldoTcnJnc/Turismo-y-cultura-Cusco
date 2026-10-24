import 'package:flutter/material.dart';

import 'local_image_provider.dart';

// Este widget reutilizable carga una imagen local desde assets.
// Se usa en diversas tarjetas para evitar repetir la lógica de carga de imágenes.
class GuideImage extends StatelessWidget {
  // El constructor exige la ruta exacta de la imagen.
  const GuideImage({required this.imagePath, super.key});

  // Ruta del asset de la imagen a mostrar.
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    // Image.asset carga un recurso local desde la carpeta assets.
    Widget buildPlaceholder(
      BuildContext context,
      Object error,
      StackTrace? stackTrace,
    ) => _placeholder(context);
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: buildPlaceholder,
      );
    }
    if (imagePath.startsWith('data:image/')) {
      return Image.memory(
        UriData.parse(imagePath).contentAsBytes(),
        fit: BoxFit.cover,
        errorBuilder: buildPlaceholder,
      );
    }
    return Image(
      image: localImageProvider(imagePath),
      fit: BoxFit.cover,
      errorBuilder: buildPlaceholder,
    );
  }

  // Placeholder que se muestra cuando la imagen no puede cargarse.
  Widget _placeholder(BuildContext context) {
    // ColoredBox crea un fondo neutro para mantener la estructura visual.
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          // Icono de paisaje para representar visualmente que la imagen no existe.
          Icons.landscape_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 32,
        ),
      ),
    );
  }
}
