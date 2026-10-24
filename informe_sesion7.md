# Informe técnico: Guía turística y cultural del Cusco

**Asignatura:** Desarrollo de Software II (IF616AIN)  
**Institución:** UNSAAC, Ingeniería Informática y de Sistemas  
**Semestre:** 2026-II  
**Actividad:** Guía Práctica 02, Sesión 7  
**Proyecto:** Proyecto 5  
**Integrantes y roles:** [Completar]  
**Repositorio:** [URL real del repositorio `dsii-sesion7-guia-cusco`]

> Borrador técnico. Para cumplir el máximo de seis páginas, exportar en tamaño A4, fuente 10–11 pt y espaciado sencillo. Completar integrantes, URL, capturas y autoevaluación con datos reales.

## 1. Introducción y objetivos

La aplicación transforma la guía visual desarrollada en Sesión 6 en una aplicación Flutter con almacenamiento local, operaciones CRUD y navegación entre contenidos. Se conserva la identidad visual, incluyendo portada, carrusel, tarjetas superpuestas, métricas, calendario cultural y navegación inferior.

Objetivos: almacenar y consultar lugares, festividades y platos; permitir búsqueda y filtros; registrar, editar y eliminar contenido; mantener favoritos y sección seleccionada; mostrar lugares cercanos sin fallar si se deniega el permiso; y calcular el próximo evento considerando el cambio de año.

## 2. Arquitectura

Se mantienen cuatro capas con la dirección `screens → data/services → models`. Las pantallas invocan repositorios y servicios; los modelos no importan Flutter, pantallas ni base de datos. `ContenidoRepository` concentra las operaciones comunes y las fachadas `LugarRepository`, `FestividadRepository` y `PlatoRepository` conservan contratos tipados.

```text
lib/
├── main.dart, app.dart
├── models/             Contenido, Lugar, Festividad, Plato
├── data/               DatabaseHelper, factories por plataforma, repositorios
├── services/           preferencias, ubicación y cámara
├── screens/            inicio, categoría, formulario, detalle, favoritos, mapa
├── widgets/            componentes visuales reutilizados
└── utils/              rutas, constantes y validadores
```

SQLite se selecciona con imports condicionales: `sqflite` en Android, `sqflite_common_ffi` en Linux y `sqflite_common_ffi_web` en navegador. En web, SQLite usa WASM, service worker e IndexedDB. Los datos siguen siendo locales al dispositivo/navegador; no se sincronizan entre plataformas.

## 3. Manejo de estado

`StatefulWidget` se usa donde cambian filtros, selección, formulario, ubicación, favoritos o resultados de consulta. `FutureBuilder` representa carga, error y datos; `IndexedStack` preserva la instancia de las cuatro pestañas. La interfaz usa `setState`, repositorios y futuros, sin introducir Provider/Riverpod.

| Pantalla/componente | Estado | Recursos | Liberación |
|---|---|---|---|
| Inicio/Explorar | Stateful | Timer de debounce de búsqueda | cancelado en `dispose` |
| Categoría | Stateful | TextEditingController de búsqueda | `dispose` |
| Formulario | Stateful | seis TextEditingController, FormKey | todos los controladores en `dispose` |
| Detalle | Stateful | estado de favorito/contenido | sin controlador propio |
| Favoritos | Stateful | futuro de lectura | sin suscripción persistente |
| Mapa | Stateful | posición y consulta | sin controlador persistente |
| Widgets presentacionales | Stateless | ninguno | no aplica |

Los futuros de persistencia se envuelven con `try/catch`. Después de los `await` que pueden continuar usando la pantalla, se comprueba `mounted` antes de actualizar estado, usar contexto o navegar.

## 4. Navegación

Los argumentos se envían mediante clases tipadas y se verifican en `onGenerateRoute`; no se extraen tipos mediante casts ciegos.

```mermaid
flowchart TD
  Inicio[Inicio / IndexedStack] --> Categoria[/categoria]
  Inicio --> Favoritos[/favoritos]
  Inicio --> Mapa[/mapa]
  Categoria --> Detalle[/contenido/detalle]
  Categoria --> Formulario[/contenido]
  Detalle --> Formulario
  Formulario -->|Contenido| Categoria
  Formulario -->|Contenido| Detalle
  Detalle -->|bool cambios| Categoria
  Detalle -->|bool cambios| Inicio
```

| Ruta | Argumentos validados | Retorno | Uso |
|---|---|---|---|
| `/` | ninguno | — | Inicio y pestañas |
| `/categoria` | `CategoriaRouteArgs` | `void` | lista por categoría |
| `/contenido` | `ContenidoFormRouteArgs` | `Contenido?` | alta/edición |
| `/contenido/detalle` | `ContenidoDetalleRouteArgs` | `bool?` | detalle/edición/borrado |
| `/favoritos` | ninguno | `void` | lista de favoritos |
| `/mapa` | ninguno | `void` | mapa y lista de lugares |

## 5. Persistencia

Se eligió SQLite porque proporciona restricciones, índices, consultas locales rápidas y transacciones para los datos relacionados con cada tipo de contenido. SharedPreferences se limita a preferencias pequeñas: claves de favoritos (`lugar:3`, `plato:7`), última pestaña y último filtro.

`DatabaseHelper` usa versión 1, `PRAGMA foreign_keys = ON`, creación inicial y `onUpgrade`. Como ejemplo de migración para subir el esquema a versión 2, `onUpgrade` agrega `fuente TEXT` a `lugares`; al activar esa versión se debe añadir también la columna en `onCreate`. Los índices cubren nombre, distrito y mes. Valores SQL variables usan `where` y `whereArgs`. La fecha `creado_en` se almacena como ISO 8601.

El formulario de perfil conserva sus cambios solo durante la sesión. No se persiste en SQLite ni en SharedPreferences, porque la especificación limita SharedPreferences a favoritos, pestaña activa y último filtro; las claves heredadas del perfil se eliminan al acceder al servicio.

| Tabla | Columnas principales | Reglas |
|---|---|---|
| `lugares` | id, nombre, distrito, descripcion, latitud, longitud, ruta_imagen, creado_en | nombre único; latitud −90..90; longitud −180..180 |
| `festividades` | id, nombre, mes, dia, descripcion, distrito, ruta_imagen, creado_en | nombre único; mes 1..12; día 1..31 |
| `platos` | id, nombre, descripcion, precio_ref, tipo, ruta_imagen, creado_en | nombre único; precio nulo o ≥ 0 |

La semilla agrega 6 lugares, 4 festividades y 5 platos al crear la BD. Las fechas seed de fiestas móviles son referenciales; Inti Raymi es 24 de junio. Para evidenciar persistencia, registrar un contenido, cerrar la app por completo, reabrir y capturar la fila presente en la lista: **[insertar captura real]**.

## 6. Formularios

El formulario unificado adapta sus controles a la categoría y precarga valores al editar. Las reglas están en `utils/validadores.dart`; el nombre único se consulta de forma asíncrona en repositorio con `excluirId` al editar. El botón queda deshabilitado e indica guardado mientras se persiste. El formulario es desplazable para acomodar teclado y campos.

| Campo | Regla principal |
|---|---|
| Nombre | obligatorio, 4–80 caracteres, único en su tabla |
| Categoría | selección requerida con `SegmentedButton`/`FormField` |
| Descripción | obligatoria, 25–500 caracteres |
| Distrito | obligatorio en lugares y festividades |
| Fecha | obligatoria en festividades, mes/día coherentes |
| Latitud/longitud | opcionales, −90..90 y −180..180 |
| Tipo de plato | obligatorio |
| Precio referencial | opcional, número ≥ 0 |
| Imagen | recomendada; cámara o galería |

Los mensajes explican qué corregir. Los textos de errores de unicidad y validación se verifican en pruebas de widget.

## 7. Sensores

Ubicación: permisos de ubicación aproximada y precisa en Android, `NSLocationWhenInUseUsageDescription` en iOS. Se explica el uso justo antes de solicitarlo. Si se niega, no se impide el acceso a la lista; si se deniega permanentemente, se ofrece Ajustes. La distancia se calcula con `Geolocator.distanceBetween` y solo se presenta para lugares con coordenadas.

Cámara/galería: permiso `CAMERA` y descripciones de cámara/fototeca en iOS. La cámara es opcional; el usuario puede elegir galería si no hay cámara disponible. En plataformas IO la foto se copia al directorio privado de documentos; en web se guarda localmente como URI de datos en la BD. La ubicación no se persiste.

El mapa usa OpenStreetMap y requiere conexión para tiles; `errorTileCallback` activa el aviso de respaldo y el botón de reintento cuando falla una carga. La lista ordenada por distancia funciona como alternativa. La licencia/atribución del contenido fotográfico se conserva en `assets/images/ATRIBUTOS.md`.

## 8. Resultados y evidencias

Validación reproducida el 23 de octubre de 2026: `flutter analyze` terminó con `No issues found`, `flutter test` aprobó 25 pruebas y completaron correctamente `flutter build apk --debug`, `flutter build web --debug` y `flutter build linux --debug`. El build Android mostró advertencias de acceso nativo Java/Gradle, opciones Java 8 obsoletas y API deprecada en geolocator, pero generó el APK. La suite cubre CRUD SQLite para las tres categorías, búsqueda, semilla, versión e índices, validadores, rutas tipadas, preferencias, breakpoints, distancia y cambio de año. Las pruebas de permisos, GPS y persistencia tras cierre real aún deben capturarse en dispositivo.

Evidencias pendientes de captura real para la entrega: alta y lista; reapertura persistente; edición y borrado; error de validación; permiso denegado; mapa con y sin tiles. Guardarlas en `evidencias/` y reemplazar los marcadores por imágenes.

## 9. Dificultades y soluciones

- En pantallas extremadamente estrechas, el calendario podía calcular ancho negativo: se limitó el ancho con `clamp` y se probó un viewport mínimo.
- `sqflite` no ofrecía directamente driver en web/Linux: se añadieron los adaptadores FFI y FFI web autorizados, más WASM/service worker.
- En diciembre, ordenar por diferencia absoluta de mes ubicaba enero lejos: el repositorio compara fechas de ocurrencia concretas hasta encontrar la siguiente fecha válida, incluyendo año nuevo y años bisiestos.
- Al guardar el perfil en web, Flutter reportaba literalmente `setState() callback argument returned a Future`: el callback flecha devolvía el futuro de carga. Se reemplazó por un bloque síncrono; además, el perfil dejó de ocupar SharedPreferences, que se reserva para las tres preferencias establecidas en la guía.
- En pruebas de widgets, el reloj simulado y FFI causaban timers pendientes: los tests UI usan repositorio falso; la integración SQLite se prueba aparte en memoria.
- Error observado al probar Flutter desktop antes de instalar herramientas: `Error: CMake is required for Linux development.` Solución: seleccionar Android/web o instalar CMake y Ninja para escritorio Linux.
- Los avisos de Gradle `A restricted method in java.lang.System has been called` no impidieron compilar el APK; el build final terminó correctamente.

## 10. Conclusiones

La aplicación integra persistencia local, CRUD, formularios validados, navegación tipada, favoritos y sensores, manteniendo la interfaz de Sesión 6. El repositorio aísla SQL, las preferencias respetan su alcance y los permisos degradan a funciones alternativas. Antes de entregar se deben completar integrantes y URL, generar evidencias reales y ejecutar builds y pruebas de permisos en dispositivo.

### Anexo A. Autoevaluación

| Criterio de rúbrica | Máximo | Autoevaluación |
|---|---:|---:|
| Persistencia y CRUD | [según rúbrica] | [completar] |
| Estado y ciclo de vida | [según rúbrica] | [completar] |
| Navegación y resultados | [según rúbrica] | [completar] |
| Validación de formularios | [según rúbrica] | [completar] |
| Sensores y degradación | [según rúbrica] | [completar] |
| Pruebas y documentación | [según rúbrica] | [completar] |

Completar puntajes usando la rúbrica oficial del Anexo A de la guía, no estimaciones inventadas.