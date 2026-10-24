# Guía turística y cultural del Cusco

**Curso:** Desarrollo de Software II (IF616AIN), UNSAAC, 2026-II  
**Proyecto:** Proyecto 5, Guía Práctica 02, Sesión 7  
**Integrantes:** [Completar nombres y roles]  
**Repositorio de entrega:** `dsii-sesion7-guia-cusco`

Aplicación Flutter que conserva la interfaz de exploración de la Sesión 6 y añade persistencia local, búsqueda, filtros, operaciones CRUD, favoritos, mapa y aportes fotográficos. Las tarjetas del carrusel abren el listado de su categoría. «Evento del mes» elige la festividad futura más próxima usando la fecha actual del dispositivo.

## Integrantes y roles

| Integrante | Rol y responsabilidades |
|---|---|
| [Apellido, Nombre] | [Modelos, SQLite y repositorios] |
| [Apellido, Nombre] | [Pantallas, navegación y formularios] |
| [Apellido, Nombre] | [Sensores, pruebas y documentación] |

Ajustar la tabla a los integrantes reales antes de entregar.

## Persistencia y datos de prueba

SQLite es la fuente de verdad para lugares, festividades y platos. Una instalación nueva aplica índices y restricciones, y se inicializa con 6 lugares, 15 festividades y 5 platos. La versión actual del esquema es 7. Las migraciones incrementales preservan el contenido existente; `lugares_imagenes` almacena fotografías aportadas por visitantes sin modificar la portada de `lugares.ruta_imagen`, y sus filas se eliminan en cascada junto con el lugar.

- Android: `sqflite` en el almacenamiento privado de la app.
- Linux: `sqflite_common_ffi`; el sistema necesita `libsqlite3`.
- Web: `sqflite_common_ffi_web`, que guarda el archivo SQLite en IndexedDB. La persistencia web depende del mismo navegador y origen/puerto.
- SharedPreferences se reserva para favoritos (`tipo:id`), sección activa y último filtro. El perfil es temporal durante la sesión; las claves de perfil antiguas se eliminan al acceder al servicio.

Los días de Corpus Christi, Qoyllur Rit’i y Señor de los Temblores en la semilla son referenciales porque esas fechas cambian según el calendario religioso. Inti Raymi se registra el 24 de junio.

## Sensores, mapa y privacidad

La ubicación solo se solicita al abrir el mapa y después de explicar su finalidad. Si se niega el permiso o la ubicación no está disponible, la lista se mantiene y las distancias se ocultan. Cuando existe posición, los lugares con coordenadas se ordenan por distancia; se muestra `m` por debajo de 1000 m y `km` en los demás casos.

El mapa usa tiles de OpenStreetMap, sin API key, requiere conexión y muestra atribución a sus colaboradores. La lista ordenada por cercanía es el respaldo si los tiles no cargan.

Las fotografías elegidas se copian a `documents/imagenes/` en plataformas IO. En web se guardan como URI de datos en la base local del navegador. La cámara del formulario permite elegir una imagen para el contenido; desde el detalle de un lugar, cualquier visitante puede aportar fotos adicionales, que se muestran en una galería y no reemplazan la portada. La posición actual no se almacena en la base.

## Requisitos

- Flutter stable y Dart indicados por `pubspec.yaml`.
- Android Studio y Android SDK si se ejecuta en emulador o dispositivo Android.
- Para Linux desktop: CMake, Ninja, GTK y biblioteca SQLite (`libsqlite3`). En CachyOS/Arch se pueden instalar, si faltan, con `sudo pacman -S cmake ninja gtk3 sqlite`.
- Para web: Chromium o Chrome. La base web requiere que el navegador permita IndexedDB y workers.

Chrome y Linux son destinos de desarrollo; no se necesita Windows para crear o probar el APK Android.

## Ejecutar

En la raíz del proyecto:

```fish
flutter pub get
flutter devices
```

Android, usando el ID que muestre `flutter devices`:

```fish
flutter run -d emulator-5554
```

Web:

```fish
flutter run -d chrome
```

Linux desktop:

```fish
flutter run -d linux
```

Después de agregar o actualizar plugins, detén la ejecución anterior y usa `flutter run` para reconstruir; hot reload no reemplaza una reconstrucción nativa.

## Verificación

Verificación funcional más reciente (24 de octubre de 2026): `flutter analyze` sin issues y `flutter test` con 39 pruebas aprobadas. El APK debug se instaló y ejecutó en un dispositivo Android durante la validación de la app. Builds debug anteriores para web y Linux se registraron el 23 de octubre; no se repitieron en esta verificación.

```fish
flutter analyze
flutter test
flutter build apk --debug
flutter build web --debug
flutter build linux --debug
```

La semilla y los repositorios tienen pruebas de SQLite en memoria. Las pruebas de UI usan repositorios falsos para evitar acoplar Flutter Widget Test al isolate FFI.

## Evidencias

Guardar las capturas reales en `evidencias/`, por ejemplo:

- `01-lista-y-semilla.png`
- `02-alta-y-validacion.png`
- `03-detalle-y-favorito.png`
- `04-mapa-sin-permiso.png`
- `05-persistencia-tras-reinicio.png`

Las evidencias deben capturarse en el emulador/dispositivo durante la demostración; no se incluyen capturas ficticias en este repositorio.

## Documentos de entrega

- [Informe técnico Sesión 7](informe_sesion7.md)
- [Guion de demostración](guion_demo_sesion7.md)
- [Checklist de entrega](checklist_entrega_sesion7.md)
- [Atribuciones de imágenes](assets/images/ATRIBUTOS.md)
- [Informe de Sesión 6](informe_proyecto_sesion6.md), conservado como antecedente

Completar nombres/roles, URL del repositorio y evidencias antes de generar el ZIP.