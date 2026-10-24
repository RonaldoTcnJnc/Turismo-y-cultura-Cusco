import '../models/contenido.dart';
import '../models/festividad.dart';
import '../models/lugar.dart';
import '../models/plato.dart';
import 'database_helper.dart';

class ContenidoRepository {
  ContenidoRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _databaseHelper;

  Future<List<Contenido>> listar(
    TipoContenido tipo, {
    String? texto,
    String? distrito,
    int? mes,
  }) async {
    final db = await _databaseHelper.database;
    final filtros = <String>[];
    final argumentos = <Object?>[];

    if (texto != null && texto.trim().isNotEmpty) {
      filtros.add('(nombre LIKE ? OR descripcion LIKE ?)');
      final patron = '%${texto.trim()}%';
      argumentos
        ..add(patron)
        ..add(patron);
    }
    if (distrito != null && distrito.trim().isNotEmpty) {
      if (tipo == TipoContenido.lugar || tipo == TipoContenido.festividad) {
        filtros.add('distrito = ?');
        argumentos.add(distrito.trim());
      }
    }
    if (mes != null && tipo == TipoContenido.festividad) {
      filtros.add('mes = ?');
      argumentos.add(mes);
    }

    final filas = await db.query(
      tipo.tabla,
      where: filtros.isEmpty ? null : filtros.join(' AND '),
      whereArgs: argumentos.isEmpty ? null : argumentos,
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return filas.map((fila) => Contenido.fromMap(tipo, fila)).toList();
  }

  Future<Contenido?> obtenerPorId(TipoContenido tipo, int id) async {
    final db = await _databaseHelper.database;
    final filas = await db.query(
      tipo.tabla,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Contenido.fromMap(tipo, filas.first);
  }

  Future<int> insertar(Contenido contenido) async {
    final db = await _databaseHelper.database;
    final datos = contenido.toMap()..remove('id');
    return db.insert(contenido.tipoContenido.tabla, datos);
  }

  Future<int> actualizar(Contenido contenido) async {
    final id = contenido.id;
    if (id == null) {
      throw ArgumentError('No se puede actualizar contenido sin id.');
    }
    final db = await _databaseHelper.database;
    final datos = contenido.toMap()..remove('id');
    return db.update(
      contenido.tipoContenido.tabla,
      datos,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> eliminar(TipoContenido tipo, int id) async {
    final db = await _databaseHelper.database;
    return db.delete(tipo.tabla, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> existeNombre(
    TipoContenido tipo,
    String nombre, {
    int? excluirId,
  }) async {
    final db = await _databaseHelper.database;
    final filtros = <String>['nombre = ?'];
    final argumentos = <Object?>[nombre.trim()];
    if (excluirId != null) {
      filtros.add('id != ?');
      argumentos.add(excluirId);
    }
    final filas = await db.query(
      tipo.tabla,
      columns: ['id'],
      where: filtros.join(' AND '),
      whereArgs: argumentos,
      limit: 1,
    );
    return filas.isNotEmpty;
  }

  Future<List<Lugar>> listarLugares({String? texto, String? distrito}) async =>
      (await listar(
        TipoContenido.lugar,
        texto: texto,
        distrito: distrito,
      )).cast<Lugar>();

  Future<List<Festividad>> listarFestividades({
    String? texto,
    String? distrito,
    int? mes,
  }) async => (await listar(
    TipoContenido.festividad,
    texto: texto,
    distrito: distrito,
    mes: mes,
  )).cast<Festividad>();

  Future<List<Plato>> listarPlatos({String? texto}) async =>
      (await listar(TipoContenido.plato, texto: texto)).cast<Plato>();

  Future<Festividad?> proximaFestividad({DateTime? hoy}) async {
    final events = await listarFestividades();
    final date = hoy ?? DateTime.now();
    final today = DateTime(date.year, date.month, date.day);
    final occurrences = <({Festividad event, DateTime date})>[];

    for (final event in events) {
      final occurrence = _nextOccurrence(event, today);
      if (occurrence != null) {
        occurrences.add((event: event, date: occurrence));
      }
    }
    if (occurrences.isEmpty) return null;
    occurrences.sort((first, second) => first.date.compareTo(second.date));
    return occurrences.first.event;
  }

  DateTime? _nextOccurrence(Festividad event, DateTime today) {
    for (var year = today.year; year <= today.year + 8; year++) {
      final candidate = DateTime(year, event.mes, event.dia);
      if (candidate.month != event.mes || candidate.day != event.dia) continue;
      if (!candidate.isBefore(today)) return candidate;
    }
    return null;
  }
}
