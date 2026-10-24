import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/data/contenido_repository.dart';
import 'package:guia_turistica_cusco/models/festividad.dart';
import 'package:guia_turistica_cusco/models/lugar.dart';
import 'package:guia_turistica_cusco/models/plato.dart';
import 'package:guia_turistica_cusco/pages/cusco_guide_page.dart';
import 'package:guia_turistica_cusco/screens/contenido_detalle_screen.dart';
import 'package:guia_turistica_cusco/services/preferencias_service.dart';

void main() {
  Future<_FakePreferenciasService> pumpGuide(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    final preferences = _FakePreferenciasService();
    await tester.pumpWidget(
      MaterialApp(
        home: CuscoGuidePage(
          repository: _FakeContenidoRepository(),
          preferences: preferences,
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

  testWidgets('al guardar desde detalle devuelve true para refrescar la lista', (
    tester,
  ) async {
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
  });

  testWidgets('edita el perfil durante la sesión sin persistirlo', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CuscoGuidePage(),
      ),
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
    await tester.tap(find.text('Guardar'));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(0)).controller!.text,
      'Ana',
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(1)).controller!.text,
      'ana@cusco.app',
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(2)).controller!.text,
      'Cusco',
    );
    expect(
      tester.widget<TextFormField>(find.byType(TextFormField).at(3)).controller!.text,
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

class _FakeContenidoRepository extends ContenidoRepository {
  final DateTime _created = DateTime.utc(2026, 10, 23);

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
  }) async => _festivities.where((item) {
    final matchesText =
        texto == null ||
        item.nombre.toLowerCase().contains(texto.toLowerCase());
    final matchesDistrict = distrito == null || item.distrito == distrito;
    final matchesMonth = mes == null || item.mes == mes;
    return matchesText && matchesDistrict && matchesMonth;
  }).toList();

  @override
  Future<List<Plato>> listarPlatos({String? texto}) async => _dishes
      .where(
        (item) =>
            texto == null ||
            item.nombre.toLowerCase().contains(texto.toLowerCase()),
      )
      .toList();

  @override
  Future<Festividad?> proximaFestividad({DateTime? hoy}) async =>
      _festivities.first;
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
