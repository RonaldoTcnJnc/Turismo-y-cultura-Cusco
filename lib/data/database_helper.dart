import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory.dart';

class DatabaseHelper {
  DatabaseHelper._({this.factoryOverride, this.pathOverride});

  static final DatabaseHelper instance = DatabaseHelper._();
  static const int databaseVersion = 7;
  static const String databaseName = 'guia_cusco.db';

  @visibleForTesting
  DatabaseHelper.forTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) : this._(factoryOverride: factory, pathOverride: databasePath);

  final DatabaseFactory? factoryOverride;
  final String? pathOverride;
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final factory = factoryOverride ?? await createDatabaseFactory();
    final databasePath = pathOverride ?? await _databasePath();
    _database = await factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<String> _databasePath() async {
    if (kIsWeb) return databaseName;
    final directory = await getApplicationDocumentsDirectory();
    return path.join(directory.path, databaseName);
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lugares (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        distrito TEXT NOT NULL,
        descripcion TEXT NOT NULL,
        latitud REAL CHECK(latitud IS NULL OR latitud BETWEEN -90 AND 90),
        longitud REAL CHECK(longitud IS NULL OR longitud BETWEEN -180 AND 180),
        ruta_imagen TEXT,
        creado_en TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE festividades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        mes INTEGER NOT NULL CHECK(mes BETWEEN 1 AND 12),
        dia INTEGER NOT NULL CHECK(dia BETWEEN 1 AND 31),
        descripcion TEXT NOT NULL,
        distrito TEXT,
        ruta_imagen TEXT,
        creado_en TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE platos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL UNIQUE,
        descripcion TEXT NOT NULL,
        precio_ref REAL CHECK(precio_ref IS NULL OR precio_ref >= 0),
        tipo TEXT NOT NULL,
        ruta_imagen TEXT,
        creado_en TEXT NOT NULL
      )
    ''');
    await _createLugarPhotosTable(db);

    await db.execute('CREATE INDEX idx_lugares_nombre ON lugares(nombre)');
    await db.execute('CREATE INDEX idx_lugares_distrito ON lugares(distrito)');
    await db.execute(
      'CREATE INDEX idx_festividades_nombre ON festividades(nombre)',
    );
    await db.execute('CREATE INDEX idx_festividades_mes ON festividades(mes)');
    await db.execute(
      'CREATE INDEX idx_festividades_distrito ON festividades(distrito)',
    );
    await db.execute('CREATE INDEX idx_platos_nombre ON platos(nombre)');
    await _seed(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2 && newVersion >= 2) {
      await _createLugarPhotosTable(db);
    }
    if (oldVersion < 3 && newVersion >= 3) {
      await _seedUpcomingFestivities(db);
    }
    if (oldVersion < 4 && newVersion >= 4) {
      await _updateUpcomingFestivityImages(db);
    }
    if (oldVersion < 5 && newVersion >= 5) {
      await _updateSeedImagePaths(db);
    }
    if (oldVersion < 6 && newVersion >= 6) {
      await _clearWrongHolidayImages(db);
    }
    if (oldVersion < 7 && newVersion >= 7) {
      await _updateUpcomingFestivityImages(db);
      await _updateSeedImagePaths(db);
    }
  }

  Future<void> _createLugarPhotosTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE lugares_imagenes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lugar_id INTEGER NOT NULL,
        ruta_imagen TEXT NOT NULL,
        agregado_en TEXT NOT NULL,
        FOREIGN KEY (lugar_id) REFERENCES lugares(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_lugares_imagenes_lugar ON lugares_imagenes(lugar_id)',
    );
  }

  Future<void> _seed(Database db) async {
    final creadoEn = DateTime.now().toIso8601String();
    await db.transaction((transaction) async {
      for (final lugar in _lugaresIniciales) {
        await transaction.insert('lugares', {...lugar, 'creado_en': creadoEn});
      }
      for (final festividad in _festividadesIniciales) {
        await transaction.insert('festividades', {
          ...festividad,
          'creado_en': creadoEn,
        });
      }
      for (final festividad in _festividadesProximas) {
        await transaction.insert('festividades', {
          ...festividad,
          'creado_en': creadoEn,
        });
      }
      for (final plato in _platosIniciales) {
        await transaction.insert('platos', {...plato, 'creado_en': creadoEn});
      }
    });
  }

  Future<void> _seedUpcomingFestivities(Database db) async {
    final creadoEn = DateTime.now().toIso8601String();
    await db.transaction((transaction) async {
      for (final festividad in _festividadesProximas) {
        await transaction.insert('festividades', {
          ...festividad,
          'creado_en': creadoEn,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  Future<void> _updateUpcomingFestivityImages(Database db) async {
    await db.transaction((transaction) async {
      for (final entry in _upcomingFestivityImages.entries) {
        await transaction.update(
          'festividades',
          {'ruta_imagen': entry.value},
          where: 'nombre = ?',
          whereArgs: [entry.key],
        );
      }
    });
  }

  Future<void> _updateSeedImagePaths(Database db) async {
    await db.transaction((transaction) async {
      for (final entry in _seedImagePaths.entries) {
        await transaction.update(
          entry.key.table,
          {'ruta_imagen': entry.value},
          where: 'nombre = ?',
          whereArgs: [entry.key.name],
        );
      }
    });
  }

  Future<void> _clearWrongHolidayImages(Database db) async {
    await db.transaction((transaction) async {
      for (final entry in _wrongHolidayImages.entries) {
        await transaction.update(
          'festividades',
          {'ruta_imagen': entry.value},
          where: 'nombre = ?',
          whereArgs: [entry.key],
        );
      }
    });
  }
}

const Map<String, String?> _wrongHolidayImages = {
  'Navidad': null,
  'Año Nuevo': null,
  'Bajada de Reyes': null,
  'Festividad de San Sebastián': null,
  'Chiaraje': null,
};

const Map<({String table, String name}), String?> _seedImagePaths = {
  (table: 'lugares', name: 'Qorikancha'):
      'assets/images/lugares/qorikancha.jpg',
  (table: 'lugares', name: 'Plaza de Armas del Cusco'):
      'assets/images/lugares/plaza_de_armas_cusco.jpg',
  (table: 'lugares', name: "Q'enqo"): 'assets/images/lugares/qenqo.jpg',
  (table: 'lugares', name: 'Mercado San Pedro'):
      'assets/images/lugares/mercado_san_pedro.jpg',
  (table: 'festividades', name: "Qoyllur Rit'i"):
      'assets/images/festividades/qoyllur_riti.jpg',
  (table: 'festividades', name: 'Señor de los Temblores'):
      'assets/images/festividades/senor_de_los_temblores.jpg',
  (table: 'festividades', name: 'Festividad de San Sebastián'):
      'assets/images/festividades/festividad_de_san_sebastian.jpg',
  (table: 'festividades', name: 'Chiaraje'):
      'assets/images/festividades/chiaraje.jpg',
  (table: 'festividades', name: 'Fiesta de San Blas'):
      'assets/images/festividades/templo_san_blas.jpg',
  (table: 'platos', name: 'Cuy chactado'):
      'assets/images/gastronomia/cuy_chactado.jpg',
  (table: 'platos', name: 'Adobo cusqueño'):
      'assets/images/gastronomia/adobo_cusqueno.jpg',
  (table: 'platos', name: 'Chairo'): 'assets/images/gastronomia/chairo.jpg',
  (table: 'platos', name: 'Tamales cusqueños'):
      'assets/images/gastronomia/tamal_cusqueno.jpg',
};

const Map<String, String?> _upcomingFestivityImages = {
  'Todos los Santos': 'assets/images/festividades/todos_los_santos.jpg',
  'Conmemoración de los Difuntos':
      'assets/images/festividades/todos_los_santos.jpg',
  'Inmaculada Concepción':
      'assets/images/festividades/inmaculada_concepcion.jpg',
  'Santurantikuy': 'assets/images/festividades/santurantikuy.jpg',
  'Takanakuy de Santo Tomás': 'assets/images/festividades/takanakuy.jpg',
  'Navidad': 'assets/images/festividades/navidad.jpg',
  'Año Nuevo': 'assets/images/festividades/año_nuevo.jpg',
  'Bajada de Reyes': 'assets/images/festividades/bajada_de_reyes.jpg',
  'Festividad de San Sebastián':
      'assets/images/festividades/festividad_de_san_sebastian.jpg',
  'Chiaraje': 'assets/images/festividades/chiaraje.jpg',
};

const List<Map<String, Object?>> _lugaresIniciales = [
  {
    'nombre': 'Sacsayhuamán',
    'distrito': 'Cusco',
    'descripcion': 'Complejo arqueológico inca reconocido por sus enormes muros de piedra y vistas de la ciudad.',
    'latitud': -13.5087,
    'longitud': -71.9817,
    'ruta_imagen': 'assets/images/lugares/sacsayhuaman.jpg',
  },
  {
    'nombre': 'Qorikancha',
    'distrito': 'Cusco',
    'descripcion': 'Templo del Sol inca cuyos muros originales forman parte del convento de Santo Domingo.',
    'latitud': -13.5207,
    'longitud': -71.9753,
    'ruta_imagen': 'assets/images/lugares/qorikancha.jpg',
  },
  {
    'nombre': 'Plaza de Armas del Cusco',
    'distrito': 'Cusco',
    'descripcion': 'Centro histórico de la ciudad, rodeado de templos, portales y espacios de encuentro.',
    'latitud': -13.5164,
    'longitud': -71.9785,
    'ruta_imagen': 'assets/images/lugares/plaza_de_armas_cusco.jpg',
  },
  {
    'nombre': "Q'enqo",
    'distrito': 'Cusco',
    'descripcion': 'Sitio ceremonial inca con formaciones de roca tallada y espacios rituales al aire libre.',
    'latitud': -13.5084,
    'longitud': -71.9619,
    'ruta_imagen': 'assets/images/lugares/qenqo.jpg',
  },
  {
    'nombre': 'Mercado San Pedro',
    'distrito': 'Cusco',
    'descripcion': 'Mercado tradicional cercano al centro donde se encuentran productos, comidas y artesanía local.',
    'latitud': -13.5202,
    'longitud': -71.9833,
    'ruta_imagen': 'assets/images/lugares/mercado_san_pedro.jpg',
  },
  {
    'nombre': 'Machu Picchu',
    'distrito': 'Machupicchu',
    'descripcion': 'Santuario histórico inca situado entre montañas y reconocido como patrimonio mundial.',
    'latitud': -13.1631,
    'longitud': -72.5450,
    'ruta_imagen': 'assets/images/lugares/machu_picchu.jpg',
  },
];

const List<Map<String, Object?>> _festividadesIniciales = [
  {
    'nombre': 'Inti Raymi',
    'mes': 6,
    'dia': 24,
    'descripcion': 'Representación contemporánea de la ceremonia inca al Sol, celebrada cada 24 de junio en Cusco.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/inti_raymi.jpg',
  },
  {
    'nombre': 'Corpus Christi',
    'mes': 6,
    'dia': 11,
    'descripcion': 'Celebración religiosa con procesión de santos; su fecha es móvil y el día semilla es referencial.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/corpus_christi.jpg',
  },
  {
    'nombre': "Qoyllur Rit'i",
    'mes': 5,
    'dia': 31,
    'descripcion': 'Peregrinación andina al santuario del Señor de Qoyllur Rit’i; su fecha varía y este día es referencial.',
    'distrito': 'Ocongate',
    'ruta_imagen': 'assets/images/festividades/qoyllur_riti.jpg',
  },
  {
    'nombre': 'Señor de los Temblores',
    'mes': 3,
    'dia': 30,
    'descripcion': 'Patrón jurado del Cusco, venerado durante Semana Santa; la fecha cambia cada año y es referencial.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/senor_de_los_temblores.jpg',
  },
];

const List<Map<String, Object?>> _festividadesProximas = [
  {
    'nombre': 'Todos los Santos',
    'mes': 11,
    'dia': 1,
    'descripcion': 'Solemnidad observada en Cusco con visitas familiares a los cementerios y ofrendas tradicionales.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/todos_los_santos.jpg',
  },
  {
    'nombre': 'Conmemoración de los Difuntos',
    'mes': 11,
    'dia': 2,
    'descripcion': 'Jornada de recuerdo a los difuntos, acompañada por visitas a cementerios y costumbres familiares.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/todos_los_santos.jpg',
  },
  {
    'nombre': 'Inmaculada Concepción',
    'mes': 12,
    'dia': 8,
    'descripcion': 'Celebración católica de la Inmaculada Concepción, observada el 8 de diciembre.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/inmaculada_concepcion.jpg',
  },
  {
    'nombre': 'Santurantikuy',
    'mes': 12,
    'dia': 24,
    'descripcion': 'Feria tradicional cusqueña de arte popular y nacimientos, realizada en vísperas de Navidad.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/santurantikuy.jpg',
  },
  {
    'nombre': 'Takanakuy de Santo Tomás',
    'mes': 12,
    'dia': 25,
    'descripcion': 'Encuentro ritual y festivo de Chumbivilcas asociado a la Navidad; las fechas locales pueden variar.',
    'distrito': 'Santo Tomás',
    'ruta_imagen': 'assets/images/festividades/takanakuy.jpg',
  },
  {
    'nombre': 'Navidad',
    'mes': 12,
    'dia': 25,
    'descripcion': 'Celebración de Navidad en Cusco, con reuniones familiares, actos religiosos y tradiciones locales.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/navidad.jpg',
  },
  {
    'nombre': 'Año Nuevo',
    'mes': 1,
    'dia': 1,
    'descripcion': 'Inicio del año calendario, celebrado en Cusco con reuniones familiares y actividades públicas.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/año_nuevo.jpg',
  },
  {
    'nombre': 'Bajada de Reyes',
    'mes': 1,
    'dia': 6,
    'descripcion': 'Celebración de la Epifanía, que cierra el ciclo navideño el 6 de enero.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/bajada_de_reyes.jpg',
  },
  {
    'nombre': 'Festividad de San Sebastián',
    'mes': 1,
    'dia': 20,
    'descripcion': 'Fiesta patronal del distrito cusqueño de San Sebastián, celebrada tradicionalmente en enero.',
    'distrito': 'San Sebastián',
    'ruta_imagen': 'assets/images/festividades/festividad_de_san_sebastian.jpg',
  },
  {
    'nombre': 'Chiaraje',
    'mes': 1,
    'dia': 20,
    'descripcion': 'Encuentro ritual tradicional de la provincia de Canas; la fecha exacta debe confirmarse cada año.',
    'distrito': 'Canas',
    'ruta_imagen': 'assets/images/festividades/chiaraje.jpg',
  },
  {
    'nombre': 'Fiesta de San Blas',
    'mes': 2,
    'dia': 3,
    'descripcion': 'Festividad patronal del tradicional barrio cusqueño de San Blas, celebrada en febrero.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/templo_san_blas.jpg',
  },
];

const List<Map<String, Object?>> _platosIniciales = [
  {
    'nombre': 'Cuy chactado',
    'descripcion': 'Cuy sazonado y frito hasta quedar crocante, servido tradicionalmente con papas y ají.',
    'precio_ref': 45.0,
    'tipo': 'Plato tradicional',
    'ruta_imagen': 'assets/images/gastronomia/cuy_chactado.jpg',
  },
  {
    'nombre': 'Chiri uchu',
    'descripcion': 'Plato festivo frío que combina ingredientes andinos y productos de distintas regiones.',
    'precio_ref': 35.0,
    'tipo': 'Plato festivo',
    'ruta_imagen': 'assets/images/gastronomia/chiri_uchu.jpg',
  },
  {
    'nombre': 'Adobo cusqueño',
    'descripcion': 'Guiso de cerdo marinado en chicha y ajíes, servido caliente con pan para el desayuno.',
    'precio_ref': 28.0,
    'tipo': 'Guiso',
    'ruta_imagen': 'assets/images/gastronomia/adobo_cusqueno.jpg',
  },
  {
    'nombre': 'Chairo',
    'descripcion': 'Sopa andina preparada con carnes, verduras y chuño, habitual en la cocina cusqueña.',
    'precio_ref': 22.0,
    'tipo': 'Sopa',
    'ruta_imagen': 'assets/images/gastronomia/chairo.jpg',
  },
  {
    'nombre': 'Tamales cusqueños',
    'descripcion': 'Preparación de maíz molido envuelta en hojas y cocida al vapor, dulce o salada.',
    'precio_ref': 6.0,
    'tipo': 'Entrada',
    'ruta_imagen': 'assets/images/gastronomia/tamal_cusqueno.jpg',
  },
];
