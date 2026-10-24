import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:guia_turistica_cusco/data/contenido_repository.dart';
import 'package:guia_turistica_cusco/data/database_helper.dart';
import 'package:guia_turistica_cusco/models/contenido.dart';
import 'package:guia_turistica_cusco/models/festividad.dart';
import 'package:guia_turistica_cusco/models/lugar.dart';
import 'package:guia_turistica_cusco/models/plato.dart';

void main() {
  late DatabaseHelper databaseHelper;
  late ContenidoRepository repository;

  setUp(() async {
    sqfliteFfiInit();
    databaseHelper = DatabaseHelper.forTesting(
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    repository = ContenidoRepository(databaseHelper: databaseHelper);
    await databaseHelper.database;
  });

  tearDown(() async {
    await databaseHelper.close();
  });

  test('crea la semilla y busca con filtros parametrizados', () async {
    expect((await repository.listarLugares()).length, 6);
    expect((await repository.listarFestividades()).length, 15);
    expect((await repository.listarPlatos()).length, 5);

    final sitios = await repository.listarLugares(
      texto: 'plaza',
      distrito: 'Cusco',
    );
    expect(sitios, hasLength(1));
    expect(sitios.single.nombre, 'Plaza de Armas del Cusco');

    final festividades = await repository.listarFestividades(mes: 6);
    expect(festividades, hasLength(2));
  });

  test('completa alta, edición, consulta y eliminación de un lugar', () async {
    final creado = DateTime.utc(2026, 10, 23);
    final lugar = Lugar(
      nombre: 'Prueba persistente',
      distrito: 'Cusco',
      descripcion: 'Lugar de prueba para verificar el ciclo CRUD en SQLite.',
      latitud: -13.52,
      longitud: -71.97,
      creadoEn: creado,
    );

    final id = await repository.insertar(lugar);
    expect(
      await repository.existeNombre(TipoContenido.lugar, lugar.nombre),
      isTrue,
    );
    expect(
      await repository.existeNombre(
        TipoContenido.lugar,
        lugar.nombre,
        excluirId: id,
      ),
      isFalse,
    );

    final actualizado = Lugar(
      id: id,
      nombre: lugar.nombre,
      distrito: 'San Sebastián',
      descripcion: lugar.descripcion,
      latitud: lugar.latitud,
      longitud: lugar.longitud,
      creadoEn: creado,
    );
    expect(await repository.actualizar(actualizado), 1);
    final guardado =
        await repository.obtenerPorId(TipoContenido.lugar, id) as Lugar?;
    expect(guardado?.distrito, 'San Sebastián');

    expect(await repository.eliminar(TipoContenido.lugar, id), 1);
    expect(await repository.obtenerPorId(TipoContenido.lugar, id), isNull);
  });

  test(
    'agrega varias fotos sin reemplazar la imagen principal del lugar',
    () async {
      final db = await databaseHelper.database;
      final coverBefore = await db.query(
        'lugares',
        columns: ['ruta_imagen'],
        where: 'id = ?',
        whereArgs: [1],
      );

      await repository.agregarFotoLugar(1, '/photos/visit-1.jpg');
      await repository.agregarFotoLugar(1, '/photos/visit-2.jpg');

      final photos = await repository.listarFotosLugar(1);
      final coverAfter = await db.query(
        'lugares',
        columns: ['ruta_imagen'],
        where: 'id = ?',
        whereArgs: [1],
      );
      expect(photos, ['/photos/visit-1.jpg', '/photos/visit-2.jpg']);
      expect(
        coverAfter.single['ruta_imagen'],
        coverBefore.single['ruta_imagen'],
      );
    },
  );

  test('completa alta, edición y eliminación de una festividad', () async {
    final creado = DateTime.utc(2026, 10, 23);
    final festival = Festividad(
      nombre: 'Festival de prueba',
      mes: 8,
      dia: 12,
      descripcion: 'Celebración de prueba para validar persistencia local.',
      distrito: 'Cusco',
      creadoEn: creado,
    );

    final id = await repository.insertar(festival);
    final actualizada = Festividad(
      id: id,
      nombre: festival.nombre,
      mes: 8,
      dia: 13,
      descripcion: festival.descripcion,
      distrito: 'San Sebastián',
      creadoEn: creado,
    );
    expect(await repository.actualizar(actualizada), 1);
    final guardada = await repository.obtenerPorId(
      TipoContenido.festividad,
      id,
    ) as Festividad?;
    expect(guardada?.dia, 13);
    expect(guardada?.distrito, 'San Sebastián');

    expect(await repository.eliminar(TipoContenido.festividad, id), 1);
    expect(await repository.obtenerPorId(TipoContenido.festividad, id), isNull);
  });

  test('completa alta, edición y eliminación de un plato', () async {
    final creado = DateTime.utc(2026, 10, 23);
    final dish = Plato(
      nombre: 'Plato de prueba',
      descripcion: 'Preparación de prueba para verificar las operaciones CRUD.',
      precioRef: 12,
      tipo: 'Entrada',
      creadoEn: creado,
    );

    final id = await repository.insertar(dish);
    final actualizado = Plato(
      id: id,
      nombre: dish.nombre,
      descripcion: dish.descripcion,
      precioRef: 15,
      tipo: 'Plato principal',
      creadoEn: creado,
    );
    expect(await repository.actualizar(actualizado), 1);
    final guardado =
        await repository.obtenerPorId(TipoContenido.plato, id) as Plato?;
    expect(guardado?.precioRef, 15);
    expect(guardado?.tipo, 'Plato principal');

    expect(await repository.eliminar(TipoContenido.plato, id), 1);
    expect(await repository.obtenerPorId(TipoContenido.plato, id), isNull);
  });

  test('mantiene versión 7, índices y tabla de fotos relacionadas', () async {
    final db = await databaseHelper.database;
    final version = await db.rawQuery('PRAGMA user_version');
    final foreignKeys = await db.rawQuery('PRAGMA foreign_keys');
    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );

    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table'",
    );

    expect(version.single['user_version'], 7);
    expect(foreignKeys.single['foreign_keys'], 1);
    expect(indexes.map((row) => row['name']), contains('idx_lugares_distrito'));
    expect(indexes.map((row) => row['name']), contains('idx_festividades_mes'));
    expect(tables.map((row) => row['name']), contains('lugares_imagenes'));
  });

  test('asigna fotos específicas a las nuevas festividades', () async {
    final events = await repository.listarFestividades();
    final imageByName = {
      for (final event in events) event.nombre: event.rutaImagen,
    };

    expect(
      imageByName['Todos los Santos'],
      'assets/images/festividades/todos_los_santos.jpg',
    );
    expect(
      imageByName['Conmemoración de los Difuntos'],
      'assets/images/festividades/todos_los_santos.jpg',
    );
    expect(
      imageByName['Inmaculada Concepción'],
      'assets/images/festividades/inmaculada_concepcion.jpg',
    );
    expect(
      imageByName['Santurantikuy'],
      'assets/images/festividades/santurantikuy.jpg',
    );
    expect(
      imageByName['Takanakuy de Santo Tomás'],
      'assets/images/festividades/takanakuy.jpg',
    );
    expect(imageByName['Navidad'], 'assets/images/festividades/navidad.jpg');
    expect(
      imageByName['Año Nuevo'],
      'assets/images/festividades/año_nuevo.jpg',
    );
    expect(
      imageByName['Bajada de Reyes'],
      'assets/images/festividades/bajada_de_reyes.jpg',
    );
    expect(
      imageByName['Fiesta de San Blas'],
      'assets/images/festividades/templo_san_blas.jpg',
    );
    expect(
      imageByName['Festividad de San Sebastián'],
      'assets/images/festividades/festividad_de_san_sebastian.jpg',
    );
    expect(imageByName['Chiaraje'], 'assets/images/festividades/chiaraje.jpg');
    expect(events.every((event) => event.rutaImagen != null), isTrue);
  });

  test('asigna fotos del lugar o plato correcto a datos iniciales', () async {
    final places = await repository.listarLugares();
    final dishes = await repository.listarPlatos();
    final placeImages = {
      for (final item in places) item.nombre: item.rutaImagen,
    };
    final dishImages = {
      for (final item in dishes) item.nombre: item.rutaImagen,
    };

    expect(placeImages['Qorikancha'], 'assets/images/lugares/qorikancha.jpg');
    expect(
      placeImages['Plaza de Armas del Cusco'],
      'assets/images/lugares/plaza_de_armas_cusco.jpg',
    );
    expect(placeImages["Q'enqo"], 'assets/images/lugares/qenqo.jpg');
    expect(
      placeImages['Mercado San Pedro'],
      'assets/images/lugares/mercado_san_pedro.jpg',
    );
    expect(
      dishImages['Cuy chactado'],
      'assets/images/gastronomia/cuy_chactado.jpg',
    );
    expect(
      dishImages['Adobo cusqueño'],
      'assets/images/gastronomia/adobo_cusqueno.jpg',
    );
    expect(dishImages['Chairo'], 'assets/images/gastronomia/chairo.jpg');
    expect(
      dishImages['Tamales cusqueños'],
      'assets/images/gastronomia/tamal_cusqueno.jpg',
    );
  });

  test('elige la siguiente festividad cruzando el cambio de año', () async {
    final event = await repository.proximaFestividad(
      hoy: DateTime(2026, 12, 31),
    );
    expect(event?.nombre, 'Año Nuevo');
    expect(event?.mes, 1);
    expect(event?.dia, 1);
  });

  test('elige por proximidad entre festividades próximas', () async {
    final event = await repository.proximaFestividad(hoy: DateTime(2026, 6, 1));

    expect(event?.nombre, 'Corpus Christi');
    expect(event?.mes, 6);
    expect(event?.dia, 11);
  });

  test('ordena la agenda por la siguiente fecha desde hoy', () async {
    final events = await repository.listarFestividadesProximas(
      hoy: DateTime(2026, 10, 23),
    );

    expect(events.take(4).map((event) => event.nombre), [
      'Todos los Santos',
      'Conmemoración de los Difuntos',
      'Inmaculada Concepción',
      'Santurantikuy',
    ]);
  });

  test('incluye la festividad del mismo día como próxima ocurrencia', () async {
    final event = await repository.proximaFestividad(
      hoy: DateTime(2026, 6, 24),
    );
    expect(event?.nombre, 'Inti Raymi');
  });
}
