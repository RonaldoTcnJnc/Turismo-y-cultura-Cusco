import '../models/contenido.dart';
import '../models/lugar.dart';
import 'contenido_repository.dart';

class LugarRepository {
  LugarRepository({ContenidoRepository? repository})
    : _repository = repository ?? ContenidoRepository();

  final ContenidoRepository _repository;

  Future<List<Lugar>> listar({String? texto, String? distrito}) =>
      _repository.listarLugares(texto: texto, distrito: distrito);

  Future<Lugar?> obtenerPorId(int id) async =>
      await _repository.obtenerPorId(_tipo, id) as Lugar?;

  Future<int> insertar(Lugar lugar) => _repository.insertar(lugar);
  Future<int> actualizar(Lugar lugar) => _repository.actualizar(lugar);
  Future<int> eliminar(int id) => _repository.eliminar(_tipo, id);
  Future<bool> existeNombre(String nombre, {int? excluirId}) =>
      _repository.existeNombre(_tipo, nombre, excluirId: excluirId);

  static const TipoContenido _tipo = TipoContenido.lugar;
}
