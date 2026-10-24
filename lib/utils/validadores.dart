class Validadores {
  const Validadores._();

  static String? nombre(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Ingrese un nombre de 4 a 80 caracteres.';
    if (text.length < 4 || text.length > 80) {
      return 'El nombre debe tener entre 4 y 80 caracteres.';
    }
    return null;
  }

  static String? descripcion(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Escriba una descripción de al menos 25 caracteres.';
    }
    if (text.length < 25) {
      return 'La descripción debe tener al menos 25 caracteres.';
    }
    if (text.length > 500) {
      return 'La descripción no debe superar los 500 caracteres.';
    }
    return null;
  }

  static String? distrito(String? value) =>
      value == null || value.isEmpty ? 'Seleccione el distrito.' : null;

  static String? fecha(DateTime? value) {
    if (value == null || value.month < 1 || value.month > 12) {
      return 'Seleccione una fecha válida.';
    }
    final daysInMonth = DateTime(value.year, value.month + 1, 0).day;
    if (value.day < 1 || value.day > daysInMonth) {
      return 'Seleccione una fecha válida.';
    }
    return null;
  }

  static String? latitud(String? value) => _coordenada(
    value,
    minimo: -90,
    maximo: 90,
    mensaje: 'La latitud debe estar entre -90 y 90.',
  );

  static String? longitud(String? value) => _coordenada(
    value,
    minimo: -180,
    maximo: 180,
    mensaje: 'La longitud debe estar entre -180 y 180.',
  );

  static String? precio(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null || !parsed.isFinite || parsed < 0) {
      return 'El precio debe ser un número mayor o igual a 0.';
    }
    return null;
  }

  static String? tipoPlato(String? value) =>
      value == null || value.trim().isEmpty
      ? 'Indique el tipo de plato (por ejemplo: sopa o guiso).'
      : null;

  static String? categoria(Object? value) =>
      value == null ? 'Seleccione una categoría.' : null;

  static String? _coordenada(
    String? value, {
    required double minimo,
    required double maximo,
    required String mensaje,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final parsed = double.tryParse(text.replaceAll(',', '.'));
    if (parsed == null ||
        !parsed.isFinite ||
        parsed < minimo ||
        parsed > maximo) {
      return mensaje;
    }
    return null;
  }
}
