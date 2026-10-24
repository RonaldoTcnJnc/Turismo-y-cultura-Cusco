import 'contenido.dart';

class Lugar extends Contenido {
  const Lugar({
    super.id,
    required super.nombre,
    required this.distrito,
    required super.descripcion,
    this.latitud,
    this.longitud,
    super.rutaImagen,
    required super.creadoEn,
  });

  final String distrito;
  final double? latitud;
  final double? longitud;

  @override
  TipoContenido get tipoContenido => TipoContenido.lugar;

  @override
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'distrito': distrito,
    'descripcion': descripcion,
    'latitud': latitud,
    'longitud': longitud,
    'ruta_imagen': rutaImagen,
    'creado_en': creadoEn.toIso8601String(),
  };

  factory Lugar.fromMap(Map<String, Object?> map) => Lugar(
    id: map['id'] as int?,
    nombre: map['nombre']! as String,
    distrito: map['distrito']! as String,
    descripcion: map['descripcion']! as String,
    latitud: (map['latitud'] as num?)?.toDouble(),
    longitud: (map['longitud'] as num?)?.toDouble(),
    rutaImagen: map['ruta_imagen'] as String?,
    creadoEn: fechaDesdeMap(map['creado_en']),
  );
}
