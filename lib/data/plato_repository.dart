import '../models/contenido.dart';
import '../models/plato.dart';
import 'contenido_repository.dart';

class PlatoRepository {
  PlatoRepository({ContenidoRepository? repository})
    : _repository = repository ?? ContenidoRepository();

  final ContenidoRepository _repository;

  Future<List<Plato>> listar({String? texto}) =>
      _repository.listarPlatos(texto: texto);

  Future<Plato?> obtenerPorId(int id) async =>
      await _repository.obtenerPorId(TipoContenido.plato, id) as Plato?;

  Future<int> insertar(Plato plato) => _repository.insertar(plato);
  Future<int> actualizar(Plato plato) => _repository.actualizar(plato);
  Future<int> eliminar(int id) => _repository.eliminar(TipoContenido.plato, id);
  Future<bool> existeNombre(String nombre, {int? excluirId}) => _repository
      .existeNombre(TipoContenido.plato, nombre, excluirId: excluirId);
}
