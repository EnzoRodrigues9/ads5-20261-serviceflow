import 'package:serviceflow/app/core/base/base.repository.dart';

import 'os_item.model.dart';

class OsItemRepository extends BaseRepository<OsItem> {
  @override
  String get tableName => 'os_itens';

  @override
  OsItem fromMap(Map<String, dynamic> map) {
    return OsItem.fromMap(map);
  }

  Future<List<OsItem>> findByOsId(int osId) async {
    final db = await getConnection();

    final result = await db.query(
      tableName,
      where: 'os_id = ?',
      whereArgs: [osId],
    );

    return result.map((e) => OsItem.fromMap(e)).toList();
  }

  Future<void> deleteByOsId(int osId) async {
    final db = await getConnection();

    await db.delete(
      tableName,
      where: 'os_id = ?',
      whereArgs: [osId],
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
