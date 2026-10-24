import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/app.dart';
import 'package:guia_turistica_cusco/models/contenido.dart';
import 'package:guia_turistica_cusco/models/lugar.dart';
import 'package:guia_turistica_cusco/navigation/route_arguments.dart';
import 'package:guia_turistica_cusco/utils/constantes.dart';

void main() {
  testWidgets('rechaza argumentos de ruta con tipo incorrecto', (tester) async {
    await tester.pumpWidget(const CuscoGuideApp());
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(Rutas.kCategoria, arguments: 42);
    await tester.pumpAndSettle();

    expect(find.text('Ruta no disponible'), findsOneWidget);
    expect(
      find.textContaining('No se pudieron validar los argumentos'),
      findsOneWidget,
    );
  });

  test('argumentos tipados conservan la categoría y el modelo', () {
    const category = CategoriaRouteArgs(TipoContenido.lugar);
    expect(category.categoria, TipoContenido.lugar);

    final content = Lugar(
      id: 4,
      nombre: 'Qorikancha',
      distrito: 'Cusco',
      descripcion: 'Templo inca de prueba.',
      creadoEn: DateTime.utc(2026, 10, 23),
    );
    final form = ContenidoFormRouteArgs(
      categoria: TipoContenido.lugar,
      contenido: content,
    );
    expect(form.contenido, same(content));
    expect(ContenidoDetalleRouteArgs(content).contenido.id, 4);
  });
}
