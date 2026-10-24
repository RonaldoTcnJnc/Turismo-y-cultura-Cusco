import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/guide_models.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import '../utils/constantes.dart';
import 'place_card.dart';
import 'section_heading.dart';

class RepositoryPlaceSection extends StatelessWidget {
  const RepositoryPlaceSection({
    required this.tipo,
    required this.title,
    required this.subtitle,
    required this.future,
    this.onViewAll,
    this.onContentTap,
    super.key,
  });

  final TipoContenido tipo;
  final String title;
  final String subtitle;
  final Future<List<Contenido>> future;
  final VoidCallback? onViewAll;
  final ValueChanged<Contenido>? onContentTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: title,
          subtitle: subtitle,
          trailing: TextButton(
            onPressed: onViewAll,
            child: const Text('VER TODO  ›'),
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Contenido>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return _ListMessage(
                icon: Icons.error_outline,
                message: Textos.kErrorCarga,
                action: TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              );
            }
            final contents = snapshot.data ?? const <Contenido>[];
            if (contents.isEmpty) {
              return const _ListMessage(
                icon: Icons.inbox_outlined,
                message: Textos.kListaVacia,
              );
            }
            return LayoutBuilder(
              builder: (context, constraints) {
                final columns = switch (constraints.maxWidth) {
                  < 520 => 2,
                  < 960 => 3,
                  _ => 4,
                };
                final visibleContents = contents.take(4).toList();
                return GridView.builder(
                  key: ValueKey('${tipo.clave}-grid'),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visibleContents.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisExtent: Dimensiones.kAlturaTarjeta,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => PlaceCard(
                    place: _toGuidePlace(visibleContents[index]),
                    sectionColor: colorScheme.primary,
                    onTap: onContentTap == null
                        ? null
                        : () => onContentTap!(visibleContents[index]),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  GuidePlace _toGuidePlace(Contenido content) {
    final category = switch (content) {
      Lugar value => value.distrito,
      Festividad value => '${value.dia}/${value.mes}',
      Plato value => value.tipo,
      _ => tipo.clave,
    };
    final image =
        content.rutaImagen ??
        switch (tipo) {
          TipoContenido.lugar => 'assets/images/categorias/lugares.jpg',
          TipoContenido.festividad =>
            'assets/images/categorias/festividades.jpg',
          TipoContenido.plato => 'assets/images/categorias/gastronomia.jpg',
        };
    return GuidePlace(
      name: content.nombre,
      category: category,
      imagePath: image,
      tags: [tipo.clave],
    );
  }
}

class _ListMessage extends StatelessWidget {
  const _ListMessage({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          ?action,
        ],
      ),
    ),
  );
}
