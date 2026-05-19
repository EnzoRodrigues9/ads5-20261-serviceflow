import 'package:serviceflow/app/core/base/base.repository.dart';

import 'usuario.model.dart';

class UsuarioRepository extends BaseRepository<Usuario> {
  @override
  String get tableName => 'usuarios';

  @override
  Usuario fromMap(Map<String, dynamic> map) {
    return Usuario.fromMap(map);
  }

  Future<bool> existsByEmail(String email) async {
    return await exists(
      'email = ?',
      [email],
    );
  }

  Future<bool> existsByEmailWithoutId(
    String email,
    int id,
  ) async {
    return await exists(
      'email = ? AND id != ?',
      [email, id],
    );
  }

  Future<void> updateId(int oldId, int newId) async {
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
