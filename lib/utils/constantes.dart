import 'package:flutter/material.dart';

abstract final class Rutas {
  static const String kInicio = '/';
  static const String kCategoria = '/categoria';
  static const String kContenido = '/contenido';
  static const String kDetalleContenido = '/contenido/detalle';
  static const String kMapa = '/mapa';
  static const String kFavoritos = '/favoritos';
}

abstract final class Categorias {
  static const String kLugares = 'lugares';
  static const String kFestividades = 'festividades';
  static const String kPlatos = 'platos';
}

abstract final class DatosFormulario {
  static const List<String> kDistritos = [
    'Cusco',
    'San Sebastián',
    'San Jerónimo',
    'Santiago',
    'Wanchaq',
    'Poroy',
    'Saylla',
    'Oropesa',
    'Pisac',
    'Ollantaytambo',
    'Machupicchu',
    'Ocongate',
  ];
}

abstract final class Dimensiones {
  static const double kMargenPantalla = 16;
  static const double kAnchoMaximoContenido = 1280;
  static const double kAlturaTarjeta = 232;
  static const double kAlturaPortada = 300;
}

abstract final class Colores {
  static const Color kPrimario = Color(0xFF126A62);
  static const Color kAcento = Color(0xFFB84F37);
  static const Color kFondo = Color(0xFFF7F5EF);
}

abstract final class Textos {
  static const String kNombreAplicacion = 'Cusco | Guía turística y cultural';
  static const String kErrorCarga = 'No se pudo cargar la información.';
  static const String kListaVacia = 'Todavía no hay contenidos para mostrar.';
  static const String kPermisoUbicacion =
      'La ubicación se usa para ordenar lugares cercanos y mostrar distancias.';
  static const String kPrivacidadImagen =
      'La foto elegida se copia al almacenamiento privado de la aplicación.';
}

abstract final class ClavesPreferencias {
  static const String kFavoritos = 'favoritos';
  static const String kUltimaSeccion = 'ultima_seccion';
  static const String kUltimoFiltro = 'ultimo_filtro';
}
