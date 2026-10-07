import 'package:flutter/material.dart';

// Este archivo define un widget reutilizable llamado SectionHeading.
// Sirve para crear el encabezado visual de cada bloque de contenido,
// como “Lugares”, “Festividades” y “Gastronomía”.
// Mantiene la misma estructura en toda la app para que el diseño se vea uniforme.
class SectionHeading extends StatelessWidget {
  // El constructor recibe los datos que necesita el widget para mostrarse.
  // Se usa const para permitir crear instancias constantes y optimizar el rendimiento.
  const SectionHeading({
    // El título principal es obligatorio, porque cada sección necesita un nombre claro.
    required this.title,
    // El subtítulo también es obligatorio, porque da contexto al usuario.
    required this.subtitle,
    // trailing es un widget opcional que puede ir a la derecha, por ejemplo: “VER TODO”.
    this.trailing,
    // super.key identifica este widget dentro del árbol de widgets de Flutter.
    super.key,
  });

  // Esta variable guarda el texto principal del encabezado.
  final String title;
  // Esta variable guarda la descripción corta de la sección.
  final String subtitle;
  // Este valor opcional permite agregar un botón, enlace o texto extra a la derecha.
  final Widget? trailing;

  // El método build es el corazón del widget.
  // Aquí se define exactamente cómo se dibuja en la pantalla.
  @override
  Widget build(BuildContext context) {
    // Row crea una fila horizontal para ubicar el texto y la acción opcional.
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.end alinea los elementos hacia abajo,
      // para que el texto principal y el contenido de la derecha queden nivelados visualmente.
      crossAxisAlignment: CrossAxisAlignment.end,
      // children es la lista de widgets que van dentro de la fila.
      children: [
        // Expanded hace que el bloque de texto ocupe el espacio disponible restante.
        // Esto es importante porque el widget de la derecha no siempre está presente.
        Expanded(
          // Column organiza el título y el subtítulo en vertical.
          child: Column(
            // Alinea el contenido hacia la izquierda para mantener una estructura editorial.
            crossAxisAlignment: CrossAxisAlignment.start,
            // Los elementos dentro de la columna son: título y subtítulo.
            children: [
              // Text muestra el título principal de la sección.
              // Se usa el estilo titleLarge del tema, que es más grande y destacado.
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              // SizedBox crea un espacio vertical exacto entre el título y el subtítulo.
              const SizedBox(height: 8),
              // Text muestra el subtítulo, que es más pequeño y menos dominante.
              Text(
                // El texto del subtítulo llega desde la propiedad subtitle.
                subtitle,
                // bodySmall es un estilo más discreto y ayuda a diferenciar la descripción del título.
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  // onSurfaceVariant ofrece un color tenue y legible para textos secundarios.
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Si el widget trailing existe, entonces se agrega un espacio horizontal
        // y se muestra a la derecha del texto principal.
        if (trailing != null) ...[const SizedBox(width: 8), trailing!],
      ],
    );
  }
}
