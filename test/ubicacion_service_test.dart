import 'package:flutter_test/flutter_test.dart';
import 'package:guia_turistica_cusco/services/ubicacion_service.dart';

void main() {
  test('formatea distancias en metros y kilómetros', () {
    final service = UbicacionService();
    expect(service.formatearDistancia(999.4), '999 m');
    expect(service.formatearDistancia(1000), '1.0 km');
    expect(service.formatearDistancia(2450), '2.5 km');
  });
}