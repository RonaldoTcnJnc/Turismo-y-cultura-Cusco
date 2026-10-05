import 'package:flutter/material.dart';

import '../models/guide_models.dart';
import 'place_card.dart';
import 'section_heading.dart';

class PlaceSection extends StatelessWidget {
  const PlaceSection({required this.section, super.key});

  final GuideSection section;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Los puntos de quiebre usan el ancho disponible del contenido.
            final columns = switch (constraints.maxWidth) {
              < 520 => 2,
              < 960 => 3,
              _ => 4,
            };

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
