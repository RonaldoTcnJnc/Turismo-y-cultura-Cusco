import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/data/contenido_repository.dart';
import 'package:guia_turistica_cusco/models/contenido.dart';
import 'package:guia_turistica_cusco/models/lugar.dart';
import 'package:guia_turistica_cusco/screens/contenido_form_screen.dart';

void main() {
  Future<void> scrollToSave(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Guardar contenido'));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra error de nombre duplicado sin guardar', (tester) async {
    final repository = _FormRepository(nameExists: true);
    await tester.pumpWidget(_formHost(repository));
    await tester.tap(find.text('Abrir formulario'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Sacsayhuamán',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Descripción'),
      'Descripción suficientemente larga para pasar la validación del formulario.',
    );
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cusco').last);
    await tester.pumpAndSettle();
    await scrollToSave(tester);
    await tester.tap(find.text('Guardar contenido'));
    await tester.pumpAndSettle();

    expect(repository.duplicateCheckCount, 1);
    expect(find.text('Ya existe un contenido con ese nombre.'), findsOneWidget);
    expect(repository.insertCount, 0);
  });

  testWidgets('bloquea el guardado cuando falla validación local', (
    tester,
  ) async {
    final repository = _FormRepository();
    await tester.pumpWidget(_formHost(repository));
    await tester.tap(find.text('Abrir formulario'));
    await tester.pumpAndSettle();
    await scrollToSave(tester);
    await tester.tap(find.text('Guardar contenido'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ingrese un nombre de 4 a 80 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Seleccione el distrito.'), findsOneWidget);
    expect(repository.duplicateCheckCount, 0);
    expect(repository.insertCount, 0);
  });
}

Widget _formHost(_FormRepository repository) => MaterialApp(
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () {
          Navigator.push<Contenido>(
            context,
            MaterialPageRoute(
              builder: (_) => ContenidoFormScreen(
                categoria: TipoContenido.lugar,
                repository: repository,
              ),
            ),
          );
        },
        child: const Text('Abrir formulario'),
      ),
    ),
  ),
);

class _FormRepository extends ContenidoRepository {
  _FormRepository({this.nameExists = false});

  final bool nameExists;
  int insertCount = 0;
  int duplicateCheckCount = 0;

  @override
  Future<bool> existeNombre(
    TipoContenido tipo,
    String nombre, {
    int? excluirId,
  }) async {
    duplicateCheckCount++;
    return nameExists;
  }

  @override
  Future<int> insertar(Contenido contenido) async {
    insertCount++;
    return 1;
  }

  @override
  Future<Contenido?> obtenerPorId(TipoContenido tipo, int id) async => Lugar(
    id: id,
    nombre: 'Sacsayhuamán',
    distrito: 'Cusco',
    descripcion:
        'Descripción suficientemente larga para el test del formulario.',
    creadoEn: DateTime.utc(2026, 10, 23),
  );
}
