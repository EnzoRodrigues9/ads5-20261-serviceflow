import 'package:serviceflow/app/core/base/base.service.dart';

import 'ordem_servico.model.dart';
import 'ordem_servico.repository.dart';
import 'ordem_servico.validation.dart';

class OrdemServicoService extends BaseService<OrdemServico,
    OrdemServicoRepository, OrdemServicoValidation> {
  OrdemServicoService(
    super.validation,
    super.repository,
  );

  @override
  OrdemServico cloneModelWithId(
    OrdemServico model,
    int id,
  ) {
    return model.copyWith(
      id: id,
    );
  }
}
