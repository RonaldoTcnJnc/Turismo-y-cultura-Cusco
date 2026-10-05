import 'package:flutter/material.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GuideHero(),
                    const SizedBox(height: 32),
                    const CategoryCarousel(),
                    const SizedBox(height: 32),
                    const MetricsOverview(),
                    const SizedBox(height: 32),
                    const WeeklyCalendar(),
                    const SizedBox(height: 32),
                    for (final section in guideSections) ...[
                      PlaceSection(section: section),
                      const SizedBox(height: 32),
                    ],
                    const MonthlyEventBanner(),
                    const SizedBox(height: 24),
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
