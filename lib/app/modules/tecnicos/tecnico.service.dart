import 'package:serviceflow/app/core/base/base.service.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.repository.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.validation.dart';

class TecnicoService
    extends BaseService<Tecnico, TecnicoRepository, TecnicoValidation> {
  TecnicoService(
    TecnicoValidation validation,
    TecnicoRepository repository,
  ) : super(validation, repository);

  @override
  Tecnico cloneModelWithId(
    Tecnico model,
    int id,
  ) {
    return model.copyWith(
      id: id,
      createdAt: DateTime.now(),
    );
  }

  Future<List<Tecnico>> findByNome(
    String nome,
  ) async {
    final db = await repository.getConnection();

    final result = await db.query(
      repository.tableName,
      where: 'nome LIKE ?',
      whereArgs: ['%$nome%'],
      orderBy: 'nome ASC',
    );

    return result.map((map) => Tecnico.fromMap(map)).toList();
  }

  Future<List<Tecnico>> listar() async {
    return await findAll();
  }
}
