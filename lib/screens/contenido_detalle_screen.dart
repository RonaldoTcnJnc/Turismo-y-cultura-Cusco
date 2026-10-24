import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import '../navigation/route_arguments.dart';
import '../services/camara_service.dart';
import '../services/preferencias_service.dart';
import '../services/role_session.dart';
import '../utils/constantes.dart';
import '../widgets/guide_image.dart';

class ContenidoDetalleScreen extends StatefulWidget {
  const ContenidoDetalleScreen({
    required this.contenido,
    this.repository,
    this.preferences,
    this.cameraService,
    required this.roleSession,
    super.key,
  });

  final Contenido contenido;
  final ContenidoRepository? repository;
  final PreferenciasService? preferences;
  final CamaraService? cameraService;
  final RoleSession roleSession;

  @override
  State<ContenidoDetalleScreen> createState() => _ContenidoDetalleScreenState();
}

class _ContenidoDetalleScreenState extends State<ContenidoDetalleScreen> {
  late Contenido _contenido = widget.contenido;
  bool _esFavorito = false;
  bool _actualizandoFavorito = false;
  bool _aportandoFotografia = false;
  late Future<List<String>> _additionalPhotosFuture;

  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();
  CamaraService get _cameraService => widget.cameraService ?? CamaraService();
  PreferenciasService get _preferences =>
      widget.preferences ?? PreferenciasService();

  String get _favoriteKey =>
      '${_contenido.tipoContenido.clave}:${_contenido.id}';

  @override
  void initState() {
    super.initState();
    _additionalPhotosFuture = _loadAdditionalPhotos();
    _loadFavorite();
  }

  Future<List<String>> _loadAdditionalPhotos() {
    final id = _contenido.id;
    if (_contenido is! Lugar || id == null) return Future.value(const []);
    return _repository.listarFotosLugar(id);
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
    if (!widget.roleSession.canManageContent) return;
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
    if (!widget.roleSession.canManageContent) return;
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

  Future<void> _aportarFotografia() async {
    if (_aportandoFotografia || _contenido is! Lugar) return;
    setState(() => _aportandoFotografia = true);
    try {
      final imagePath = await _cameraService.elegirYGuardar(ImageSource.camera);
      if (!mounted) return;
      if (imagePath == null) {
        setState(() => _aportandoFotografia = false);
        return;
      }

      final id = _contenido.id;
      if (id == null) throw StateError('El lugar no tiene identificador.');
      await _repository.agregarFotoLugar(id, imagePath);
      if (!mounted) return;
      setState(() {
        _additionalPhotosFuture = _loadAdditionalPhotos();
        _aportandoFotografia = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto agregada. La imagen principal se conservó.'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _aportandoFotografia = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la fotografía.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = _contenido.rutaImagen;
    return Scaffold(
      appBar: AppBar(
        title: Text(_contenido.nombre),
        actions: widget.roleSession.canManageContent
            ? [
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
              ]
            : const [],
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
          if (_contenido is Lugar)
            OutlinedButton.icon(
              onPressed: _aportandoFotografia ? null : _aportarFotografia,
              icon: _aportandoFotografia
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_a_photo_outlined),
              label: Text(
                _contenido.rutaImagen == null
                    ? 'Fotografiar este lugar'
                    : 'Aportar otra fotografía',
              ),
            ),
          if (_contenido is Lugar) const SizedBox(height: 8),
          if (_contenido is Lugar)
            FutureBuilder<List<String>>(
              future: _additionalPhotosFuture,
              builder: (context, snapshot) {
                final photos = snapshot.data ?? const <String>[];
                if (photos.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fotos aportadas',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, index) => SizedBox(
                            width: 220,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: GuideImage(imagePath: photos[index]),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
