import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory.dart';

class DatabaseHelper {
  DatabaseHelper._({this.factoryOverride, this.pathOverride});

  static final DatabaseHelper instance = DatabaseHelper._();
  static const int databaseVersion = 1;
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
    // Ejemplo listo para activar al subir databaseVersion a 2 y añadir `fuente`
    // también al CREATE TABLE de onCreate. Los datos existentes se conservan.
    if (oldVersion < 2 && newVersion >= 2) {
      await db.execute('ALTER TABLE lugares ADD COLUMN fuente TEXT');
    }
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
      for (final plato in _platosIniciales) {
        await transaction.insert('platos', {...plato, 'creado_en': creadoEn});
      }
    });
  }
}

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
    'ruta_imagen': 'assets/images/lugares/plaza_de_armas.jpg',
  },
  {
    'nombre': 'Plaza de Armas del Cusco',
    'distrito': 'Cusco',
    'descripcion': 'Centro histórico de la ciudad, rodeado de templos, portales y espacios de encuentro.',
    'latitud': -13.5164,
    'longitud': -71.9785,
    'ruta_imagen': 'assets/images/lugares/plaza_de_armas.jpg',
  },
  {
    'nombre': "Q'enqo",
    'distrito': 'Cusco',
    'descripcion': 'Sitio ceremonial inca con formaciones de roca tallada y espacios rituales al aire libre.',
    'latitud': -13.5084,
    'longitud': -71.9619,
    'ruta_imagen': 'assets/images/lugares/sacsayhuaman.jpg',
  },
  {
    'nombre': 'Mercado San Pedro',
    'distrito': 'Cusco',
    'descripcion': 'Mercado tradicional cercano al centro donde se encuentran productos, comidas y artesanía local.',
    'latitud': -13.5202,
    'longitud': -71.9833,
    'ruta_imagen': 'assets/images/gastronomia/quesos_cusquenos.jpg',
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
    'ruta_imagen': 'assets/images/festividades/virgen_del_carmen.jpg',
  },
  {
    'nombre': 'Señor de los Temblores',
    'mes': 3,
    'dia': 30,
    'descripcion': 'Patrón jurado del Cusco, venerado durante Semana Santa; la fecha cambia cada año y es referencial.',
    'distrito': 'Cusco',
    'ruta_imagen': 'assets/images/festividades/corpus_christi.jpg',
  },
];

const List<Map<String, Object?>> _platosIniciales = [
  {
    'nombre': 'Cuy chactado',
    'descripcion': 'Cuy sazonado y frito hasta quedar crocante, servido tradicionalmente con papas y ají.',
    'precio_ref': 45.0,
    'tipo': 'Plato tradicional',
    'ruta_imagen': 'assets/images/gastronomia/chiri_uchu.jpg',
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
    'ruta_imagen': 'assets/images/gastronomia/costillar_frutillada.jpg',
  },
  {
    'nombre': 'Chairo',
    'descripcion': 'Sopa andina preparada con carnes, verduras y chuño, habitual en la cocina cusqueña.',
    'precio_ref': 22.0,
    'tipo': 'Sopa',
    'ruta_imagen': 'assets/images/gastronomia/anticuchos_cusquenos.jpg',
  },
  {
    'nombre': 'Tamales cusqueños',
    'descripcion': 'Preparación de maíz molido envuelta en hojas y cocida al vapor, dulce o salada.',
    'precio_ref': 6.0,
    'tipo': 'Entrada',
    'ruta_imagen': 'assets/images/gastronomia/quesos_cusquenos.jpg',
  },
];
