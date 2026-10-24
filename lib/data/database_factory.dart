import 'package:sqflite_common/sqlite_api.dart';

import 'database_factory_stub.dart'
    if (dart.library.io) 'database_factory_io.dart'
    if (dart.library.js_interop) 'database_factory_web.dart'
    as platform;

Future<DatabaseFactory> createDatabaseFactory() =>
    platform.createDatabaseFactory();
