import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.model.dart';
import 'package:serviceflow/app/modules/tecnicos/tecnico.repository.dart';

class TecnicoValidation extends BaseValidation<Tecnico, TecnicoRepository> {
  TecnicoValidation(
    TecnicoRepository repository,
  ) : super(repository);

  @override
  void validateFields(Tecnico? model) {
    if (model == null) {
      throw Exception(
        'O técnico não pode ser nulo',
      );
    }

    if (model.nome.trim().isEmpty) {
      throw Exception(
        'O nome do técnico é obrigatório',
      );
    }
  }

  @override
  Future<void> validateRulesCreate(
    Tecnico model,
  ) async {
    final exists = await repository.existsByNome(
      model.nome,
    );

    if (exists) {
      throw Exception(
        'Já existe um técnico com este nome',
      );
    }
  }

  @override
  Future<void> validateRulesUpdate(
    Tecnico model,
  ) async {
    final exists = await repository.existsByNomeWithoutId(
      model.nome,
      model.id!,
    );

    if (exists) {
      throw Exception(
        'Já existe um técnico com este nome',
      );
    }
  }
}
