import 'package:flutter/material.dart';

// Importa la pantalla principal de la guía turística.
import 'pages/cusco_guide_page.dart';
// Importa el tema visual personalizado de la aplicación.
import 'theme/app_theme.dart';

// Clase principal de la aplicación.
// Es un StatelessWidget porque la app no necesita cambiar de estado para mostrar la interfaz.
class CuscoGuideApp extends StatelessWidget {
  // Constructor constante para crear la instancia de la app.
  const CuscoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp es el punto de partida de una app con diseño Material.
    return MaterialApp(
      // Título que se usa como nombre de la aplicación.
      title: 'Cusco | Guía turística y cultural',
      // Oculta la etiqueta de debug en la esquina superior derecha.
      debugShowCheckedModeBanner: false,
      // Usa el tema visual centralizado definido en app_theme.dart.
      theme: AppTheme.light,
      // La pantalla inicial que se mostrará cuando la app arranque.
      home: const CuscoGuidePage(),
    );
  }
}
