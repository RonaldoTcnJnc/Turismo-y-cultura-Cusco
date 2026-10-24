import '../models/contenido.dart';
import '../models/festividad.dart';
import 'contenido_repository.dart';

class FestividadRepository {
  FestividadRepository({ContenidoRepository? repository})
    : _repository = repository ?? ContenidoRepository();

  final ContenidoRepository _repository;

  Future<List<Festividad>> listar({
    String? texto,
    String? distrito,
    int? mes,
  }) => _repository.listarFestividades(
    texto: texto,
    distrito: distrito,
    mes: mes,
  );

  Future<Festividad?> obtenerPorId(int id) async =>
      await _repository.obtenerPorId(TipoContenido.festividad, id)
          as Festividad?;

  Future<int> insertar(Festividad festividad) =>
      _repository.insertar(festividad);
  Future<int> actualizar(Festividad festividad) =>
      _repository.actualizar(festividad);
  Future<int> eliminar(int id) =>
      _repository.eliminar(TipoContenido.festividad, id);
  Future<bool> existeNombre(String nombre, {int? excluirId}) => _repository
      .existeNombre(TipoContenido.festividad, nombre, excluirId: excluirId);
}
