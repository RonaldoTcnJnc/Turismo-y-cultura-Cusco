import 'package:flutter/material.dart';

import 'data/contenido_repository.dart';
import 'models/contenido.dart';
import 'navigation/route_arguments.dart';
import 'screens/categoria_screen.dart';
import 'screens/contenido_detalle_screen.dart';
import 'screens/contenido_form_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/mapa_screen.dart';
import 'services/role_session.dart';
// Importa la pantalla principal de la guía turística.
import 'pages/cusco_guide_page.dart';
// Importa el tema visual personalizado de la aplicación.
import 'theme/app_theme.dart';
import 'utils/constantes.dart';

// Clase principal de la aplicación.
// Es un StatelessWidget porque la app no necesita cambiar de estado para mostrar la interfaz.
class CuscoGuideApp extends StatefulWidget {
  const CuscoGuideApp({this.roleSession, super.key});

  final RoleSession? roleSession;

  @override
  State<CuscoGuideApp> createState() => _CuscoGuideAppState();
}

class _CuscoGuideAppState extends State<CuscoGuideApp> {
  late final RoleSession _roleSession = widget.roleSession ?? RoleSession();
  late final bool _ownsRoleSession = widget.roleSession == null;

  @override
  void dispose() {
    if (_ownsRoleSession) _roleSession.dispose();
    super.dispose();
  }

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
      home: CuscoGuidePage(roleSession: _roleSession),
      onGenerateRoute: (settings) {
        final repository = ContenidoRepository();
        switch (settings.name) {
          case Rutas.kCategoria:
            final arguments = settings.arguments;
            if (arguments is CategoriaRouteArgs) {
              return MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => CategoriaScreen(
                  categoria: arguments.categoria,
                  roleSession: _roleSession,
                ),
              );
            }
            return _invalidRoute(settings.name);
          case Rutas.kContenido:
            final arguments = settings.arguments;
            if (arguments is ContenidoFormRouteArgs) {
              if (!_roleSession.canManageContent) {
                return _accessDeniedFormRoute();
              }
              return MaterialPageRoute<Contenido>(
                settings: settings,
                builder: (_) => ContenidoFormScreen(
                  categoria: arguments.categoria,
                  contenido: arguments.contenido,
                  repository: repository,
                  roleSession: _roleSession,
                ),
              );
            }
            return _invalidRoute(settings.name);
          case Rutas.kDetalleContenido:
            final arguments = settings.arguments;
            if (arguments is ContenidoDetalleRouteArgs) {
              return MaterialPageRoute<bool>(
                settings: settings,
                builder: (_) => ContenidoDetalleScreen(
                  contenido: arguments.contenido,
                  repository: repository,
                  roleSession: _roleSession,
                ),
              );
            }
            return _invalidRoute(settings.name);
          case Rutas.kFavoritos:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const FavoritosScreen(),
            );
          case Rutas.kMapa:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => MapaScreen(repository: repository),
            );
          default:
            return _invalidRoute(settings.name);
        }
      },
    );
  }
}

MaterialPageRoute<void> _invalidRoute(String? route) => MaterialPageRoute<void>(
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Ruta no disponible')),
    body: Center(
      child: Text('No se pudieron validar los argumentos de $route.'),
    ),
  ),
);

MaterialPageRoute<Contenido?> _accessDeniedFormRoute() =>
  MaterialPageRoute<Contenido?>(
  builder: (_) => Scaffold(
    appBar: AppBar(title: const Text('Acceso restringido')),
    body: const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Cambia al modo Colaborador desde Perfil para gestionar contenido.',
          textAlign: TextAlign.center,
        ),
      ),
    ),
  ),
);
