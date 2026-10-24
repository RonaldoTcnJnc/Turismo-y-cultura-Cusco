import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guia_turistica_cusco/services/preferencias_service.dart';
import 'package:guia_turistica_cusco/utils/constantes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'favoritos se persisten como claves y quitar no crea favoritos',
    () async {
      final service = PreferenciasService();

      await service.cambiarFavorito('lugar:3');
      await service.cambiarFavorito('plato:7');
      expect(await service.obtenerFavoritos(), {'lugar:3', 'plato:7'});

      await service.cambiarFavorito('lugar:3');
      expect(await service.obtenerFavoritos(), {'plato:7'});

      await service.quitarFavorito('festividad:5');
      expect(await service.obtenerFavoritos(), {'plato:7'});
    },
  );

  test(
    'elimina claves de perfil antiguas y limita el almacenamiento permitido',
    () async {
    SharedPreferences.setMockInitialValues({
      'perfil_nombre': 'Ana',
      'perfil_email': 'ana@cusco.app',
      'perfil_ciudad': 'Cusco',
      'perfil_bio': 'Perfil previo',
    });
    final service = PreferenciasService();

      await service.obtenerUltimaSeccion();
      await service.guardarUltimaSeccion(2);
      await service.guardarUltimoFiltro('Cusco');
      await service.cambiarFavorito('lugar:3');

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getKeys(), {
        ClavesPreferencias.kUltimaSeccion,
        ClavesPreferencias.kUltimoFiltro,
        ClavesPreferencias.kFavoritos,
      });
    },
  );

  test('la última sección queda limitada a las cuatro pestañas', () async {
    SharedPreferences.setMockInitialValues({
      ClavesPreferencias.kUltimaSeccion: 8,
    });
    final service = PreferenciasService();
    expect(await service.obtenerUltimaSeccion(), 3);
    await service.guardarUltimaSeccion(2);
    expect(await service.obtenerUltimaSeccion(), 2);
  });
}
