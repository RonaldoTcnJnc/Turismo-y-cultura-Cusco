import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guia_turistica_cusco/app.dart';
import 'package:guia_turistica_cusco/data/contenido_repository.dart';
import 'package:guia_turistica_cusco/models/festividad.dart';
import 'package:guia_turistica_cusco/models/lugar.dart';
import 'package:guia_turistica_cusco/models/plato.dart';
import 'package:guia_turistica_cusco/models/contenido.dart';
import 'package:guia_turistica_cusco/navigation/route_arguments.dart';
import 'package:guia_turistica_cusco/pages/cusco_guide_page.dart';
import 'package:guia_turistica_cusco/screens/contenido_detalle_screen.dart';
import 'package:guia_turistica_cusco/widgets/category_carousel.dart';
import 'package:guia_turistica_cusco/services/camara_service.dart';
import 'package:guia_turistica_cusco/services/preferencias_service.dart';
import 'package:guia_turistica_cusco/services/role_session.dart';
import 'package:guia_turistica_cusco/utils/constantes.dart';

void main() {
  Future<_FakePreferenciasService> pumpGuide(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    final preferences = _FakePreferenciasService();
    await tester.pumpWidget(
      MaterialApp(
        home: CuscoGuidePage(
          repository: _FakeContenidoRepository(),
          preferences: preferences,
          roleSession: RoleSession(),
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return preferences;
  }

  testWidgets('no genera restricciones negativas en el calendario semanal', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(12, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGuide(tester);

    expect(find.text('Agenda de la semana'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar categorías del carrusel abre sus listados', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(CuscoGuideApp(roleSession: RoleSession()));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final gastronomyCard = find.descendant(
      of: find.byType(CategoryCarousel),
      matching: find.text('Gastronomía'),
    );
    await tester.tap(gastronomyCard);
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Buscar en Gastronomía'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(CuscoGuideApp(roleSession: RoleSession()));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final festivalsCard = find.descendant(
      of: find.byType(CategoryCarousel),
      matching: find.text('Festividades'),
    );
    await tester.tap(festivalsCard);
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Buscar en Festividades'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(CuscoGuideApp(roleSession: RoleSession()));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final placesCard = find.descendant(
      of: find.byType(CategoryCarousel),
      matching: find.text('Lugares'),
    );
    await tester.tap(placesCard);
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text('Buscar en Lugares'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('muestra datos, conserva pestañas y adapta columnas', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final preferences = await pumpGuide(tester);

    expect(find.text('Explora por categoría'), findsOneWidget);
    expect(find.text('Lugares'), findsWidgets);
    expect(find.text('Festividades'), findsWidgets);
    expect(find.text('Gastronomía'), findsWidgets);
    expect(find.text('EVENTO DEL MES'), findsOneWidget);
    expect(find.text('Inti Raymi'), findsNWidgets(2));
    expect(
      find.text('24/6 · Celebración cultural anual de prueba.'),
      findsOneWidget,
    );
    expect(find.text('Cusco en cifras'), findsOneWidget);
    expect(find.byType(IndexedStack), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.byKey(const ValueKey('lugar-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('festividad-grid')), findsOneWidget);
    expect(find.byKey(const ValueKey('plato-grid')), findsOneWidget);

    final navigationBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navigationBar.items, hasLength(4));
    expect(navigationBar.onTap, isNotNull);

    const layouts = [
      (width: 320.0, columns: 2),
      (width: 800.0, columns: 3),
      (width: 1200.0, columns: 4),
    ];
    for (final layout in layouts) {
      tester.view.physicalSize = Size(layout.width, 900);
      await tester.pump();

      for (final section in ['lugar', 'festividad', 'plato']) {
        final grid = tester.widget<GridView>(
          find.byKey(ValueKey('$section-grid')),
        );
        final delegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(delegate.crossAxisCount, layout.columns);
        expect(delegate.mainAxisExtent, 232);
      }
      final metricsGrid = tester.widget<GridView>(
        find.byKey(const ValueKey('metrics-grid')),
      );
      final metricsDelegate =
          metricsGrid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(metricsDelegate.crossAxisCount, layout.width < 520 ? 2 : 4);
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.text('Agenda').last);
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 2);
    expect(preferences.section, 2);
    await tester.tap(find.text('Explorar').last);
    await tester.pump();
    expect(tester.widget<IndexedStack>(find.byType(IndexedStack)).index, 0);
    expect(find.byKey(const ValueKey('lugar-grid')), findsOneWidget);
  });

  testWidgets('calcula el Evento del mes usando la fecha actual', (
    tester,
  ) async {
    final repository = _FakeContenidoRepository();
    final start = DateTime.now();
    await tester.pumpWidget(
      MaterialApp(
        home: CuscoGuidePage(
          repository: repository,
          preferences: _FakePreferenciasService(),
          roleSession: RoleSession(),
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final end = DateTime.now();

    expect(repository.requestedEventDate, isNotNull);
    expect(
      repository.requestedEventDate!.isBefore(start) ||
          repository.requestedEventDate!.isAfter(end),
      isFalse,
    );
    expect(find.text('EVENTO DEL MES'), findsOneWidget);
  });

  testWidgets('la agenda semanal expone nombres y próximos eventos', (
    tester,
  ) async {
    await pumpGuide(tester);

    expect(find.text('Próximos eventos'), findsOneWidget);
    expect(find.textContaining('Inti Raymi'), findsWidgets);
    expect(find.textContaining('Año Nuevo'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('actualiza el evento al reanudar con la fecha actual', (
    tester,
  ) async {
    final repository = _FakeContenidoRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: CuscoGuidePage(
          repository: repository,
          preferences: _FakePreferenciasService(),
          roleSession: RoleSession(),
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    final requestsBeforeResume = repository.eventRequestCount;

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(repository.eventRequestCount, greaterThan(requestsBeforeResume));
    final now = DateTime.now();
    expect(repository.requestedEventDate, isNotNull);
    expect(
      repository.requestedEventDate!.isAfter(
        now.add(const Duration(seconds: 1)),
      ),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Perfil permite activar el modo Colaborador', (tester) async {
    final roles = RoleSession();
    await tester.pumpWidget(
      MaterialApp(
        home: CuscoGuidePage(
          repository: _FakeContenidoRepository(),
          preferences: _FakePreferenciasService(),
          roleSession: roles,
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(roles.canManageContent, isFalse);
    await tester.tap(find.text('Perfil').last);
    await tester.pump();
    await tester.tap(find.text('Colaborador'));
    await tester.pump();

    expect(roles.canManageContent, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agenda abre el listado completo de festividades', (
    tester,
  ) async {
    final repository = _FakeContenidoRepository();
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) {
          expect(settings.name, Rutas.kCategoria);
          final arguments = settings.arguments! as CategoriaRouteArgs;
          expect(arguments.categoria, TipoContenido.festividad);
          return MaterialPageRoute<void>(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Listado completo de festividades')),
            ),
          );
        },
        home: CuscoGuidePage(
          repository: repository,
          preferences: _FakePreferenciasService(),
          roleSession: RoleSession(),
        ),
      ),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Agenda').last);
    await tester.pump();
    await tester.tap(find.text('VER TODO  ›').last);
    await tester.pumpAndSettle();

    expect(find.text('Listado completo de festividades'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'al guardar desde detalle devuelve true para refrescar la lista',
    (tester) async {
      final favorites = <String>{};
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ContenidoDetalleScreen(
                      contenido: Lugar(
                        id: 42,
                        nombre: 'Test place',
                        distrito: 'Cusco',
                        descripcion: 'Detalle de prueba',
                        creadoEn: DateTime(2026, 10, 23),
                      ),
                      preferences: _TrackingPreferencesService(favorites),
                      roleSession: RoleSession()
                        ..selectRole(UserRole.collaborator),
                    ),
                  ),
                );
              },
              child: const Text('Open detail'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open detail'));
      await tester.pumpAndSettle();

      expect(find.text('Guardar en favoritos'), findsOneWidget);
      await tester.tap(find.text('Guardar en favoritos'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
      expect(favorites, {'lugar:42'});
    },
  );

  testWidgets('visitante aporta una foto al lugar y se actualiza', (
    tester,
  ) async {
    final repository = _PhotoRepository();
    final camera = _FakeCameraService();
    final originalPlace = Lugar(
      id: 12,
      nombre: 'Qorikancha',
      distrito: 'Cusco',
      descripcion: 'Lugar para probar la foto aportada.',
      rutaImagen: 'assets/images/lugares/plaza_de_armas.jpg',
      creadoEn: DateTime(2026, 10, 23),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => ContenidoDetalleScreen(
                    contenido: originalPlace,
                    repository: repository,
                    cameraService: camera,
                    roleSession: RoleSession(),
                  ),
                ),
              );
            },
            child: const Text('Abrir lugar'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir lugar'));
    await tester.pumpAndSettle();
    expect(find.text('Aportar otra fotografía'), findsOneWidget);
    expect(find.byTooltip('Editar'), findsNothing);

    await tester.tap(find.text('Aportar otra fotografía'));
    await tester.pumpAndSettle();

    expect(camera.requestedSource, ImageSource.camera);
    expect(repository.addedPlaceId, 12);
    expect(repository.additionalPhotos, ['/private/place-photo.jpg']);
    expect(
      originalPlace.rutaImagen,
      'assets/images/lugares/plaza_de_armas.jpg',
    );
    expect(find.text('Fotos aportadas'), findsOneWidget);
  });

  testWidgets('edita el perfil durante la sesión sin persistirlo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: CuscoGuidePage(roleSession: RoleSession())),
    );
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Perfil').last);
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(0), 'Ana');
    await tester.enterText(find.byType(TextFormField).at(1), 'ana@cusco.app');
    await tester.enterText(find.byType(TextFormField).at(2), 'Cusco');
    await tester.enterText(find.byType(TextFormField).at(3), 'Nueva bio');
    await tester.ensureVisible(find.text('Guardar'));
    for (var frame = 0; frame < 3; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.tap(find.text('Guardar'));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(0))
          .controller!
          .text,
      'Ana',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(1))
          .controller!
          .text,
      'ana@cusco.app',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(2))
          .controller!
          .text,
      'Cusco',
    );
    expect(
      tester
          .widget<TextFormField>(find.byType(TextFormField).at(3))
          .controller!
          .text,
      'Nueva bio',
    );
    expect(
      find.text('Perfil actualizado durante esta sesión.'),
      findsOneWidget,
    );
    expect(find.text('No se pudo guardar el perfil.'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _TrackingPreferencesService extends PreferenciasService {
  _TrackingPreferencesService(this.favorites);

  final Set<String> favorites;

  @override
  Future<Set<String>> obtenerFavoritos() async => Set<String>.from(favorites);

  @override
  Future<bool> esFavorito(String clave) async => favorites.contains(clave);

  @override
  Future<void> cambiarFavorito(String clave) async {
    if (!favorites.add(clave)) {
      favorites.remove(clave);
    }
  }
}

class _FakeCameraService extends CamaraService {
  ImageSource? requestedSource;

  @override
  Future<String?> elegirYGuardar(ImageSource source) async {
    requestedSource = source;
    return '/private/place-photo.jpg';
  }
}

class _PhotoRepository extends ContenidoRepository {
  int? addedPlaceId;
  final List<String> additionalPhotos = [];

  @override
  Future<int> agregarFotoLugar(int lugarId, String rutaImagen) async {
    addedPlaceId = lugarId;
    additionalPhotos.add(rutaImagen);
    return additionalPhotos.length;
  }

  @override
  Future<List<String>> listarFotosLugar(int lugarId) async =>
      List<String>.from(additionalPhotos);
}

class _FakeContenidoRepository extends ContenidoRepository {
  final DateTime _created = DateTime.utc(2026, 10, 23);
  DateTime? requestedEventDate;
  int eventRequestCount = 0;
  int festivityListCount = 0;

  List<Lugar> get _places => [
    Lugar(
      id: 1,
      nombre: 'Sacsayhuamán',
      distrito: 'Cusco',
      descripcion: 'Complejo arqueológico de prueba para la interfaz.',
      creadoEn: _created,
    ),
    Lugar(
      id: 2,
      nombre: 'Qorikancha',
      distrito: 'Cusco',
      descripcion: 'Templo histórico de prueba para la interfaz.',
      creadoEn: _created,
    ),
  ];

  List<Festividad> get _festivities => [
    Festividad(
      id: 1,
      nombre: 'Inti Raymi',
      mes: 6,
      dia: 24,
      descripcion: 'Celebración cultural anual de prueba.',
      creadoEn: _created,
    ),
    Festividad(
      id: 2,
      nombre: 'Año Nuevo',
      mes: 1,
      dia: 1,
      descripcion: 'Celebración de prueba para próximos eventos.',
      creadoEn: _created,
    ),
  ];

  List<Plato> get _dishes => [
    Plato(
      id: 1,
      nombre: 'Chiri uchu',
      descripcion: 'Plato tradicional de prueba para la interfaz.',
      tipo: 'Festivo',
      creadoEn: _created,
    ),
  ];

  @override
  Future<List<Lugar>> listarLugares({String? texto, String? distrito}) async =>
      _places.where((item) {
        final matchesText =
            texto == null ||
            item.nombre.toLowerCase().contains(texto.toLowerCase());
        final matchesDistrict = distrito == null || item.distrito == distrito;
        return matchesText && matchesDistrict;
      }).toList();

  @override
  Future<List<Festividad>> listarFestividades({
    String? texto,
    String? distrito,
    int? mes,
  }) async {
    festivityListCount++;
    return _festivities.where((item) {
      final matchesText =
          texto == null ||
          item.nombre.toLowerCase().contains(texto.toLowerCase());
      final matchesDistrict = distrito == null || item.distrito == distrito;
      final matchesMonth = mes == null || item.mes == mes;
      return matchesText && matchesDistrict && matchesMonth;
    }).toList();
  }

  @override
  Future<List<Festividad>> listarFestividadesProximas({DateTime? hoy}) async {
    festivityListCount++;
    return _festivities;
  }

  @override
  Future<List<Plato>> listarPlatos({String? texto}) async => _dishes
      .where(
        (item) =>
            texto == null ||
            item.nombre.toLowerCase().contains(texto.toLowerCase()),
      )
      .toList();

  @override
  Future<Festividad?> proximaFestividad({DateTime? hoy}) async {
    eventRequestCount++;
    requestedEventDate = hoy;
    return _festivities.first;
  }
}

class _FakePreferenciasService extends PreferenciasService {
  int section = 0;

  @override
  Future<int> obtenerUltimaSeccion() async => section;

  @override
  Future<void> guardarUltimaSeccion(int index) async {
    section = index;
  }
}
