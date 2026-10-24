import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../data/contenido_repository.dart';
import '../models/lugar.dart';
import '../navigation/route_arguments.dart';
import '../services/ubicacion_service.dart';
import '../utils/constantes.dart';
import '../widgets/contenido_list_tile.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({this.repository, this.locationService, super.key});

  final ContenidoRepository? repository;
  final UbicacionService? locationService;

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  static const LatLng _cusco = LatLng(-13.53195, -71.96746);

  ContenidoRepository get _repository =>
      widget.repository ?? ContenidoRepository();
  UbicacionService get _locationService =>
      widget.locationService ?? UbicacionService();

  late Future<List<Lugar>> _placesFuture;
  Position? _position;
  MotivoUbicacion? _locationFailure;
  bool _loadingLocation = false;
  String? _mapError;
  int _mapRetryVersion = 0;

  @override
  void initState() {
    super.initState();
    _placesFuture = _repository.listarLugares();
  }

  Future<void> _requestLocation() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Usar tu ubicación'),
        content: const Text(
          'Se consultará tu ubicación actual para centrar el mapa y ordenar '
          'los lugares por cercanía. Se usará solo mientras consultas esta '
          'pantalla y no se guardará en la base de datos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Ahora no'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
    if (!mounted || accepted != true) return;

    setState(() {
      _loadingLocation = true;
      _locationFailure = null;
    });
    final result = await _locationService.obtenerPosicionActual();
    if (!mounted) return;
    setState(() {
      _position = result.posicion;
      _locationFailure = result.motivo;
      _loadingLocation = false;
    });
  }

  Future<void> _openSettings() async {
    await _locationService.abrirAjustes();
    if (!mounted) return;
  }

  Future<void> _openDetail(Lugar place) async {
    final id = place.id;
    if (id == null) return;
    final changed = await Navigator.pushNamed<bool>(
      context,
      Rutas.kDetalleContenido,
      arguments: ContenidoDetalleRouteArgs(place),
    );
    if (!mounted) return;
    if (changed == true) {
      setState(() => _placesFuture = _repository.listarLugares());
    }
  }

  List<Lugar> _sortPlaces(List<Lugar> places) {
    final position = _position;
    final sorted = [...places];
    if (position == null) {
      sorted.sort(
        (first, second) =>
            first.nombre.toLowerCase().compareTo(second.nombre.toLowerCase()),
      );
      return sorted;
    }
    double distance(Lugar place) {
      if (place.latitud == null || place.longitud == null) {
        return double.infinity;
      }
      return _locationService.distanciaEnMetros(
        latitudOrigen: position.latitude,
        longitudOrigen: position.longitude,
        latitudDestino: place.latitud!,
        longitudDestino: place.longitud!,
      );
    }

    sorted.sort((first, second) => distance(first).compareTo(distance(second)));
    return sorted;
  }

  String _failureMessage(MotivoUbicacion failure) => switch (failure) {
    MotivoUbicacion.permisoDenegado =>
      'Se denegó el permiso. Puedes seguir explorando la lista sin distancias.',
    MotivoUbicacion.permisoDenegadoPermanentemente =>
      'El permiso está bloqueado. Actívalo en ajustes para mostrar distancias.',
    MotivoUbicacion.servicioDesactivado => 'La ubicación del dispositivo está desactivada. La lista sigue disponible.',
    MotivoUbicacion.noDisponible =>
      'No se pudo obtener la ubicación. La lista sigue disponible.',
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Lugares cercanos'),
      actions: [
        IconButton(
          tooltip: 'Usar ubicación actual',
          onPressed: _loadingLocation ? null : _requestLocation,
          icon: _loadingLocation
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location),
        ),
      ],
    ),
    body: FutureBuilder<List<Lugar>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(Textos.kErrorCarga),
                TextButton.icon(
                  onPressed: () => setState(
                    () => _placesFuture = _repository.listarLugares(),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        final places = _sortPlaces(snapshot.data ?? const <Lugar>[]);
        final position = _position;
        final center = position == null
            ? _cusco
            : LatLng(position.latitude, position.longitude);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            if (_locationFailure != null)
              _PermissionNotice(
                message: _failureMessage(_locationFailure!),
                showSettings:
                    _locationFailure ==
                    MotivoUbicacion.permisoDenegadoPermanentemente,
                onSettings: _openSettings,
              ),
            if (_mapError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'El mapa no está disponible ahora. Usa la lista de lugares.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Reintentar carga del mapa',
                      onPressed: () => setState(() {
                        _mapError = null;
                        _mapRetryVersion++;
                      }),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: FlutterMap(
                  key: ValueKey(
                    '${center.latitude},${center.longitude}-$_mapRetryVersion',
                  ),
                  options: MapOptions(initialCenter: center, initialZoom: 13),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'edu.unsaac.guia_turistica_cusco',
                      errorTileCallback: (tile, error, stackTrace) {
                        if (!mounted || _mapError != null) return;
                        setState(() => _mapError = error.toString());
                      },
                    ),
                    MarkerLayer(
                      markers: [
                        if (position != null)
                          Marker(
                            point: center,
                            width: 44,
                            height: 44,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 34,
                            ),
                          ),
                        for (final place in places)
                          if (place.latitud != null && place.longitud != null)
                            Marker(
                              point: LatLng(place.latitud!, place.longitud!),
                              width: 40,
                              height: 48,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 38,
                              ),
                            ),
                      ],
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('© OpenStreetMap contributors'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              position == null ? 'Lugares del Cusco' : 'Ordenados por cercanía',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (places.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text(Textos.kListaVacia)),
              ),
            for (final place in places) ...[
              _PlaceDistanceTile(
                place: place,
                distance:
                    position == null ||
                        place.latitud == null ||
                        place.longitud == null
                    ? null
                    : _locationService.formatearDistancia(
                        _locationService.distanciaEnMetros(
                          latitudOrigen: position.latitude,
                          longitudOrigen: position.longitude,
                          latitudDestino: place.latitud!,
                          longitudDestino: place.longitud!,
                        ),
                      ),
                onTap: () => _openDetail(place),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    ),
  );
}

class _PermissionNotice extends StatelessWidget {
  const _PermissionNotice({
    required this.message,
    required this.showSettings,
    required this.onSettings,
  });

  final String message;
  final bool showSettings;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (showSettings)
            TextButton.icon(
              onPressed: onSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Abrir ajustes'),
            ),
        ],
      ),
    ),
  );
}

class _PlaceDistanceTile extends StatelessWidget {
  const _PlaceDistanceTile({
    required this.place,
    required this.distance,
    required this.onTap,
  });

  final Lugar place;
  final String? distance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
    child: Column(
      children: [
        ContenidoListTile(contenido: place, onTap: onTap),
        if (distance != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 12),
            child: Row(
              children: [
                const Icon(Icons.near_me_outlined, size: 16),
                const SizedBox(width: 6),
                Text(distance!),
              ],
            ),
          ),
      ],
    ),
  );
}
