import 'package:flutter/material.dart';

// Centraliza la apariencia visual de la app en un solo lugar.
// Esto hace que el diseño se mantenga consistente en todo el proyecto.
class AppTheme {
  // Define el tema claro de la aplicación.
  static final ThemeData light = ThemeData(
    // Genera un esquema de colores a partir de una semilla verde.
    colorScheme: ColorScheme.fromSeed(
      // Color base del tema, inspirado en tonos de Cusco y naturaleza andina.
      seedColor: const Color(0xFF126A62),
      brightness: Brightness.light,
    ),
    // Fondo general de la app para mantener una estética cálida y limpia.
    scaffoldBackgroundColor: const Color(0xFFF7F5EF),
    // Activa Material 3 para usar componentes modernos y actualizados.
    useMaterial3: true,
    // Define los estilos tipográficos principales de la interfaz.
    textTheme: const TextTheme(
      // Título grande y elegante para los textos más destacados.
      headlineMedium: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w700,
      ),
      // Título de sección para encabezados moderados.
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      // Título secundario para elementos de contenido breve.
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      // Texto corporal principal, con altura de línea apropiada para lectura.
      bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      // Texto auxiliar pequeño, usado en subtítulos y etiquetas secundarias.
      bodySmall: TextStyle(fontSize: 12, height: 1.35),
    ),
  );
}
