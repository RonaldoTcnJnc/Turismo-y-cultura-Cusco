import 'contenido.dart';

class Festividad extends Contenido {
  const Festividad({
    super.id,
    required super.nombre,
    required this.mes,
    required this.dia,
    required super.descripcion,
    this.distrito,
    super.rutaImagen,
    required super.creadoEn,
  });

  final int mes;
  final int dia;
  final String? distrito;

  @override
  TipoContenido get tipoContenido => TipoContenido.festividad;

  @override
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'mes': mes,
    'dia': dia,
    'descripcion': descripcion,
    'distrito': distrito,
    'ruta_imagen': rutaImagen,
    'creado_en': creadoEn.toIso8601String(),
  };

  factory Festividad.fromMap(Map<String, Object?> map) => Festividad(
    id: map['id'] as int?,
    nombre: map['nombre']! as String,
    mes: map['mes']! as int,
    dia: map['dia']! as int,
    descripcion: map['descripcion']! as String,
    distrito: map['distrito'] as String?,
    rutaImagen: map['ruta_imagen'] as String?,
    creadoEn: fechaDesdeMap(map['creado_en']),
  );
}
