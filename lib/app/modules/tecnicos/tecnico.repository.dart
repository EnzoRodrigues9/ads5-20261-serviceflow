import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';

class TecnicoRepository extends BaseRepository<Tecnico> {
  @override
  String get tableName => 'tecnicos';

  @override
  Tecnico fromMap(Map<String, dynamic> map) {
    return Tecnico.fromMap(map);
  }

  Future<bool> existsByNome(String nome) async {
    return await exists(
      'nome = ?',
      [nome],
    );
  }

  Future<bool> existsByNomeWithoutId(
    String nome,
    int id,
  ) async {
    return await exists(
      'nome = ? AND id != ?',
      [nome, id],
    );
  }
}
