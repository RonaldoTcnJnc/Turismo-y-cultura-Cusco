import 'package:flutter/material.dart';

class MonthlyEventBanner extends StatelessWidget {
  const MonthlyEventBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [colorScheme.primary, const Color(0xFFB84F37)],
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(
            'EVENTO DEL MES',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Inti Raymi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: Colors.white, fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            '24 de junio · Una celebración al sol que llena la ciudad de historia.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
