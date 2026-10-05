import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:guia_turistica_cusco/main.dart';

void main() {
  testWidgets('muestra la guía y adapta las columnas sin overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CuscoGuideApp());
    await tester.pump();

    expect(find.text('Explora por categoría'), findsOneWidget);
    expect(find.text('Lugares'), findsWidgets);
    expect(find.text('Festividades'), findsWidgets);
    expect(find.text('Gastronomía'), findsWidgets);
    expect(find.text('EVENTO DEL MES'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);
    expect(find.text('Agenda de la semana'), findsOneWidget);
    expect(find.text('Cusco en cifras'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration?.prefixIcon,
      isNotNull,
    );
    expect(
      tester.widget<ListView>(find.byType(ListView)).scrollDirection,
      Axis.horizontal,
    );

    final navigationBar = tester.widget<BottomNavigationBar>(
      find.byType(BottomNavigationBar),
    );
    expect(navigationBar.items, hasLength(4));
    expect(navigationBar.onTap, isNull);

    const layouts = [
      (width: 320.0, columns: 2),
      (width: 800.0, columns: 3),
      (width: 1200.0, columns: 4),
    ];
    for (final layout in layouts) {
      tester.view.physicalSize = Size(layout.width, 900);
      await tester.pump();

      for (final section in ['lugares', 'festividades', 'gastronomía']) {
        final grid = tester.widget<GridView>(
          find.byKey(ValueKey('$section-grid')),
        );
        final gridDelegate =
            grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
        expect(gridDelegate.crossAxisCount, layout.columns);
        expect(gridDelegate.mainAxisExtent, 232);
      }

      final metricsGrid = tester.widget<GridView>(
        find.byKey(const ValueKey('metrics-grid')),
      );
      final metricsDelegate = metricsGrid.gridDelegate
          as SliverGridDelegateWithFixedCrossAxisCount;
      expect(metricsDelegate.crossAxisCount, layout.width < 520 ? 2 : 4);

      expect(
        find.byKey(
          ValueKey(
            layout.width < 520
                ? 'weekly-calendar-wrap'
                : 'weekly-calendar-row',
          ),
        ),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('weekday-6')), findsOneWidget);
      final firstWeekday = tester.getTopLeft(
        find.byKey(const ValueKey('weekday-0')),
      );
      final fifthWeekday = tester.getTopLeft(
        find.byKey(const ValueKey('weekday-4')),
      );
      if (layout.width < 520) {
        expect(fifthWeekday.dy, greaterThan(firstWeekday.dy));
      } else {
        expect(fifthWeekday.dy, firstWeekday.dy);
      }
      expect(
        tester.takeException(),
        isNull,
        reason: 'Ancho evaluado: ${layout.width}px',
      );
    }
  });
}
