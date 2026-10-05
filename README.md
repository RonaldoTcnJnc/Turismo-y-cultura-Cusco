# Proyecto 5: Guía turística y cultural del Cusco

Aplicación Flutter de interfaz estática para la Sesión 6 de Desarrollo de Software II (UNSAAC, IF616AIN). La pantalla principal reúne lugares, festividades y gastronomía; los controles son visuales y no ejecutan acciones.

## Ejecutar y validar

Desde esta carpeta:

```powershell
flutter pub get
flutter run -d chrome
```

Para validar el código y los breakpoints:

```powershell
flutter analyze
flutter test
```

Breakpoints: con menos de 520 dp disponibles, las rejillas temáticas usan 2 columnas, las métricas 2 columnas y el calendario semanal se acomoda en dos filas con `Wrap` (4 + 3 días). Desde 520 dp, las rejillas usan 3 columnas hasta 959 dp y 4 desde 960 dp; las métricas usan 4 columnas y el calendario presenta los siete días en una fila.

La entrada de la aplicación está en [lib/main.dart](lib/main.dart). La interfaz se organiza por responsabilidad en `lib/app.dart`, `lib/theme/`, `lib/models/`, `lib/data/`, `lib/pages/` y `lib/widgets/`. Las fotografías reales se guardan en `assets/images/` por portada, categorías, lugares, festividades y gastronomía. `lib/data/` conserva únicamente las listas y rutas locales que usa la interfaz; la pantalla no descarga imágenes de la red.

Coloca los archivos con estos nombres para que se carguen automáticamente:

- `portada/cusco_portada.jpg`
- `categorias/lugares.jpg`, `festividades.jpg`, `gastronomia.jpg`, `tradiciones.jpg`
- `lugares/machu_picchu.jpg`, `sacsayhuaman.jpg`, `plaza_de_armas.jpg`, `valle_sagrado.jpg`
- `festividades/inti_raymi.jpg`, `corpus_christi.jpg`, `virgen_del_carmen.jpg`, `feria_de_pisac.jpg`
- `gastronomia/chiri_uchu.jpg`, `costillar_frutillada.jpg`, `anticuchos_cusquenos.jpg`, `quesos_cusquenos.jpg`

Las fotografías incluidas tienen sus créditos y licencias en [assets/images/ATRIBUTOS.md](assets/images/ATRIBUTOS.md). Después de reemplazar o agregar imágenes, ejecuta `flutter pub get` y vuelve a iniciar la aplicación.

## Capturas adaptativas

1. Ejecuta la app en Chrome y abre las herramientas de desarrollador con `F12`.
2. Activa la barra de dispositivos con `Ctrl+Shift+M` e ingresa `320 × 900` para evidenciar dos columnas, métricas 2×2 y calendario en dos filas.
3. Cambia el viewport a `1280 × 900` para evidenciar cuatro columnas, métricas en una fila y los siete días en una fila. Opcionalmente captura `800 × 900` para mostrar tres columnas en las secciones.
4. Guarda las imágenes en `evidencias/` como `01-movil-320.png`, `02-ancho-1280.png` y, opcionalmente, `03-intermedio-800.png`.

## Reparto sugerido (3 a 4 integrantes)

- Diseño de interfaz: jerarquía visual, paleta y selección de imágenes.
- Construcción de widgets: hero, carrusel, encabezados, tarjetas y evento destacado.
- Verificación de layout: anchos de 320, 800 y 1200 px; contraste, consola y overflow.
- Documentación y entrega: informe, capturas, revisión final y empaquetado. Con tres integrantes, combinar este rol con diseño.

## Preparar el ZIP

Desde PowerShell, entra primero a esta carpeta y limpia los artefactos locales; después regresa a la carpeta padre y crea el archivo:

```powershell
flutter clean
Set-Location ..
Compress-Archive -Path .\Sesion06_Guia_Turistica_Cusco -DestinationPath .\ApellidoNombre_ProyectoSesion6.zip -Force
```

Incluye las capturas en `evidencias/` antes de crear el ZIP. Reemplaza `ApellidoNombre` por los apellidos y nombres acordados por el grupo. El informe está en [informe_proyecto_sesion6.md](informe_proyecto_sesion6.md).
