# Checklist de entrega: Sesión 7

## Código y repositorio

- [ ] Crear o verificar el repositorio con nombre exacto `dsii-sesion7-guia-cusco`.
- [ ] Confirmar que README incluya integrantes, roles, persistencia, sensores, ejecución y datos de prueba.
- [ ] Completar integrantes y roles reales en README e informe.
- [ ] Reemplazar el marcador de URL por el enlace real del repositorio.
- [ ] Conservar atribuciones/licencias de imágenes en `assets/images/ATRIBUTOS.md`.
- [ ] Revisar que no se suban secretos, datos personales ni imágenes sin atribución.

## Revisión técnica

- [x] `flutter pub get` termina correctamente.
- [x] `flutter analyze` sin errores ni issues (verificado el 23 de octubre de 2026).
- [x] `flutter test` pasa toda la suite (25 pruebas, verificado el 23 de octubre de 2026).
- [x] `flutter build apk --debug` termina correctamente (23 de octubre de 2026; con advertencias de toolchain Java/Gradle y API deprecada de geolocator).
- [x] `flutter build web --debug` termina correctamente (23 de octubre de 2026).
- [x] `flutter build linux --debug` termina correctamente (23 de octubre de 2026).
- [ ] Ejecutar el flujo en emulador/teléfono después de cambios de plugins; hot reload no basta.
- [ ] Registrar contenido, cerrar completamente y reabrir para demostrar persistencia.
- [ ] Probar el rechazo de permiso; la lista de lugares debe seguir disponible.
- [ ] Capturar pantallas reales y agregarlas en `evidencias/`.

## Documentos

- [x] Revisar [README.md](README.md); faltan nombres/roles y evidencias reales.
- [ ] Completar y revisar [informe_sesion7.md](informe_sesion7.md), con máximo seis páginas al exportar.
- [ ] Ensayar [guion_demo_sesion7.md](guion_demo_sesion7.md), duración máxima diez minutos.
- [ ] Completar autoevaluación con la rúbrica oficial, no dejar puntajes de ejemplo.

## Archivo ZIP

- [ ] Generar el archivo con nombre exacto `ApellidoNombre_GuiaCuscoSesion7.zip` (reemplazar por el apellido/nombre acordado).
- [ ] Excluir `build/` y `.dart_tool/` del ZIP.
- [ ] No incluir caches, APKs temporales ni archivos de log innecesarios.
- [ ] Incluir `lib/`, `assets/`, `test/`, `web/` (WASM y service worker requeridos), archivos de plataforma necesarios y documentación.
- [ ] Verificar que el ZIP abre y contiene el proyecto en su raíz.

Comandos de validación recomendados antes del empaquetado:

```fish
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

En CachyOS, empaquetar con una herramienta ZIP que permita excluir explícitamente `build/` y `.dart_tool/`; no es necesario ejecutar `flutter clean` sobre el directorio de trabajo compartido para crear el archivo.