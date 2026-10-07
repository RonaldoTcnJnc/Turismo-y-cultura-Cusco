import 'package:flutter/material.dart';

// Importa el widget que se encarga de cargar imágenes locales desde assets.
import 'guide_image.dart';

// Este widget representa la portada principal de la guía turística del Cusco.
// Tiene una imagen de fondo, un filtro oscuro y un bloque de texto con buscador.
class GuideHero extends StatelessWidget {
  // Constructor constante del widget.
  const GuideHero({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de colores del tema para mantener coherencia en iconos y campos.
    final colorScheme = Theme.of(context).colorScheme;

    // ClipRRect recorta las esquinas del bloque para que tenga bordes redondeados.
    return ClipRRect(
      // El radio redondea los bordes para hacer la portada más elegante.
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        // La portada tiene una altura fija para crear impacto visual.
        height: 300,
        // Ocupa todo el ancho disponible del contenedor padre.
        width: double.infinity,
        child: Stack(
          // Stack permite superponer varios elementos: imagen, degradado y texto.
          fit: StackFit.expand,
          children: [
            // Muestra la imagen principal de la portada desde los assets.
            const GuideImage(
              imagePath: 'assets/images/portada/cusco_portada.jpg',
            ),
            // DecoratedBox añade una capa oscura encima de la imagen para mejorar la legibilidad del texto.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.12),
                    Colors.black.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
            // Padding genera espacio interno para separar el contenido del borde del hero.
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                // El contenido queda alineado a la izquierda.
                crossAxisAlignment: CrossAxisAlignment.start,
                // El texto y el buscador se ubican al fondo del bloque.
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Etiqueta pequeña y elegante para darle identidad a la portada.
                  Text(
                    'CUSCO, TRADICIÓN VIVA',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Separación entre la etiqueta y el título principal.
                  const SizedBox(height: 8),

                  // Título del hero con dos líneas para captar atención visualmente.
                  Text(
                    'Cusco, historia\ny sabor andino',
                    maxLines: 2,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(color: Colors.white, fontSize: 30),
                  ),
                  // Espacio para separar el título del campo de búsqueda.
                  const SizedBox(height: 20),

                  // El buscador visual ayuda a simular una interfaz real de app de turismo.
                  TextField(
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      // Icono de búsqueda en la izquierda del campo.
                      prefixIcon: Icon(
                        Icons.search,
                        color: colorScheme.primary,
                      ),
                      // Sugerencia visible dentro del campo.
                      hintText: 'Busca lugares, sabores y fiestas',
                      // Color del texto de sugerencia.
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      // Fondo blanco para que se diferencie del fondo oscuro.
                      filled: true,
                      fillColor: colorScheme.surface,
                      // Ajusta el padding vertical del campo de texto.
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      // Quita el borde visible para mantener un diseño más limpio.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
