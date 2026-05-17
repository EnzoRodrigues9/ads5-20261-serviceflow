import 'package:serviceflow/app/core/base/base.repository.dart';

import 'ordem_servico.model.dart';
import 'os_item.repository.dart';

class OrdemServicoRepository
    extends BaseRepository<OrdemServico> {

  final osItemRepository = OsItemRepository();

  @override
  String get tableName => 'ordens_servico';

  @override
  OrdemServico fromMap(
    Map<String, dynamic> map,
  ) {
    return OrdemServico.fromMap(map);
  }

  @override
  Future<List<OrdemServico>> findAllActive() async {
    final db = await getConnection();

    final result = await db.query(
      tableName,
      where: 'ativo = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
    );

    final ordens = <OrdemServico>[];

    for (final map in result) {
      final ordem = OrdemServico.fromMap(map);

      final itens = await osItemRepository.findByOsId(
        ordem.id!,
      );

      ordens.add(
        ordem.copyWith(
          itens: itens,
        ),
      );
    }

    return ordens;
  }

  @override
  Future<OrdemServico?> findById(int id) async {
    final db = await getConnection();

    final result = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    final ordem = OrdemServico.fromMap(
      result.first,
    );

    final itens = await osItemRepository.findByOsId(
      ordem.id!,
    );

    return ordem.copyWith(
      itens: itens,
    );
  }

  @override
  Future<int> insert(OrdemServico model) async {
    final db = await getConnection();

    final osId = await db.insert(
      tableName,
      model.toMap(),
    );

    for (final item in model.itens) {
      await osItemRepository.insert(
        item.copyWith(
          osId: osId,
        ),
      );
    }

    return osId;
  }

  @override
  Future<int> update(OrdemServico model) async {
    final db = await getConnection();

    final result = await db.update(
      tableName,
      model.toMap(),
      where: 'id = ?',
      whereArgs: [model.id],
    );

    await osItemRepository.deleteByOsId(
      model.id!,
    );

    for (final item in model.itens) {
      await osItemRepository.insert(
        item.copyWith(
          osId: model.id,
        ),
      );
    }

    return result;
  }
}