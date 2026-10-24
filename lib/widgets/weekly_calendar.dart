import 'package:flutter/material.dart';

import '../models/festividad.dart';
import 'section_heading.dart';

class WeeklyCalendar extends StatelessWidget {
  const WeeklyCalendar({
    required this.festivities,
    required this.today,
    super.key,
  });

  final List<Festividad> festivities;
  final DateTime today;

  static const _weekdayNames = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
  static const _monthNames = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  DateTime get _todayDate => DateTime(today.year, today.month, today.day);

  DateTime get _weekStart =>
      _todayDate.subtract(Duration(days: _todayDate.weekday - 1));

  String _rangeLabel(DateTime start, DateTime end) {
    if (start.year != end.year) {
      return 'Del ${start.day} de ${_monthNames[start.month - 1]} de ${start.year} '
          'al ${end.day} de ${_monthNames[end.month - 1]} de ${end.year}';
    }
    if (start.month != end.month) {
      return 'Del ${start.day} de ${_monthNames[start.month - 1]} '
          'al ${end.day} de ${_monthNames[end.month - 1]} de ${end.year}';
    }
    return 'Del ${start.day} al ${end.day} de ${_monthNames[end.month - 1]} de ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekStart = _weekStart;
    final weekEnd = weekStart.add(const Duration(days: 6));
    final days = List.generate(
      7,
      (index) => weekStart.add(Duration(days: index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeading(
          title: 'Agenda de la semana',
          subtitle: _rangeLabel(weekStart, weekEnd),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 520) {
              final cellWidth = ((constraints.maxWidth - 24) / 4).clamp(
                0.0,
                constraints.maxWidth,
              );
              return Wrap(
                key: const ValueKey('weekly-calendar-wrap'),
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var index = 0; index < days.length; index++)
                    SizedBox(
                      width: cellWidth,
                      child: _WeekdayCell(
                        day: days[index],
                        name: _weekdayNames[index],
                        isSelected: _sameDate(days[index], _todayDate),
                        hasEvent: _hasEvent(days[index]),
                        eventNames: _eventNames(days[index]),
                        key: ValueKey('weekday-$index'),
                      ),
                    ),
                ],
              );
            }

            return Row(
              key: const ValueKey('weekly-calendar-row'),
              children: [
                for (var index = 0; index < days.length; index++) ...[
                  if (index > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _WeekdayCell(
                      day: days[index],
                      name: _weekdayNames[index],
                      isSelected: _sameDate(days[index], _todayDate),
                      hasEvent: _hasEvent(days[index]),
                      eventNames: _eventNames(days[index]),
                      key: ValueKey('weekday-$index'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        if (_upcomingEvents().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Próximos eventos',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final occurrence in _upcomingEvents())
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${occurrence.event.nombre} · ${_formatDate(occurrence.date)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
        Text(
          'Los puntos indican festividades registradas.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  bool _hasEvent(DateTime date) => _eventNames(date).isNotEmpty;

  List<String> _eventNames(DateTime date) => festivities
      .where((event) => event.mes == date.month && event.dia == date.day)
      .map((event) => event.nombre)
      .toList();

  List<({Festividad event, DateTime date})> _upcomingEvents() {
    final today = _todayDate;
    final occurrences = <({Festividad event, DateTime date})>[];

    for (final event in festivities) {
      for (var year = today.year; year <= today.year + 2; year++) {
        final candidate = DateTime(year, event.mes, event.dia);
        if (candidate.month != event.mes || candidate.day != event.dia) {
          continue;
        }
        if (!candidate.isBefore(today)) {
          occurrences.add((event: event, date: candidate));
          break;
        }
      }
    }

    occurrences.sort((first, second) => first.date.compareTo(second.date));
    return occurrences.take(4).toList();
  }

  String _formatDate(DateTime date) =>
      '${date.day} de ${_monthNames[date.month - 1]}';

  bool _sameDate(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

class _WeekdayCell extends StatelessWidget {
  const _WeekdayCell({
    required this.day,
    required this.name,
    required this.isSelected,
    required this.hasEvent,
    required this.eventNames,
    super.key,
  });

  final DateTime day;
  final String name;
  final bool isSelected;
  final bool hasEvent;
  final List<String> eventNames;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isSelected ? colorScheme.onPrimary : colorScheme.onSurface;

    return Semantics(
      label: '$name ${day.day}'
          '${eventNames.isEmpty ? '' : ', ${eventNames.join(', ')}'}',
      child: Container(
        height: hasEvent ? 116 : 92,
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.day.toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: foreground,
              ),
            ),
            const SizedBox(height: 6),
            if (hasEvent)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    eventNames.take(2).join(', '),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}