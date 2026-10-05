# Informe breve: Guía turística y cultural del Cusco

**Curso:** Desarrollo de Software II · UNSAAC · IF616AIN  
**Proyecto:** 5 · Sesión 6

## Jerarquía visual

La cabecera fotográfica introduce el destino con un título y un buscador. El carrusel facilita el reconocimiento rápido de categorías; luego, los encabezados repetibles organizan las rejillas de Lugares, Festividades y Gastronomía. Las fotografías con degradado mantienen legibles las etiquetas, nombres y subetiquetas. El bloque «Evento del mes» cierra el recorrido con un acento visual propio y la navegación inferior mantiene visibles las cuatro secciones estáticas.

## Espaciado y color

El espaciado sigue una base de 8 dp: separación de 8/16 dp dentro de componentes y 24/32 dp entre bloques. Los márgenes laterales son de 16 dp en móvil y el contenido se limita a 1280 dp en pantallas amplias. La paleta parte del verde andino generado por `ColorScheme.fromSeed`, sobre un fondo claro; el terracota aparece como acento del evento. Título, subtítulo y cuerpo usan tres escalas tipográficas diferenciadas. Cada tarjeta de rejilla conserva una altura fija de 232 dp.

## Adaptación y dificultad

Las rejillas de Lugares, Festividades y Gastronomía usan 2 columnas bajo 520 dp, 3 entre 520 y 959 dp y 4 desde 960 dp. Las métricas se presentan en 2 columnas bajo 520 dp y 4 desde 520 dp. El calendario muestra 7 celdas en una fila desde 520 dp y, en pantallas menores, un `Wrap` de dos filas (4 + 3 días). El carrusel conserva desplazamiento horizontal en todos los anchos. En la prueba de 320 px, el título inicial del hero ocupaba una línea adicional y desbordaba su columna; se reescribió en dos líneas cortas. Las fotos reales se empaquetan como assets locales; sus autores y licencias se enumeran en `assets/images/ATRIBUTOS.md`.

## Organización del equipo

Para cuatro personas: diseño visual, construcción de widgets, verificación responsive y documentación/entrega, un rol por integrante. Para tres, diseño y documentación pueden ser responsabilidad compartida. La comprobación final incluye `flutter analyze`, `flutter test` y capturas móvil y escritorio.
