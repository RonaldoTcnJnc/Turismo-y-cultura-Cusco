import 'package:flutter/material.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/guide_models.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import '../navigation/route_arguments.dart';
import '../services/preferencias_service.dart';
import '../services/role_session.dart';
import '../utils/constantes.dart';
import '../widgets/place_card.dart';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({
    required this.categoria,
    required this.roleSession,
    super.key,
  });

  final TipoContenido categoria;
  final RoleSession roleSession;

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  final ContenidoRepository _repository = ContenidoRepository();
  final PreferenciasService _preferences = PreferenciasService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _district;
  int? _month;
  int _refreshVersion = 0;
  late Future<List<Contenido>> _future;

  String get _title => switch (widget.categoria) {
    TipoContenido.lugar => 'Lugares',
    TipoContenido.festividad => 'Festividades',
    TipoContenido.plato => 'Gastronomía',
  };

  @override
  void initState() {
    super.initState();
    _future = _load();
    _restoreFilter();
  }

  Future<List<Contenido>> _load() => _repository.listar(
    widget.categoria,
    texto: _query,
    distrito: _district,
    mes: _month,
  );

  Future<void> _restoreFilter() async {
    try {
      final savedFilter = await _preferences.obtenerUltimoFiltro();
      if (!mounted || savedFilter == null) return;
      final parts = savedFilter.split('|');
      if (parts.length != 2 || parts.first != widget.categoria.clave) return;
      setState(() {
        if (widget.categoria == TipoContenido.festividad) {
          _month = int.tryParse(parts.last);
        } else if (widget.categoria == TipoContenido.lugar &&
            parts.last.isNotEmpty) {
          _district = parts.last;
        }
        _future = _load();
      });
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo recuperar el último filtro.');
    }
  }

  Future<void> _changeFilter({String? district, int? month}) async {
    setState(() {
      _district = district;
      _month = month;
      _refreshVersion++;
      _future = _load();
    });
    final value = widget.categoria == TipoContenido.festividad
        ? (_month?.toString() ?? '')
        : (_district ?? '');
    try {
      await _preferences.guardarUltimoFiltro(
        '${widget.categoria.clave}|$value',
      );
      if (!mounted) return;
    } catch (_) {
      if (!mounted) return;
      _showError('No se pudo guardar el filtro.');
    }
  }

  void _search(String value) {
    setState(() {
      _query = value.trim();
      _refreshVersion++;
      _future = _load();
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() {
      _refreshVersion++;
      _future = _load();
    });
  }

  Future<void> _openDetail(Contenido content) async {
    try {
      final changed = await Navigator.pushNamed<bool>(
        context,
        Rutas.kDetalleContenido,
        arguments: ContenidoDetalleRouteArgs(content),
      );
      if (!mounted) return;
      if (changed == true) _refresh();
    } catch (_) {
      if (!mounted) return;
      _showError();
    }
  }

  Future<void> _addContent() async {
    if (!widget.roleSession.canManageContent) {
      _showError('Solo el modo Colaborador puede agregar contenido.');
      return;
    }
    try {
      final saved = await Navigator.pushNamed<Contenido>(
        context,
        Rutas.kContenido,
        arguments: ContenidoFormRouteArgs(categoria: widget.categoria),
      );
      if (!mounted) return;
      if (saved != null) _refresh();
    } catch (_) {
      if (!mounted) return;
      _showError();
    }
  }

  void _showError([String message = Textos.kErrorCarga]) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_title)),
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _search,
            decoration: InputDecoration(
              labelText: 'Buscar en $_title',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Limpiar búsqueda',
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        if (widget.categoria == TipoContenido.lugar ||
            widget.categoria == TipoContenido.festividad)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DropdownButtonFormField<String>(
              initialValue: _district,
              decoration: const InputDecoration(
                labelText: 'Filtrar por distrito',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('Todos los distritos'),
                ),
                ...DatosFormulario.kDistritos.map(
                  (district) =>
                      DropdownMenuItem(value: district, child: Text(district)),
                ),
              ],
              onChanged: (value) =>
                  _changeFilter(district: value, month: _month),
            ),
          ),
        if (widget.categoria == TipoContenido.festividad)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: DropdownButtonFormField<int>(
              initialValue: _month,
              decoration: const InputDecoration(
                labelText: 'Filtrar por mes',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text('Todos los meses'),
                ),
                for (var month = 1; month <= 12; month++)
                  DropdownMenuItem(
                    value: month,
                    child: Text(_monthName(month)),
                  ),
              ],
              onChanged: (value) =>
                  _changeFilter(district: _district, month: value),
            ),
          ),
        Expanded(
          child: FutureBuilder<List<Contenido>>(
            key: ValueKey(_refreshVersion),
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ListState(
                  icon: Icons.error_outline,
                  message: Textos.kErrorCarga,
                  action: TextButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                );
              }
              final contents = snapshot.data ?? const <Contenido>[];
              if (contents.isEmpty) {
                return const _ListState(
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
                  final color = Theme.of(context).colorScheme.primary;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                    itemCount: contents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: Dimensiones.kAlturaTarjeta,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemBuilder: (context, index) => PlaceCard(
                      place: _toGuidePlace(contents[index]),
                      sectionColor: color,
                      onTap: () => _openDetail(contents[index]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    ),
    floatingActionButton: widget.roleSession.canManageContent
        ? FloatingActionButton.extended(
            onPressed: _addContent,
            icon: const Icon(Icons.add),
            label: const Text('Agregar'),
          )
        : null,
  );

  String _monthName(int month) => const [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ][month - 1];

  GuidePlace _toGuidePlace(Contenido content) {
    final category = switch (content) {
      Lugar value => value.distrito,
      Festividad value => '${value.dia}/${value.mes}',
      Plato value => value.tipo,
      _ => widget.categoria.clave,
    };
    final fallbackImage = switch (widget.categoria) {
      TipoContenido.lugar => 'assets/images/categorias/lugares.jpg',
      TipoContenido.festividad => 'assets/images/categorias/festividades.jpg',
      TipoContenido.plato => 'assets/images/categorias/gastronomia.jpg',
    };
    return GuidePlace(
      name: content.nombre,
      category: category,
      imagePath: content.rutaImagen ?? fallbackImage,
      tags: [widget.categoria.clave],
    );
  }
}

class _ListState extends StatelessWidget {
  const _ListState({required this.icon, required this.message, this.action});

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
