import 'package:flutter/material.dart';

// Importa el modelo de datos del contenido turístico.
import '../models/guide_models.dart';
// Importa el widget reutilizable para cargar imágenes locales.
import 'guide_image.dart';

// Esta tarjeta representa cada lugar, festival o experiencia dentro de una sección.
class PlaceCard extends StatelessWidget {
  // El constructor recibe el contenido del item y el color de la sección para dar estilo visual.
  const PlaceCard({required this.place, required this.sectionColor, super.key});

  // Contenido del lugar o evento a mostrar.
  final GuidePlace place;
  // Color de la sección para resaltar la etiqueta superior.
  final Color sectionColor;

  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de colores del tema para armonizar los colores del texto y etiquetas.
    final colorScheme = Theme.of(context).colorScheme;

    // ClipRRect recorta la imagen y el contenido para que las esquinas queden redondeadas.
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        // Stack permite superponer imagen, gradiente, etiqueta y texto sobre la misma tarjeta.
        fit: StackFit.expand,
        children: [
          // La imagen es el elemento base que representa el lugar.
          GuideImage(imagePath: place.imagePath),
          DecoratedBox(
            // Añade un degradado oscuro para que el texto se vea bien sobre la foto.
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.35, 1],
                colors: [
                  Colors.black.withValues(alpha: 0.30),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.88),
                ],
              ),
            ),
          ),
          // La etiqueta superior identifica la categoría o tipo de contenido.
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                place.category,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          // El texto principal y los tags se ubican en la parte inferior.
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre del lugar o evento.
                Text(
                  place.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(color: Colors.white, fontSize: 16),
                ),
                // Separación del nombre con las etiquetas.
                const SizedBox(height: 8),

                // Wrap permite poner varias etiquetas pequeñas en varias líneas si hace falta.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in place.tags)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
