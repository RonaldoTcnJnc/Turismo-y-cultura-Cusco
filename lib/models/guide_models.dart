import 'package:flutter/material.dart';

// Define la estructura de una categoría de la guía turística.
// Por ejemplo: Lugares, Festividades, Gastronomía o Tradiciones.
class GuideCategory {
  // Constructor del modelo con nombre, icono e imagen de la categoría.
  const GuideCategory(this.name, this.icon, this.imagePath);

  // Nombre visible que se muestra para la categoría.
  final String name;
  // Icono que representa la categoría en la interfaz.
  final IconData icon;
  // Ruta de la imagen local que se usa como fondo del carrusel.
  final String imagePath;
}

// Define cada elemento individual que aparece dentro de una sección de contenido.
// Por ejemplo: Machu Picchu, Inti Raymi o Chiri uchu.
class GuidePlace {
  // Constructor con los campos necesarios para una tarjeta de lugar o evento.
  const GuidePlace({
    required this.name,
    required this.category,
    required this.imagePath,
    required this.tags,
  });

  // Nombre principal del lugar o evento.
  final String name;
  // Etiqueta secundaria para identificar la categoría o tipo de contenido.
  final String category;
  // Ruta local de la imagen que acompaña al contenido.
  final String imagePath;
  // Lista de palabras clave visuales para describir rápidamente el contenido.
  final List<String> tags;
}

// Define cada bloque temático de la aplicación.
// Cada sección agrupa varios GuidePlace bajo un mismo título y subtítulo.
class GuideSection {
  // Constructor para crear una sección con su título y contenido relacionado.
  const GuideSection({
    required this.title,
    required this.subtitle,
    required this.places,
  });

  // Título visible de la sección, por ejemplo: “Lugares”.
  final String title;
  // Texto breve de contexto para describir la sección.
  final String subtitle;
  // Colección de lugares o eventos que se muestran dentro de la sección.
  final List<GuidePlace> places;
}
