import 'package:flutter/material.dart';

import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/lugar.dart';
import '../models/plato.dart';

class ContenidoListTile extends StatelessWidget {
  const ContenidoListTile({
    required this.contenido,
    required this.onTap,
    this.onFavoriteTap,
    this.esFavorito = false,
    super.key,
  });

  final Contenido contenido;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool esFavorito;

  @override
  Widget build(BuildContext context) {
    final subtitle = switch (contenido) {
      Lugar value => value.distrito,
      Festividad value =>
        '${value.dia.toString().padLeft(2, '0')}/'
            '${value.mes.toString().padLeft(2, '0')}',
      Plato value => value.tipo,
      _ => contenido.tipoContenido.clave,
    };
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(_icon(contenido.tipoContenido)),
        ),
        title: Text(
          contenido.nombre,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle),
        trailing: onFavoriteTap == null
            ? const Icon(Icons.chevron_right)
            : IconButton(
                tooltip: esFavorito
                    ? 'Quitar de favoritos'
                    : 'Agregar a favoritos',
                onPressed: onFavoriteTap,
                icon: Icon(esFavorito ? Icons.bookmark : Icons.bookmark_border),
              ),
      ),
    );
  }

  IconData _icon(TipoContenido tipo) => switch (tipo) {
    TipoContenido.lugar => Icons.place_outlined,
    TipoContenido.festividad => Icons.celebration_outlined,
    TipoContenido.plato => Icons.restaurant_outlined,
  };
}
