import 'package:flutter/material.dart';

// Importa el contenido estático de la guía y los widgets reutilizables.
import '../data/guide_data.dart';
import '../widgets/category_carousel.dart';
import '../widgets/guide_hero.dart';
import '../widgets/metrics_overview.dart';
import '../widgets/monthly_event_banner.dart';
import '../widgets/place_section.dart';
import '../widgets/weekly_calendar.dart';

class CuscoGuidePage extends StatelessWidget {
  const CuscoGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene los colores del tema para mantener coherencia visual.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // El cuerpo principal permite desplazar todo el contenido si la pantalla es pequeña.
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              // Limita el ancho máximo para que la interface se vea ordenada en pantallas grandes.
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                // Espaciado general alrededor del contenido principal.
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada visual con imagen, título y buscador.
                    const GuideHero(),
                    const SizedBox(height: 32),

                    // Carrusel horizontal de categorías turísticas.
                    const CategoryCarousel(),
                    const SizedBox(height: 32),

                    // Tarjetas con indicadores generales del destino.
                    const MetricsOverview(),
                    const SizedBox(height: 32),

                    // Agenda semanal con días y eventos culturales.
                    const WeeklyCalendar(),
                    const SizedBox(height: 32),

                    // Secciones repetitivas de lugares, festividades y gastronomía.
                    for (final section in guideSections) ...[
                      PlaceSection(section: section),
                      const SizedBox(height: 32),
                    ],

                    // Banner promocional del evento principal del mes.
                    const MonthlyEventBanner(),
                    const SizedBox(height: 24),

                    // Frase final para cerrar visualmente la pantalla.
                    Text(
                      'Cusco se descubre paso a paso.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),

      // Navegación inferior con opciones de una guía de turismo.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: null,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Guardados',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            label: 'Agenda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
