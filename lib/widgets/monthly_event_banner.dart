import 'package:flutter/material.dart';

// Este widget crea un banner promocional para destacar un evento importante del mes.
// Sirve como bloque editorial que resalta una fiesta o celebración del Cusco.
class MonthlyEventBanner extends StatelessWidget {
  // Constructor constante.
  const MonthlyEventBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera el color principal para crear un fondo vibrante y coherente con el tema.
    final colorScheme = Theme.of(context).colorScheme;

    // El contenedor ocupa todo el ancho disponible y sirve como banner destacado.
    return Container(
      width: double.infinity,
      // Padding interno para separar el contenido del borde.
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
          // Icono para representar la festividad o el sol del evento.
          const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 28),
          // Espacio entre el icono y el texto principal.
          const SizedBox(height: 8),

          // Texto pequeño en mayúsculas que indica el tipo de contenido.
          Text(
            'EVENTO DEL MES',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          // Espacio entre la etiqueta y el nombre del evento.
          const SizedBox(height: 8),

          // Nombre principal del evento promocionado.
          Text(
            'Inti Raymi',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(color: Colors.white, fontSize: 28),
          ),
          // Espacio para separar el nombre del evento de la descripción.
          const SizedBox(height: 8),

          // Descripción breve del evento con fecha y contexto cultural.
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
