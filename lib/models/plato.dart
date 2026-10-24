import 'contenido.dart';

class Plato extends Contenido {
  const Plato({
    super.id,
    required super.nombre,
    required super.descripcion,
    this.precioRef,
    required this.tipo,
    super.rutaImagen,
    required super.creadoEn,
  });

  final double? precioRef;
  final String tipo;

  @override
  TipoContenido get tipoContenido => TipoContenido.plato;

  @override
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'nombre': nombre,
    'descripcion': descripcion,
    'precio_ref': precioRef,
    'tipo': tipo,
    'ruta_imagen': rutaImagen,
    'creado_en': creadoEn.toIso8601String(),
  };

  factory Plato.fromMap(Map<String, Object?> map) => Plato(
    id: map['id'] as int?,
    nombre: map['nombre']! as String,
    descripcion: map['descripcion']! as String,
    precioRef: (map['precio_ref'] as num?)?.toDouble(),
    tipo: map['tipo']! as String,
    rutaImagen: map['ruta_imagen'] as String?,
    creadoEn: fechaDesdeMap(map['creado_en']),
  );
}
