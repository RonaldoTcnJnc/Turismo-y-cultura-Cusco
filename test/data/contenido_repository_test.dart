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
    expect((await repository.listarFestividades()).length, 4);
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
    final guardada =
        await repository.obtenerPorId(TipoContenido.festividad, id)
            as Festividad?;
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

  test('mantiene versión 1, índices y restricciones de clave foránea', () async {
    final db = await databaseHelper.database;
    final version = await db.rawQuery('PRAGMA user_version');
    final foreignKeys = await db.rawQuery('PRAGMA foreign_keys');
    final indexes = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index'",
    );

    expect(version.single['user_version'], 1);
    expect(foreignKeys.single['foreign_keys'], 1);
    expect(indexes.map((row) => row['name']), contains('idx_lugares_distrito'));
    expect(indexes.map((row) => row['name']), contains('idx_festividades_mes'));
  });

  test('elige la siguiente festividad cruzando el cambio de año', () async {
    final event = await repository.proximaFestividad(
      hoy: DateTime(2026, 12, 31),
    );
    expect(event?.nombre, 'Señor de los Temblores');
    expect(event?.mes, 3);
    expect(event?.dia, 30);
  });

  test('incluye la festividad del mismo día como próxima ocurrencia', () async {
    final event = await repository.proximaFestividad(
      hoy: DateTime(2026, 6, 24),
    );
    expect(event?.nombre, 'Inti Raymi');
  });
}
