import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';
import 'package:serviceflow/app/modules/servicos/servico.validation.dart';

class ServicoService
    extends BaseService<Servico, ServicoRepository, ServicoValidation> {
  ServicoService(
    ServicoValidation validation,
    ServicoRepository repository,
  ) : super(validation, repository);

  @override
  Servico cloneModelWithId(
    Servico model,
    int id,
  ) {
    return model.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Servico>> findByDescricao(
    String descricao,
  ) async {
    final db = await repository.getConnection();

    final result = await db.query(
      repository.tableName,
      where: 'descricao LIKE ?',
      whereArgs: ['%$descricao%'],
      orderBy: 'descricao ASC',
    );

    return result.map((map) => Servico.fromMap(map)).toList();
  }
}
