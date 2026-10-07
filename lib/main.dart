import 'package:flutter/material.dart';

// Importa la aplicación principal desde el archivo app.dart.
// Esto permite separar la lógica de arranque del contenido visual de la app.
import 'app.dart';

// Exporta la clase principal para facilitar el acceso desde otros archivos o pruebas.
export 'app.dart';

// Punto de entrada de la aplicación Flutter.
// runApp inicializa la aplicación y carga la interfaz principal de la guía del Cusco.
void main() => runApp(const CuscoGuideApp());
