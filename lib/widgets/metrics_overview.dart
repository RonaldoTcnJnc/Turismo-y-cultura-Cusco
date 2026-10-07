import 'package:flutter/material.dart';

class MetricsOverview extends StatelessWidget {
  const MetricsOverview({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera los colores del tema para mantener la consistencia visual del bloque.
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección con métricas del destino.
        const Text(
          'Cusco en cifras',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        // Ajusta la cantidad de columnas según el ancho disponible.
        LayoutBuilder(
          builder: (context, constraints) {
            // Menos de 520 dp disponibles: 2 columnas. Desde 520 dp: 4.
            final columns = constraints.maxWidth < 520 ? 2 : 4;

            return GridView.builder(
              key: const ValueKey('metrics-grid'),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _guideMetrics.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisExtent: 104,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                final metric = _guideMetrics[index];
                return Semantics(
                  // Lee la información de la métrica con accesibilidad.
                  label: '${metric.value} ${metric.label}',
                  child: Card(
                    margin: EdgeInsets.zero,
                    color: colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Icono de la métrica.
                          Icon(metric.icon, color: colorScheme.primary),
                          const SizedBox(width: 8),

                          // Columna con el valor y la etiqueta.
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metric.value,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(color: colorScheme.primary),
                                ),
                                Text(
                                  metric.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _GuideMetric {
  // Modelo auxiliar para guardar el valor, etiqueta e icono de cada métricas.
  const _GuideMetric(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

const _guideMetrics = [
  _GuideMetric('04', 'Lugares', Icons.place_outlined),
  _GuideMetric('04', 'Festividades', Icons.celebration_outlined),
  _GuideMetric('04', 'Sabores', Icons.restaurant_outlined),
  _GuideMetric('07', 'Días culturales', Icons.calendar_month_outlined),
];
