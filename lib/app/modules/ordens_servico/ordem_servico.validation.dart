import 'package:serviceflow/app/core/base/base.validation.dart';

import 'ordem_servico.model.dart';
import 'ordem_servico.repository.dart';

class OrdemServicoValidation
    extends BaseValidation<OrdemServico, OrdemServicoRepository> {
  OrdemServicoValidation(
    super.repository,
  );

  @override
  void validateFields(
    OrdemServico? model,
  ) {
    if (model == null) {
      throw Exception(
        'Ordem de serviço inválida',
      );
    }

    if (model.clienteId <= 0) {
      throw Exception(
        'Selecione um cliente',
      );
    }

    if (model.tecnicoId <= 0) {
      throw Exception(
        'Selecione um técnico',
      );
    }
  }

  @override
  Future<void> validateRulesCreate(
    OrdemServico model,
  ) async {}

  @override
  Future<void> validateRulesUpdate(
    OrdemServico model,
  ) async {}
}
