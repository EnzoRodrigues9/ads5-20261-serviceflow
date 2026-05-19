import 'package:serviceflow/app/core/base/base.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';

class ServicoRepository extends BaseRepository<Servico> {
  @override
  String get tableName => 'servicos';

  @override
  Servico fromMap(Map<String, dynamic> map) {
    return Servico.fromMap(map);
  }

  Future<bool> existsByDescricao(
    String descricao,
  ) async {
    return await exists(
      'descricao = ?',
      [descricao],
    );
  }

  Future<bool> existsByDescricaoWithoutId(
    String descricao,
    int id,
  ) async {
    return await exists(
      'descricao = ? AND id != ?',
      [descricao, id],
    );
  }

  Future<void> updateId(
    int oldId,
    int newId,
  ) async {
    final db = await getConnection();

    await db.update(
      tableName,
      {
        'id': newId,
        'is_sync': 1,
      },
      where: 'id = ?',
      whereArgs: [oldId],
    );
  }
}
