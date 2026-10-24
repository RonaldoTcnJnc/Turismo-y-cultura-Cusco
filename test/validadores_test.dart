import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/models/contenido.dart';
import 'package:guia_turistica_cusco/utils/validadores.dart';

void main() {
  group('Validadores.nombre', () {
    test('rechaza vacío y valores fuera del rango 4..80', () {
      expect(Validadores.nombre('  '), isNotNull);
      expect(Validadores.nombre('Cus'), isNotNull);
      expect(Validadores.nombre('a' * 81), isNotNull);
      expect(Validadores.nombre('Cusco'), isNull);
    });
  });

  group('Validadores.descripcion', () {
    test('requiere de 25 a 500 caracteres', () {
      expect(Validadores.descripcion('corta'), contains('25 caracteres'));
      expect(Validadores.descripcion('a' * 501), contains('500 caracteres'));
      expect(Validadores.descripcion('a' * 25), isNull);
    });
  });

  test('distrito, categoría y fecha son obligatorios/coherentes', () {
    expect(Validadores.distrito(null), 'Seleccione el distrito.');
    expect(Validadores.distrito('Cusco'), isNull);
    expect(Validadores.categoria(null), isNotNull);
    expect(Validadores.categoria(TipoContenido.lugar), isNull);
    expect(Validadores.fecha(null), 'Seleccione una fecha válida.');
    expect(Validadores.fecha(DateTime(2026, 2, 28)), isNull);
  });

  test('coordenadas numéricas respetan sus rangos y aceptan vacío', () {
    expect(Validadores.latitud(''), isNull);
    expect(Validadores.latitud('-90'), isNull);
    expect(Validadores.latitud('90.01'), contains('-90 y 90'));
    expect(Validadores.latitud('norte'), isNotNull);
    expect(Validadores.longitud('-180'), isNull);
    expect(Validadores.longitud('180.1'), contains('-180 y 180'));
  });

  test('precio opcional debe ser numérico y no negativo', () {
    expect(Validadores.precio(''), isNull);
    expect(Validadores.precio('0'), isNull);
    expect(Validadores.precio('12,50'), isNull);
    expect(
      Validadores.precio('-1'),
      'El precio debe ser un número mayor o igual a 0.',
    );
    expect(Validadores.precio('gratis'), isNotNull);
  });

  test('tipo de plato es obligatorio', () {
    expect(Validadores.tipoPlato(''), isNotNull);
    expect(Validadores.tipoPlato('Sopa'), isNull);
  });
}
