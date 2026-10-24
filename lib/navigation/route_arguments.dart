import '../models/contenido.dart';

class CategoriaRouteArgs {
  const CategoriaRouteArgs(this.categoria);

  final TipoContenido categoria;
}

class ContenidoFormRouteArgs {
  const ContenidoFormRouteArgs({required this.categoria, this.contenido});

  final TipoContenido categoria;
  final Contenido? contenido;
}

class ContenidoDetalleRouteArgs {
  const ContenidoDetalleRouteArgs(this.contenido);

  final Contenido contenido;
}
