import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/servicos/servico.model.dart';
import 'package:serviceflow/app/modules/servicos/servico.repository.dart';

class ServicoValidation
    extends BaseValidation<Servico, ServicoRepository> {
  ServicoValidation(
    ServicoRepository repository,
  ) : super(repository);

  @override
  void validateFields(Servico? model) {
    if (model == null) {
      throw Exception(
        'O serviço não pode ser nulo',
      );
    }

    if (model.descricao.trim().isEmpty) {
      throw Exception(
        'A descrição é obrigatória',
      );
    }

    if (model.preco <= 0) {
      throw Exception(
        'O preço deve ser maior que zero',
      );
    }
  }

  @override
  Future<void> validateRulesCreate(
    Servico model,
  ) async {
    final exists =
        await repository.existsByDescricao(
      model.descricao,
    );

    if (exists) {
      throw Exception(
        'Já existe um serviço com esta descrição',
      );
    }
  }

  @override
  Future<void> validateRulesUpdate(
    Servico model,
  ) async {
    final exists =
        await repository
            .existsByDescricaoWithoutId(
      model.descricao,
      model.id!,
    );

    if (exists) {
      throw Exception(
        'Já existe um serviço com esta descrição',
      );
    }
  }
}