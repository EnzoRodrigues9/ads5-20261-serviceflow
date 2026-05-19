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
