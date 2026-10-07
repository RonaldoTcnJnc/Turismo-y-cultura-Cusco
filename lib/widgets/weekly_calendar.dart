import 'package:flutter/material.dart';

import 'section_heading.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado del calendario con el rango de fechas visible.
        const SectionHeading(
          title: 'Agenda de la semana',
          subtitle: 'Del 5 al 11 de octubre',
        ),
        const SizedBox(height: 16),

        // El calendario cambia de distribución según el ancho disponible.
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              // En móviles muy estrechos puede quedar un ancho negativo si se
              // intenta repartir más espacio del disponible. Clampear evita que
              // el render falle en pantallas pequeñas o en pruebas de layout.
              final cellWidth = ((constraints.maxWidth - 24) / 4).clamp(
                0.0,
                constraints.maxWidth,
              );
              return Wrap(
                key: const ValueKey('weekly-calendar-wrap'),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < _weekDays.length; index++)
                    SizedBox(
                      width: cellWidth,
                      child: _WeekdayCell(
                        day: _weekDays[index],
                        key: ValueKey('weekday-$index'),
                      ),
                    ),
                ],
              );
            }

            // Desde 520 dp disponibles se presentan los siete días en una fila.
            return Row(
              key: const ValueKey('weekly-calendar-row'),
              children: [
                for (var index = 0; index < _weekDays.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _WeekdayCell(
                      day: _weekDays[index],
                      key: ValueKey('weekday-$index'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _WeekdayCell extends StatelessWidget {
  const _WeekdayCell({required this.day, super.key});

  final _Weekday day;

  @override
  Widget build(BuildContext context) {
    // El color del texto cambia si el día está seleccionado o no.
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = day.isSelected
        ? colorScheme.onPrimary
        : colorScheme.onSurface;

    return Semantics(
      // Descripción accesible para cada día, incluyendo si tiene actividad cultural.
      label: '${day.name} ${day.date}${day.hasEvent ? ', actividad cultural' : ''}',
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: day.isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nombre corto del día: Lun, Mar, Mié, etc.
            Text(
              day.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Número del día para la agenda.
            Text(
              day.date,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
              ),
            ),
            const SizedBox(height: 8),

            // Indicador visual de que existe un evento cultural o actividad.
            SizedBox(
              width: 8,
              height: 8,
              child: day.hasEvent
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        color: day.isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Weekday {
  // Modelo interno para representar los días del calendario.
  const _Weekday(this.name, this.date, {this.isSelected = false, this.hasEvent = false});

  final String name;
  final String date;
  final bool isSelected;
  final bool hasEvent;
}

const _weekDays = [
  _Weekday('Lun', '05', isSelected: true, hasEvent: true),
  _Weekday('Mar', '06'),
  _Weekday('Mié', '07', hasEvent: true),
  _Weekday('Jue', '08'),
  _Weekday('Vie', '09', hasEvent: true),
  _Weekday('Sáb', '10', hasEvent: true),
  _Weekday('Dom', '11'),
];
