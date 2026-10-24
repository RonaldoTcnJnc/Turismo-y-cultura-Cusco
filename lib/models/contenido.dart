import 'festividad.dart';
import 'lugar.dart';
import 'plato.dart';

enum TipoContenido { lugar, festividad, plato }

extension TipoContenidoInfo on TipoContenido {
  String get clave => switch (this) {
    TipoContenido.lugar => 'lugar',
    TipoContenido.festividad => 'festividad',
    TipoContenido.plato => 'plato',
  };

  String get tabla => switch (this) {
    TipoContenido.lugar => 'lugares',
    TipoContenido.festividad => 'festividades',
    TipoContenido.plato => 'platos',
  };

  static TipoContenido parse(String valor) => switch (valor) {
    'lugar' || 'lugares' => TipoContenido.lugar,
    'festividad' || 'festividades' => TipoContenido.festividad,
    'plato' || 'platos' => TipoContenido.plato,
    _ => throw ArgumentError.value(valor, 'valor', 'Categoría desconocida'),
  };
}

abstract class Contenido {
  const Contenido({
    this.id,
    required this.nombre,
    required this.descripcion,
    this.rutaImagen,
    required this.creadoEn,
  });

  final int? id;
  final String nombre;
  final String descripcion;
  final String? rutaImagen;
  final DateTime creadoEn;

  TipoContenido get tipoContenido;

  Map<String, Object?> toMap();

  static Contenido fromMap(TipoContenido tipo, Map<String, Object?> map) =>
      switch (tipo) {
        TipoContenido.lugar => Lugar.fromMap(map),
        TipoContenido.festividad => Festividad.fromMap(map),
        TipoContenido.plato => Plato.fromMap(map),
      };
}

DateTime fechaDesdeMap(Object? valor) => DateTime.parse(valor! as String);
