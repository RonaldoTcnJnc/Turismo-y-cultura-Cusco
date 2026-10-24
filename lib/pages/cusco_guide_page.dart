import 'dart:async';

import 'package:flutter/material.dart';

import '../data/contenido_repository.dart';
import '../models/contenido.dart';
import '../models/festividad.dart';
import '../navigation/route_arguments.dart';
import '../services/preferencias_service.dart';
import '../screens/favoritos_screen.dart';
import '../utils/constantes.dart';
import '../widgets/category_carousel.dart';
import '../widgets/guide_hero.dart';
import '../widgets/metrics_overview.dart';
import '../widgets/monthly_event_banner.dart';
import '../widgets/repository_place_section.dart';
import '../widgets/weekly_calendar.dart';

class CuscoGuidePage extends StatefulWidget {
  const CuscoGuidePage({this.repository, this.preferences, super.key});

  final ContenidoRepository? repository;
  final PreferenciasService? preferences;

  @override
  State<CuscoGuidePage> createState() => _CuscoGuidePageState();
}

class _CuscoGuidePageState extends State<CuscoGuidePage> {
  int _selectedIndex = 0;
  bool _userSelectedSection = false;
  final GlobalKey<_FavoritesTabState> _favoritesTabKey =
      GlobalKey<_FavoritesTabState>();
  late final List<Widget> _tabs = [
    _ExploreTab(repository: widget.repository),
    _FavoritesTab(
      key: _favoritesTabKey,
      repository: widget.repository,
      preferences: widget.preferences,
    ),
    _AgendaTab(repository: widget.repository),
    const _ProfileTab(),
  ];

  PreferenciasService get _preferences =>
      widget.preferences ?? PreferenciasService();

  @override
  void initState() {
    super.initState();
    _restoreSection();
  }

  Future<void> _restoreSection() async {
    try {
      final section = await _preferences.obtenerUltimaSeccion();
      if (!mounted) return;
      if (_userSelectedSection) return;
      setState(() => _selectedIndex = section);
    } catch (_) {
      if (!mounted) return;
      setState(() => _selectedIndex = 0);
    }
  }

  Future<void> _selectSection(int index) async {
    _userSelectedSection = true;
    setState(() => _selectedIndex = index);
    if (index == 1) _favoritesTabKey.currentState?.refresh();
    try {
      await _preferences.guardarUltimaSeccion(index);
      if (!mounted) return;
    } catch (error, stackTrace) {
      debugPrint('No se pudo guardar la sección actual: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la sección actual.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: _tabs),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _selectSection,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _ExploreTab extends StatefulWidget {
  const _ExploreTab({this.repository});

  final ContenidoRepository? repository;

  @override
  State<_ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<_ExploreTab> {
  Timer? _searchTimer;
  String _searchText = '';
  int _refreshVersion = 0;

  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _searchText = value.trim());
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _refreshVersion++);
  }

  Future<List<Contenido>> _load(TipoContenido type) async {
    switch (type) {
      case TipoContenido.lugar:
        return _repository.listarLugares(texto: _searchText);
      case TipoContenido.festividad:
        return _repository.listarFestividades(texto: _searchText);
      case TipoContenido.plato:
        return _repository.listarPlatos(texto: _searchText);
    }
  }

  Future<List<int>> _loadCounts() async {
    final places = await _repository.listarLugares(texto: _searchText);
    final festivities = await _repository.listarFestividades(
      texto: _searchText,
    );
    final dishes = await _repository.listarPlatos(texto: _searchText);
    return [places.length, festivities.length, dishes.length];
  }

  Future<void> _openCategory(TipoContenido type) async {
    await Navigator.pushNamed<void>(
      context,
      Rutas.kCategoria,
      arguments: CategoriaRouteArgs(type),
    );
    if (!mounted) return;
    _refresh();
  }

  Future<void> _openDetail(Contenido content) async {
    final changed = await Navigator.pushNamed<bool>(
      context,
      Rutas.kDetalleContenido,
      arguments: ContenidoDetalleRouteArgs(content),
    );
    if (!mounted) return;
    if (changed == true) _refresh();
  }

  Future<void> _openMap() async {
    await Navigator.pushNamed<void>(context, Rutas.kMapa);
    if (!mounted) return;
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final keySuffix = '$_searchText-$_refreshVersion';

    return SingleChildScrollView(
      key: const PageStorageKey<String>('explore-scroll'),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GuideHero(
                  onSearchChanged: _onSearchChanged,
                  onMapTap: _openMap,
                ),
                const SizedBox(height: 32),
                const CategoryCarousel(),
                const SizedBox(height: 32),
                FutureBuilder<List<int>>(
                  key: ValueKey('counts-$keySuffix'),
                  future: _loadCounts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return _RetryMessage(onRetry: _refresh);
                    }
                    if (!snapshot.hasData) {
                      return const SizedBox(
                        height: 104,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final counts = snapshot.data!;
                    return MetricsOverview(
                      placesCount: counts[0],
                      festivitiesCount: counts[1],
                      dishesCount: counts[2],
                      totalCount: counts.reduce((a, b) => a + b),
                    );
                  },
                ),
                const SizedBox(height: 32),
                const WeeklyCalendar(),
                const SizedBox(height: 32),
                RepositoryPlaceSection(
                  key: ValueKey('places-$keySuffix'),
                  tipo: TipoContenido.lugar,
                  title: 'Lugares',
                  subtitle: 'Rincones que cuentan siglos',
                  future: _load(TipoContenido.lugar),
                  onViewAll: () => _openCategory(TipoContenido.lugar),
                  onContentTap: _openDetail,
                ),
                const SizedBox(height: 32),
                RepositoryPlaceSection(
                  key: ValueKey('festivals-$keySuffix'),
                  tipo: TipoContenido.festividad,
                  title: 'Festividades',
                  subtitle: 'Rituales, música y comunidad',
                  future: _load(TipoContenido.festividad),
                  onViewAll: () => _openCategory(TipoContenido.festividad),
                  onContentTap: _openDetail,
                ),
                const SizedBox(height: 32),
                RepositoryPlaceSection(
                  key: ValueKey('dishes-$keySuffix'),
                  tipo: TipoContenido.plato,
                  title: 'Gastronomía',
                  subtitle: 'Sabores nacidos en los Andes',
                  future: _load(TipoContenido.plato),
                  onViewAll: () => _openCategory(TipoContenido.plato),
                  onContentTap: _openDetail,
                ),
                const SizedBox(height: 32),
                FutureBuilder<Festividad?>(
                  key: ValueKey('event-$keySuffix'),
                  future: _repository.proximaFestividad(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return _RetryMessage(onRetry: _refresh);
                    }
                    final event = snapshot.data;
                    if (event == null) {
                      return const SizedBox.shrink();
                    }
                    return MonthlyEventBanner(
                      title: event.nombre,
                      description: event.descripcion,
                      dateLabel: '${event.dia}/${event.mes}',
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Cusco se descubre paso a paso.',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AgendaTab extends StatefulWidget {
  const _AgendaTab({this.repository});

  final ContenidoRepository? repository;

  @override
  State<_AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<_AgendaTab> {
  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();
  late Future<List<Contenido>> _future;

  @override
  void initState() {
    super.initState();
    _future = (widget.repository ?? ContenidoRepository()).listarFestividades();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _repository.listarFestividades());
  }

  @override
  Widget build(BuildContext context) => _TabScaffold(
    title: 'Agenda cultural',
    child: RepositoryPlaceSection(
      tipo: TipoContenido.festividad,
      title: 'Festividades',
      subtitle: 'Rituales, música y comunidad',
      future: _future,
      onViewAll: _reload,
    ),
  );
}

class _FavoritesTab extends StatefulWidget {
  const _FavoritesTab({this.repository, this.preferences, super.key});

  final ContenidoRepository? repository;
  final PreferenciasService? preferences;

  @override
  State<_FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<_FavoritesTab> {
  final GlobalKey<FavoritosScreenState> _favoritesKey =
      GlobalKey<FavoritosScreenState>();

  void refresh() => _favoritesKey.currentState?.refresh();

  Future<void> _openFavorites() async {
    await Navigator.pushNamed<void>(context, Rutas.kFavoritos);
    if (!mounted) return;
    _favoritesKey.currentState?.refresh();
  }

  @override
  Widget build(BuildContext context) => _TabScaffold(
    title: 'Guardados',
    onOpen: _openFavorites,
    child: FavoritosScreen(
      key: _favoritesKey,
      repository: widget.repository,
      preferences: widget.preferences,
      embedded: true,
    ),
  );
}

const Map<String, String> _defaultProfile = {
  'nombre': 'Turista',
  'email': 'usuario@cusco.app',
  'ciudad': 'Cusco',
  'bio': 'Explorador de la cultura cusqueña.',
};

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  late Future<Map<String, String>> _future;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cityController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = Future.value(_defaultProfile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _fillForm(Map<String, String> profile) {
    final nextName = profile['nombre'] ?? 'Turista';
    final nextEmail = profile['email'] ?? 'usuario@cusco.app';
    final nextCity = profile['ciudad'] ?? 'Cusco';
    final nextBio = profile['bio'] ?? 'Explorador de la cultura cusqueña.';

    if (_nameController.text != nextName) _nameController.text = nextName;
    if (_emailController.text != nextEmail) _emailController.text = nextEmail;
    if (_cityController.text != nextCity) _cityController.text = nextCity;
    if (_bioController.text != nextBio) _bioController.text = nextBio;
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    final nextProfile = {
      'nombre': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'ciudad': _cityController.text.trim(),
      'bio': _bioController.text.trim(),
    };
    setState(() {
      _future = Future.value(nextProfile);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil actualizado durante esta sesión.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TabScaffold(
      title: 'Perfil',
      child: FutureBuilder<Map<String, String>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No se pudo cargar el perfil.'));
          }

          final profile = snapshot.data!;
          _fillForm(profile);

          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              child: Icon(Icons.person_outline),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameController.text,
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _cityController.text,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.icon(
                              onPressed: _saveProfile,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Guardar'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) =>
                              (value == null || value.trim().isEmpty)
                                  ? 'Ingresa tu nombre'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Correo no válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ciudad',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _bioController,
                          maxLines: 4,
                          decoration: const InputDecoration(
                            labelText: 'Biografía',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TabScaffold extends StatelessWidget {
  const _TabScaffold({required this.title, required this.child, this.onOpen});

  final String title;
  final Widget child;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    key: PageStorageKey<String>('tab-$title'),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (onOpen != null)
                    IconButton(
                      tooltip: 'Abrir pantalla de favoritos',
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_full),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

class _RetryMessage extends StatelessWidget {
  const _RetryMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      children: [
        const Text(Textos.kErrorCarga),
        TextButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
        ),
      ],
    ),
  );
}
