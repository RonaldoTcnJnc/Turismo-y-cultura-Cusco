# INFORME TÉCNICO DE DESARROLLO DE LA INTERFAZ DE USUARIO (UI/UX)

**Asignatura:** Desarrollo de Software II (IF616BIN)  
**Unidad:** I - Fundamentos de Dart, UI declarativa y UX  
**Proyecto:** Guía Turística de Cusco  
**Integrantes:** [Apellidos, Nombres]  
**Fecha de entrega:** 05 de octubre de 2026  
**URL GitHub:** [https://github.com/user/proyecto]

---

## 1. Introducción y Objetivos

### 1.1. Descripción del proyecto
La aplicación consiste en una guía turística de Cusco para presentar información visual y organizada sobre lugares representativos, festividades, gastronomía, eventos del mes y datos generales del destino. La interfaz tiene como propósito ofrecer una navegación rápida, una lectura clara y una experiencia visual relacionada con la identidad cultural andina.

El contenido se presenta mediante elementos estáticos, sin conexión a una base de datos ni lógica de negocio. La aplicación busca comunicar la información con una composición moderna, contrastes adecuados y una estructura repetible para cada bloque temático.

### 1.2. Objetivo de la interfaz
El objetivo principal es facilitar la exploración del destino mediante una secuencia visual coherente. Se busca que el usuario pueda:

- identificar las categorías disponibles;
- reconocer los contenidos más relevantes en la primera pantalla;
- comprender la información mediante textos breves y elementos visuales;
- navegar sin perder la orientación en el contenido;
- consultar la aplicación en dispositivos con diferentes tamaños de pantalla.

La interfaz también debe transmitir una identidad visual propia mediante una paleta dominada por tonos verdes y una tipografía con una presencia editorial.

### 1.3. Alcance de la sesión
La entrega corresponde exclusivamente a una interfaz de usuario estática. No se implementaron servicios, persistencia de datos, autenticación, gestión de estado, filtros dinámicos ni navegación entre pantallas.

Los widgets principales se desarrollaron con `StatelessWidget`, mientras que la información visual se mantiene separada en archivos de datos y estilos. Esta decisión permite centrarse en los conceptos de composición, restricciones, responsividad y diseño visual de la unidad.

---

## 2. Arquitectura de Widgets y Estructura del Código

### 2.1. Organización del proyecto
La organización modular del proyecto permite separar las responsabilidades del contenido, la presentación y la apariencia visual.

```text
lib/
├── app.dart
├── main.dart
├── data/
│   └── guide_data.dart
├── models/
│   └── guide_models.dart
├── pages/
│   └── cusco_guide_page.dart
├── theme/
│   └── app_theme.dart
├── widgets/
│   ├── category_carousel.dart
│   ├── guide_hero.dart
│   ├── guide_image.dart
│   ├── metrics_overview.dart
│   ├── monthly_event_banner.dart
│   ├── place_card.dart
│   ├── place_section.dart
│   ├── section_heading.dart
│   └── weekly_calendar.dart
└── ...

test/
└── widget_test.dart
```

**Justificación de la organización:**

- `data/` contiene la información estática de categorías, lugares y métricas.
- `models/` define los modelos utilizados para representar las secciones del contenido.
- `theme/` centraliza el tema visual y la tipografía de la aplicación.
- `widgets/` agrupa componentes reutilizables para evitar duplicación de código.
- `pages/` concentra la composición de la pantalla principal.
- `test/` verifica la responsabilidad visual y el comportamiento responsive.

Esta distribución aplica el principio DRY y facilita la modificación, la prueba y el mantenimiento de cada parte de la interfaz.

### 2.2. Árbol de widgets principal
La pantalla principal se compone de una estructura vertical organizada dentro de `Scaffold`, `SafeArea` y `SingleChildScrollView`.

```text
Scaffold
├── SafeArea
│   └── SingleChildScrollView
│       └── Center
│           └── ConstrainedBox
│               └── Padding
│                   └── Column
│                       ├── GuideHero
│                       ├── SizedBox
│                       ├── CategoryCarousel
│                       ├── MetricsOverview
│                       ├── WeeklyCalendar
│                       ├── PlaceSection
│                       ├── PlaceSection
│                       ├── PlaceSection
│                       ├── MonthlyEventBanner
│                       └── Text
└── BottomNavigationBar
```

**Justificación de la estructura:**

- `SingleChildScrollView` permite que el contenido sea desplazable en pantallas pequeñas.
- `ConstrainedBox` limita el contenido a un ancho máximo de 1280 dp.
- `Column` ordena los bloques de forma vertical y dominante.
- `GridView` organiza las tarjetas de cada sección.
- `ListView` horizontal presenta las categorías en un carrusel.
- `Wrap` adapta el calendario semanal cuando el espacio horizontal es limitado.
- `BottomNavigationBar` mantiene visibles las opciones principales de navegación.

---

## 3. Implementación de Widgets Clave y Decisiones de Diseño

### 3.1. Widgets de contenido
La interfaz combina varios widgets de Flutter para construir una experiencia visual coherente.

#### Text
Se emplearon distintos estilos de texto para establecer una jerarquía visual:

- títulos principales mediante `headlineMedium`;
- encabezados de sección mediante `titleLarge` y `titleMedium`;
- textos descriptivos mediante `bodyMedium` y `bodySmall`;
- etiquetas de navegación mediante `labelMedium`.

Para textos largos se utilizaron `maxLines` y `TextOverflow.ellipsis`. Esto evita que una etiqueta o un valor supere el ancho disponible de una fila.

#### Image
Las imágenes se cargan desde recursos locales mediante `Image.asset`. Se utiliza `BoxFit.cover` para llenar el espacio disponible conservando la proporción visual de la fotografía.

El componente `GuideImage` encapsula la carga de imágenes y permite mantener un mismo tratamiento visual en toda la aplicación.

#### Icon
Los iconos se utilizan para identificar categorías, métricas y opciones de navegación. En los botones de navegación se emplean versiones de icono outline y filled para indicar visualmente la opción seleccionada.

Para mejorar la accesibilidad, se añadieron etiquetas semánticas mediante `Semantics`. En el código, cada indicador de métricas recibe una etiqueta descriptiva que informa al lector de pantalla sobre el valor y la categoría correspondiente.

### 3.2. Modelo de caja
La composición visual utiliza principalmente `Padding`, `SizedBox`, `Container`, `Card` y `BoxDecoration`.

#### Espaciado
Se mantiene una unidad de espaciado basada en múltiplos de 8 dp. Los valores principales son:

- `8 dp` para separaciones pequeñas;
- `16 dp` para separación entre componentes y contenido interno;
- `24 dp` para separación entre bloques;
- `32 dp` para separar grandes secciones verticalmente.

#### Padding y margin

- `Padding` se utiliza para separar el contenido del borde de un contenedor.
- `margin` de `Card` se define como cero cuando el diseño necesita una separación externa controlada por el contenedor padre.
- `SizedBox` proporciona espacios concretos cuando el tamaño debe conservar una dimensión específica.

#### Decoraciones
`BoxDecoration` se utiliza para aplicar bordes redondeados, colores de fondo y sombras. La aplicación mantiene una apariencia uniforme mediante radios de 8 dp y fondos claros que contrastan con los elementos principales.

> La incompatibilidad de `BoxDecoration` con algunos objetos de color debe revisarse al combinar fondos, degradados y colores de tema. En esta implementación se utiliza `BoxDecoration` con colores obtenidos de `ColorScheme`.

### 3.3. Layout flexible
Los layouts principales utilizan `Row`, `Column`, `Expanded` y `Flexible` para repartir el espacio proporcionalmente.

#### Row y Column
`Column` organiza la pantalla verticalmente. `Row` se utiliza en elementos que deben distribuir información horizontalmente, por ejemplo en las tarjetas de métricas y en los bloques de icono y texto.

#### Expanded y Flexible
`Expanded` se usa para permitir que un texto o un widget ocupe el espacio restante. En `MetricsOverview`, por ejemplo, el bloque de texto se coloca dentro de un `Expanded` para prevenir que el contenido se desborde.

`Flexible` resulta apropiado cuando un elemento debe recibir una parte proporcional del espacio sin forzar a ocupar toda la fila. En el proyecto, `Expanded` fue suficiente para los casos principales porque el contenido debía crecer hasta ocupar el espacio disponible.

#### Alineación
`mainAxisAlignment` controla la distribución de los elementos a lo largo del eje principal, mientras que `crossAxisAlignment` controla la alineación respecto al eje transversal. El uso combinado permite mantener tres distintos tipos de composición: centrada, alineada a la izquierda y distribuida.

### 3.4. Superposición y flujo
La interfaz utiliza `Stack` y `Wrap` para incorporar contenido superpuesto y variables.

#### Stack
En `GuideHero` y `CategoryCarousel`, `Stack` permite superponer una imagen, un degradado y el texto o icono de la categoría. El degradado oscuro mejora la legibilidad del texto blanco sobre fotografías.

#### Positioned
Aunque no se usó `Positioned` en la implementación actual, este widget sería útil para ubicar etiquetas o indicadores con una posición exacta sobre la imagen. En una versión futura podría usarse para colocar descuentos, estados o iconos flotantes.

#### Wrap
`Wrap` se utiliza en el calendario semanal cuando el ancho disponible es inferior a 520 dp. En esa situación, los siete días se distribuyen en líneas que se acomodan automáticamente. La configuración de `spacing` y `runSpacing` mantiene una separación constante entre celdas.

#### Clip behavior
`Clip.antiAlias` se utiliza en las tarjetas del carrusel para asegurar que los bordes de la imagen y el degradado respeten el radio de la tarjeta. Esto evita que los elementos gráficos se muestren fuera de los límites esperados.

---

## 4. Adaptabilidad y Prevención de Errores de Layout

### 4.1. Diseño adaptativo
La aplicación utiliza `LayoutBuilder` para decidir qué estructura usar según el ancho disponible. Esto permite adaptar la pantalla sin depender únicamente de la pantalla global del dispositivo.

#### Breakpoints implementados

| Ancho disponible | Comportamiento |
|---:|---|
| Menor a 520 dp | Dos columnas en lugares, festividades y gastronomía; dos columnas en métricas; calendario semanal en `Wrap` |
| Entre 520 y 959 dp | Tres columnas en lugares, festividades y gastronomía; cuatro columnas en métricas; calendario semanal en fila |
| 960 dp o más | Cuatro columnas en lugares, festividades y gastronomía; cuatro columnas en métricas; calendario semanal en fila |

La estructura se implementó de la siguiente manera:

```dart
final columns = switch (constraints.maxWidth) {
  < 520 => 2,
  < 960 => 3,
  _ => 4,
};
```

La decisión de usar `LayoutBuilder` es adecuada porque cada sección del proyecto necesita diferentes puntos de quiebre. `MediaQuery` sería más apropiado cuando existe una adaptación global para toda la aplicación.

### 4.2. Prevención de errores
Durante la validación se detectó un problema en el calendario semanal: la fórmula para calcular el ancho de cada celda podía generar una restricción negativa en pantallas muy estrechas.

El cálculo original era equivalente a:

```dart
(constraints.maxWidth - 24) / 4
```

Cuando el ancho disponible era menos de 24 dp, el resultado podía ser negativo. Flutter rechazó esa restricción, generando un error comparable a:

```text
BoxConstraints(w=-6.0, 0.0<=h<=Infinity; NOT NORMALIZED)
```

La corrección aplicada fue usar `clamp`:

```dart
final cellWidth = ((constraints.maxWidth - 24) / 4).clamp(
  0.0,
  constraints.maxWidth,
);
```

Además, `SingleChildScrollView` y `GridView.builder` con `shrinkWrap: true` permiten que el contenido vertical se adapte sin producir overflow en la pantalla. `NeverScrollableScrollPhysics` mantiene el scroll controlado por el contenedor principal.

### 4.3. Accesibilidad y UX
Se aplicaron criterios básicos de accesibilidad:

- contraste suficiente entre textos blancos y fondos oscuros;
- `Semantics` para describir métricas y calendarios;
- iconos con una medida visual y táctil suficiente;
- textos con `maxLines` y `ellipsis` para evitar desbordamientos;
- tamaños de fuente coherentes con la jerarquía tipográfica;
- áreas de contenido separadas mediante espacios uniformes.

La barra inferior contiene cuatro opciones con iconos y etiquetas. Los elementos están agrupados con `BottomNavigationBarType.fixed` para mantener una distribución estable en pantallas pequeñas.

### 4.4. Verificación con Flutter Inspector y pruebas
El panel de Flutter Inspector permite revisar el árbol de widgets, los límites de cada caja y los problemas de layout. En la validación se utilizó la prueba de widget para comprobar el diseño en distintos anchos.

El comando ejecutado fue:

```powershell
flutter test test/widget_test.dart
```

Las pruebas verificaron:

- ausencia de excepciones al representar una pantalla de 12 px de ancho;
- presencia de los textos principales y de los widgets clave;
- número correcto de columnas en los `GridView`;
- activación del `Wrap` en pantallas menores a 520 dp;
- activación del `Row` en pantallas iguales o mayores a 520 dp;
- colocación de los días de la semana en filas distintas o en una misma fila según el ancho.

---

## 5. Resultados y Evidencias

### 5.1. Capturas de pantalla

> **Espacio reservado para las capturas de evidencia. Inserte una imagen en cada sección y mantenga el título correspondiente.**

#### Captura 1: Vista móvil

```text
[INSERTAR CAPTURA: pantalla completa en dispositivo Android o emulador]
```

- **Dispositivo/ancho:** [móvil o emulador, ancho menor a 600 dp]
- **Descripción:** se observa la cabecera, el carrusel, los bloques de contenido y la barra inferior.

#### Captura 2: Vista tableta

```text
[INSERTAR CAPTURA: aplicación con ancho aproximado de 768 dp]
```

- **Dispositivo/ancho:** [tableta o simulador, ancho aproximado de 768 dp]
- **Descripción:** se comprueba la distribución de columnas y la separación entre bloques.

#### Captura 3: Vista escritorio

```text
[INSERTAR CAPTURA: pantalla con ancho de 1200 dp o superior]
```

- **Dispositivo/ancho:** [escritorio o navegador, ancho de 1200 dp o superior]
- **Descripción:** se verifica el contenido centrado y el aprovechamiento del espacio horizontal.

#### Captura 4: Panel de diagnóstico

```text
[INSERTAR CAPTURA: Flutter Inspector o debugPaintSizeEnabled]
```

- **Herramienta:** [Flutter Inspector / `debugPaintSizeEnabled`]
- **Descripción:** se comprueba la estructura del árbol de widgets y los límites de cada caja.

### 5.2. Evidencia de ejecución
El proyecto se ejecutó correctamente en el dispositivo Android identificado como `emulator-5554` con el siguiente comando:

```powershell
flutter run -d emulator-5554
```

La compilación generó el APK en:

```text
build\app\outputs\flutter-apk\app-debug.apk
```

El resultado de la prueba fue:

```text
00:02 +2: All tests passed!
```

### 5.3. Análisis de fragilidad
La sección más sensible al cambio de tamaño es el calendario semanal. El número de columnas cambia, el ancho de las celdas cambia y el comportamiento del layout pasa de `Row` a `Wrap` cuando el ancho disponible disminuye.

La fragilidad se debe a que el ancho de cada celda depende directamente de la suma de los espacios disponibles y de la separación entre elementos. La corrección con `clamp` elimina la posibilidad de generar una restricción negativa.

---

## 6. Dificultades Encontradas y Soluciones

### 6.1. Problemas técnicos
Durante la ejecución se produjo un error de layout en el calendario semanal. La diferencia entre el ancho total disponible y la separación de las celdas podía resultar en un ancho negativo.

El entorno de pruebas también identificó que el diseño debía verificarse en tamaños extremadamente pequeños. No se trató de un error de compilación ni de dependencias, sino de una incompatibilidad entre el cálculo del ancho y el modelo de restricciones de Flutter.

### 6.2. Soluciones aplicadas
Se aplicaron varias correcciones de acuerdo con los conceptos revisados en la sesión:

- se conservó la estructura móvil con `Wrap` para pantallas estrechas;
- se utilizó `LayoutBuilder` para seleccionar el layout apropiado;
- se añadió `clamp` para limitar el ancho de cada celda;
- se mantuvo `SingleChildScrollView` para permitir desplazamiento vertical;
- se usaron pruebas de widget para revisar diferentes anchos;
- se validó la aplicación con el dispositivo físico virtual Android.

### 6.3. Aprendizajes
El concepto más difícil de dominar fue el manejo del modelo de restricciones. En Flutter, un widget puede compilar correctamente y aun así presentar errores de layout cuando recibe anchos o límites incompatibles.

Para evitar problemas futuros, se debe validar el diseño en tamaños pequeños, medios y amplios. La combinación de `LayoutBuilder`, ajustes de `GridView`, `Wrap`, `Expanded` y pruebas de widget permite detectar estas condiciones antes de la entrega.

---

## 7. Conclusiones

El proyecto cumple con los objetivos de la sesión de UI declarativa y diseño responsivo. La interfaz de Cusco presenta la información de forma ordenada, con una estructura clara y una composición visual consistente.

Los paneles de contenidos, la cabecera visual, el carrusel, el calendario y las métricas fueron desarrollados como componentes reutilizables. El uso de `LayoutBuilder` permitió adaptar la disposición a distintos tamaños de pantalla sin duplicar por completo el código.

La corrección del problema del calendario demostró la importancia de validar las restricciones de ancho en Flutter. El proyecto puede mejorar en futuras entregas incorporando navegación interactiva, lógica de estado, búsqueda y contenido dinámico.

---

## 8. Anexos

### Anexo A: Código fuente
El código fuente principal está distribuido en:

- `lib/pages/cusco_guide_page.dart`
- `lib/widgets/category_carousel.dart`
- `lib/widgets/guide_hero.dart`
- `lib/widgets/metrics_overview.dart`
- `lib/widgets/place_section.dart`
- `lib/widgets/weekly_calendar.dart`
- `lib/theme/app_theme.dart`
- `lib/data/guide_data.dart`
- `lib/models/guide_models.dart`
- `test/widget_test.dart`

El repositorio remoto debe completarse con la URL real del proyecto.

### Anexo B: Tabla de autoevaluación según la rúbrica (20 puntos)

| Criterio | Puntuación máxima | Puntuación obtenida |
|---|---:|---:|
| Estructura y organización del proyecto | 5 | [ ] |
| Uso correcto de widgets y composición | 5 | [ ] |
| Diseño adaptativo y prevención de errores | 4 | [ ] |
| Calidad visual y experiencia de usuario | 4 | [ ] |
| Documentación y presentación técnica | 2 | [ ] |
| **Total** | **20** | **[ ]** |

La puntuación debe completarse por el estudiante o el docente según la rúbrica aplicable.

### Anexo C: Comandos utilizados

```powershell
flutter devices
flutter run -d emulator-5554
flutter test test/widget_test.dart
```

### Anexo D: Estado de los artefactos

| Artefacto | Estado |
|---|---|
| Código fuente | Disponible |
| APK de depuración | Generado |
| Pruebas de widget | Ejecutadas y aprobadas |
| Capturas móvil | Pendiente de captura |
| Capturas escritorio | Pendiente de captura |
| URL del repositorio | Pendiente de completar |
| Nombres de integrantes | Pendiente de completar |

---

## 9. Observaciones finales

Este informe documenta el proceso de desarrollo de la interfaz de la guía turística de Cusco, incluyendo la arquitectura, el diseño visual, la responsividad, las pruebas y la solución del problema de restricciones del calendario.

La presentación cumple con el esquema solicitado, pero los datos personales del equipo y las capturas gráficas deben completarse antes de la entrega final. Los resultados de compilación y pruebas confirmaron que la aplicación puede ejecutarse correctamente en el emulador Android elegido.
