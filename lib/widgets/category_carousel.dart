import 'package:flutter/material.dart';

// Importa las categorías desde la base de datos local del contenido.
import '../data/guide_data.dart';
// Importa el widget reutilizable que carga imágenes desde assets.
import 'guide_image.dart';
// Importa el encabezado estándar para cada bloque de contenido.
import 'section_heading.dart';

// Este widget representa el carrusel horizontal de categorías del Cusco.
// Muestra una serie de tarjetas, cada una con una imagen, un icono y el nombre de la categoría.
class CategoryCarousel extends StatelessWidget {
  // Constructor constante del widget.
  const CategoryCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    // Recupera el esquema de colores del tema actual para mantener la identidad visual.
    final colorScheme = Theme.of(context).colorScheme;

    // La estructura principal es una columna: título + carrusel.
    return Column(
      // Alinea el contenido hacia la izquierda para que el bloque quede bien anclado.
      crossAxisAlignment: CrossAxisAlignment.start,
      // Los hijos de la columna son el encabezado y la lista horizontal.
      children: [
        // Encabezado visual de la sección: “Explora por categoría”.
        const SectionHeading(
          title: 'Explora por categoría',
          subtitle: 'Una ciudad, muchas formas de vivirla',
        ),
        // Espacio entre el encabezado y el carrusel.
        const SizedBox(height: 16),

        // Contenedor con altura fija para el carrusel horizontal.
        SizedBox(
          height: 128,
          // ListView.separated permite mostrar elementos en una fila horizontal.
          child: ListView.separated(
            // La dirección horizontal hace que las tarjetas se desplacen de lado a lado.
            scrollDirection: Axis.horizontal,
            // La cantidad de imágenes/categorías viene de la lista fija del archivo de datos.
            itemCount: guideCategories.length,
            // Añade separación entre cada tarjeta del carrusel.
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            // Crea cada tarjeta con sus datos reales.
            itemBuilder: (context, index) {
              // Obtiene la categoría actual para dibujar su tarjeta.
              final category = guideCategories[index];
              // Cada elemento tiene un ancho fijo para mantener una proporción uniforme.
              return SizedBox(
                width: 160,
                child: Card(
                  // Recorta la imagen para que se adapte con bordes redondeados suaves.
                  clipBehavior: Clip.antiAlias,
                  // Quita márgenes externos para que el espacio lo controle el padre.
                  margin: EdgeInsets.zero,
                  // Stack permite superponer imagen, degradado y texto en la misma tarjeta.
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Carga la imagen local asociada a la categoría.
                      GuideImage(imagePath: category.imagePath),
                      DecoratedBox(
                        // Agrega un degradado oscuro para mejorar la legibilidad del texto sobre la imagen.
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              colorScheme.scrim.withValues(alpha: 0.78),
                            ],
                          ),
                        ),
                      ),
                      // Alinea el contenido textual en la parte inferior izquierda.
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          // Añade espacio interno para que el texto y el icono no se peguen al borde.
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Icono representativo de la categoría.
                              Icon(
                                category.icon,
                                color: Colors.white,
                                size: 18,
                              ),
                              // Espacio entre el icono y el nombre.
                              const SizedBox(width: 8),

                              // El nombre se muestra dentro de un Expanded para no desbordar la tarjeta.
                              Expanded(
                                child: Text(
                                  category.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
