import 'package:flutter/material.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import '../navigation/route_arguments.dart';
import '../services/preferencias_service.dart';
import '../utils/constantes.dart';
import '../widgets/guide_image.dart';

class ContenidoDetalleScreen extends StatefulWidget {
  const ContenidoDetalleScreen({
    required this.contenido,
    this.repository,
    this.preferences,
    super.key,
  });

  final Contenido contenido;
  final ContenidoRepository? repository;
  final PreferenciasService? preferences;

  @override
  State<ContenidoDetalleScreen> createState() => _ContenidoDetalleScreenState();
}

class _ContenidoDetalleScreenState extends State<ContenidoDetalleScreen> {
  late Contenido _contenido = widget.contenido;
  bool _esFavorito = false;
  bool _actualizandoFavorito = false;

  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();
  PreferenciasService get _preferences =>
      widget.preferences ?? PreferenciasService();

  String get _favoriteKey =>
      '${_contenido.tipoContenido.clave}:${_contenido.id}';

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    try {
      final favorite = await _preferences.esFavorito(_favoriteKey);
      if (!mounted) return;
      setState(() => _esFavorito = favorite);
    } catch (_) {
      if (!mounted) return;
      setState(() => _esFavorito = false);
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _actualizandoFavorito = true);
    try {
      await _preferences.cambiarFavorito(_favoriteKey);
      if (!mounted) return;
      setState(() {
        _esFavorito = !_esFavorito;
        _actualizandoFavorito = false;
      });
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop<bool>(true);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _actualizandoFavorito = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo actualizar el favorito.')),
      );
    }
  }

  Future<void> _edit() async {
    final updated = await Navigator.pushNamed<Contenido>(
      context,
      Rutas.kContenido,
      arguments: ContenidoFormRouteArgs(
        categoria: _contenido.tipoContenido,
        contenido: _contenido,
      ),
    );
    if (!mounted) return;
    if (updated != null) {
      setState(() => _contenido = updated);
      Navigator.pop<bool>(context, true);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar contenido'),
        content: Text(
          '¿Desea eliminar «${_contenido.nombre}»? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    try {
      final id = _contenido.id;
      if (id == null) throw StateError('El contenido no tiene identificador.');
      await _repository.eliminar(_contenido.tipoContenido, id);
      if (!mounted) return;
      await _preferences.quitarFavorito(_favoriteKey);
      if (!mounted) return;
      Navigator.pop<bool>(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo eliminar. Inténtelo nuevamente.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _contenido.rutaImagen;
    return Scaffold(
      appBar: AppBar(
        title: Text(_contenido.nombre),
        actions: [
          IconButton(
            tooltip: 'Editar',
            onPressed: _edit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Eliminar',
            onPressed: _delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (image != null)
            SizedBox(height: 240, child: GuideImage(imagePath: image))
          else
            const SizedBox(
              height: 180,
              child: Center(child: Icon(Icons.image_outlined, size: 64)),
            ),
          const SizedBox(height: 16),
          Text(
            _contenido.nombre,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(_contenido.descripcion),
          const SizedBox(height: 20),
          _specificDetails(),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _actualizandoFavorito ? null : _toggleFavorite,
            icon: Icon(_esFavorito ? Icons.bookmark : Icons.bookmark_border),
            label: Text(
              _esFavorito ? 'Quitar de guardados' : 'Guardar en favoritos',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Textos.kPrivacidadImagen,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _specificDetails() => switch (_contenido) {
    Lugar value => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Distrito', value: value.distrito),
        if (value.latitud != null && value.longitud != null)
          _DetailRow(
            label: 'Coordenadas',
            value: '${value.latitud}, ${value.longitud}',
          ),
      ],
    ),
    Festividad value => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Fecha anual', value: '${value.dia}/${value.mes}'),
        if (value.distrito != null)
          _DetailRow(label: 'Distrito', value: value.distrito!),
      ],
    ),
    Plato value => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailRow(label: 'Tipo', value: value.tipo),
        if (value.precioRef != null)
          _DetailRow(
            label: 'Precio referencial',
            value: 'S/ ${value.precioRef}',
          ),
      ],
    ),
    _ => const SizedBox.shrink(),
  };
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}
