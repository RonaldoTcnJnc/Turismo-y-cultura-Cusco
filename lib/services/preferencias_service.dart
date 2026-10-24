import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constantes.dart';

class PreferenciasService {
  Future<SharedPreferences> _getPreferences() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('perfil_nombre');
    await preferences.remove('perfil_email');
    await preferences.remove('perfil_ciudad');
    await preferences.remove('perfil_bio');
    return preferences;
  }

  Future<int> obtenerUltimaSeccion() async {
    final preferences = await _getPreferences();
    final section = preferences.getInt(ClavesPreferencias.kUltimaSeccion) ?? 0;
    return section.clamp(0, 3);
  }

  Future<void> guardarUltimaSeccion(int index) async {
    final preferences = await _getPreferences();
    await preferences.setInt(ClavesPreferencias.kUltimaSeccion, index);
  }

  Future<String?> obtenerUltimoFiltro() async {
    final preferences = await _getPreferences();
    return preferences.getString(ClavesPreferencias.kUltimoFiltro);
  }

  Future<void> guardarUltimoFiltro(String filter) async {
    final preferences = await _getPreferences();
    await preferences.setString(ClavesPreferencias.kUltimoFiltro, filter);
  }

  Future<Set<String>> obtenerFavoritos() async {
    final preferences = await _getPreferences();
    return (preferences.getStringList(ClavesPreferencias.kFavoritos) ?? [])
        .toSet();
  }

  Future<bool> esFavorito(String clave) async =>
      (await obtenerFavoritos()).contains(clave);

  Future<void> cambiarFavorito(String clave) async {
    final preferences = await _getPreferences();
    final favorites =
        (preferences.getStringList(ClavesPreferencias.kFavoritos) ?? [])
            .toSet();
    if (!favorites.add(clave)) favorites.remove(clave);
    await preferences.setStringList(
      ClavesPreferencias.kFavoritos,
      favorites.toList()..sort(),
    );
  }

  Future<void> quitarFavorito(String clave) async {
    final preferences = await _getPreferences();
    final favorites =
        (preferences.getStringList(ClavesPreferencias.kFavoritos) ?? [])
            .toSet();
    favorites.remove(clave);
    await preferences.setStringList(
      ClavesPreferencias.kFavoritos,
      favorites.toList()..sort(),
    );
  }

}
