import 'package:flutter/material.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../navigation/route_arguments.dart';
import '../services/preferencias_service.dart';
import '../utils/constantes.dart';
import '../widgets/contenido_list_tile.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({
    this.repository,
    this.preferences,
    this.embedded = false,
    super.key,
  });

  final ContenidoRepository? repository;
  final PreferenciasService? preferences;
  final bool embedded;

  @override
  FavoritosScreenState createState() => FavoritosScreenState();
}

class FavoritosScreenState extends State<FavoritosScreen> {
  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();
  PreferenciasService get _preferences =>
      widget.preferences ?? PreferenciasService();

  late Future<List<Contenido>> _future;
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Contenido>> _load() async {
    final keys = await _preferences.obtenerFavoritos();
    final favorites = <Contenido>[];
    for (final key in keys) {
      final separator = key.indexOf(':');
      if (separator <= 0 || separator == key.length - 1) continue;
      try {
        final type = TipoContenidoInfo.parse(key.substring(0, separator));
        final id = int.parse(key.substring(separator + 1));
        final content = await _repository.obtenerPorId(type, id);
        if (content != null) favorites.add(content);
      } on FormatException {
        continue;
      } on ArgumentError {
        continue;
      }
    }
    return favorites;
  }

  void refresh() {
    if (!mounted) return;
    setState(() {
      _refreshVersion++;
      _future = _load();
    });
  }

  Future<void> _openDetail(Contenido content) async {
    final changed = await Navigator.pushNamed<bool>(
      context,
      Rutas.kDetalleContenido,
      arguments: ContenidoDetalleRouteArgs(content),
    );
    if (!mounted) return;
    if (changed == true) refresh();
  }

  Future<void> _removeFavorite(Contenido content) async {
    final id = content.id;
    if (id == null) return;
    try {
      await _preferences.cambiarFavorito('${content.tipoContenido.clave}:$id');
      if (!mounted) return;
      refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo quitar el favorito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<List<Contenido>>(
      key: ValueKey(_refreshVersion),
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _FavoritesState(
            icon: Icons.error_outline,
            message: Textos.kErrorCarga,
            action: TextButton.icon(
              onPressed: refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          );
        }
        final favorites = snapshot.data ?? const <Contenido>[];
        if (favorites.isEmpty) {
          return const _FavoritesState(
            icon: Icons.bookmark_border,
            message: 'Aún no tienes contenidos guardados.',
          );
        }
        final tiles = [
          for (final favorite in favorites) ...[
            ContenidoListTile(
              contenido: favorite,
              onTap: () => _openDetail(favorite),
              esFavorito: true,
              onFavoriteTap: () => _removeFavorite(favorite),
            ),
            const SizedBox(height: 8),
          ],
        ];
        if (widget.embedded) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(children: tiles),
          );
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: tiles,
        );
      },
    );

    if (widget.embedded) return content;
    return Scaffold(
      appBar: AppBar(title: const Text('Favoritos')),
      body: content,
    );
  }
}

class _FavoritesState extends StatelessWidget {
  const _FavoritesState({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 32),
        const SizedBox(height: 8),
        Text(message),
        ?action,
      ],
    ),
  );
}
