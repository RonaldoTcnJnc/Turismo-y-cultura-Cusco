# Guion de demostración en vivo

**Duración máxima:** 10 minutos  
**Entorno recomendado:** emulador Android `emulator-5554` o dispositivo Android.  
**Preparación:** tener la app instalada, empezar con un contenido de prueba identificable y permitir abrir el mapa. No borrar datos de la aplicación antes de demostrar persistencia.

| Tiempo | Acción y resultado esperado |
|---:|---|
| 0:00–1:00 | Abrir Explorar y explicar brevemente que las listas vienen de SQLite. Mostrar los datos semilla y mantener visible el diseño de Sesión 6. |
| 1:00–2:00 | Pulsar `VER TODO` en Lugares, tocar `Agregar`, registrar un lugar con nombre único, descripción válida y distrito; guardar. |
| 2:00–2:30 | Confirmar que el nuevo contenido aparece en la lista y abrir su detalle. |
| 2:30–3:00 | Cerrar por completo la app, no solo ponerla en segundo plano. Volver a abrirla desde el launcher. |
| 3:00–3:30 | Volver a Lugares y comprobar que el contenido sigue en la BD. Esto evidencia persistencia real. |
| 3:30–4:30 | Abrir detalle, editar descripción o distrito y guardar. Comprobar el resultado actualizado al volver al listado. |
| 4:30–5:15 | Desde el detalle iniciar eliminación; mostrar el diálogo, cancelar una vez y volver a abrirlo para confirmar eliminación. |
| 5:15–6:15 | Mostrar error de validación: crear un contenido, dejar nombre vacío o escribir menos de 4 caracteres, pulsar Guardar y mostrar el mensaje correctivo. No debe guardarse. |
| 6:15–7:00 | Abrir el mapa y mostrar el diálogo que explica la finalidad de la ubicación. Elegir `Ahora no` para demostrar que la app sigue operativa. |
| 7:00–8:00 | Si el dispositivo lo permite, volver a pulsar ubicación y denegar el permiso del sistema. Mostrar explicación y lista sin distancias. Si Android ofrece denegación permanente, mostrar el botón de Ajustes sin obligación de conceder el permiso. |
| 8:00–9:00 | Mostrar el orden por cercanía y las distancias solo si se concedió permiso; si no, explicar que la lista alfabética es el respaldo. Mostrar brevemente favoritos si queda tiempo. |
| 9:00–10:00 | Cierre: resumir SQLite, formularios, degradación por permiso y pruebas; señalar evidencias capturadas. |

## Lista de control previa

- [ ] Emulador o teléfono aparece en `flutter devices`.
- [ ] Ejecutar `flutter run -d <id-real>`; usar reconstrucción completa tras plugins.
- [ ] Elegir un nombre de contenido que no exista en la semilla.
- [ ] Tener lista la evidencia de antes/después de reinicio.
- [ ] Confirmar que no haya datos personales o fotos privadas en las capturas.
- [ ] En caso de no tener GPS o conexión, usar el flujo de permiso denegado; la app debe continuar con la lista.
