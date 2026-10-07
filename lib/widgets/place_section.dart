import 'package:flutter/material.dart';

// Importa el modelo que define cada sección de contenido.
import '../models/guide_models.dart';
// Importa la tarjeta individual para cada lugar o evento.
import 'place_card.dart';
// Importa el encabezado reutilizable.
import 'section_heading.dart';

// Este widget representa una sección completa del contenido, por ejemplo: lugares, festividades o gastronomía.
class PlaceSection extends StatelessWidget {
  // El constructor recibe la sección concreta que debe dibujarse.
  const PlaceSection({required this.section, super.key});

  // La sección que contiene el título, subtítulo y la lista de lugares.
  final GuideSection section;

  @override
  Widget build(BuildContext context) {
    // Recupera el color primario del tema para darle consistencia a la acción “VER TODO”.
    final colorScheme = Theme.of(context).colorScheme;

    // Una sección se compone de un encabezado y una grilla de tarjetas.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // El encabezado de la sección reutiliza el widget base con título y su enlace de acción.
        SectionHeading(
          title: section.title,
          subtitle: section.subtitle,
          trailing: Text(
            'VER TODO  ›',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        // Espacio entre el encabezado y la grilla.
        const SizedBox(height: 16),

        // LayoutBuilder detecta el ancho disponible para adaptar la cantidad de columnas.
        LayoutBuilder(
          builder: (context, constraints) {
            // Se usa un switch para definir el número de columnas según el ancho disponible.
            final columns = switch (constraints.maxWidth) {
              < 520 => 2,
              < 960 => 3,
              _ => 4,
            };

            // GridView.builder genera la grilla de contenido dinámicamente.
            return GridView.builder(
              key: ValueKey('${section.title.toLowerCase()}-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: section.places.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 232,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) => PlaceCard(
                place: section.places[index],
                sectionColor: colorScheme.primary,
              ),
            );
          },
        ),
      ],
    );
  }
}
