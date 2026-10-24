import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

class ResultadoUbicacion {
  const ResultadoUbicacion({this.posicion, this.motivo});

  final Position? posicion;
  final MotivoUbicacion? motivo;

  bool get disponible => posicion != null;
}

enum MotivoUbicacion {
  permisoDenegado,
  permisoDenegadoPermanentemente,
  servicioDesactivado,
  noDisponible,
}

class UbicacionService {
  Future<ResultadoUbicacion> obtenerPosicionActual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const ResultadoUbicacion(
          motivo: MotivoUbicacion.servicioDesactivado,
        );
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const ResultadoUbicacion(
          motivo: MotivoUbicacion.permisoDenegadoPermanentemente,
        );
      }
      if (permission == LocationPermission.denied) {
        return const ResultadoUbicacion(
          motivo: MotivoUbicacion.permisoDenegado,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return ResultadoUbicacion(posicion: position);
    } on PermissionDeniedException {
      return const ResultadoUbicacion(motivo: MotivoUbicacion.permisoDenegado);
    } catch (_) {
      return const ResultadoUbicacion(motivo: MotivoUbicacion.noDisponible);
    }
  }

  Future<bool> abrirAjustes() async {
    try {
      return await permissions.openAppSettings();
    } catch (_) {
      return false;
    }
  }

  double distanciaEnMetros({
    required double latitudOrigen,
    required double longitudOrigen,
    required double latitudDestino,
    required double longitudDestino,
  }) => Geolocator.distanceBetween(
    latitudOrigen,
    longitudOrigen,
    latitudDestino,
    longitudDestino,
  );

  String formatearDistancia(double metros) => metros < 1000
      ? '${metros.round()} m'
      : '${(metros / 1000).toStringAsFixed(1)} km';
}
