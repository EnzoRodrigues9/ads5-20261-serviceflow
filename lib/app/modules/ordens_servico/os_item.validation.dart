import 'package:serviceflow/app/core/base/base.validation.dart';

import 'os_item.model.dart';
import 'os_item.repository.dart';

class OsItemValidation extends BaseValidation<OsItem, OsItemRepository> {
  OsItemValidation(
    super.repository,
  );

  @override
  void validateFields(
    OsItem? model,
  ) {
    if (model == null) {
      throw Exception(
        'Item da OS inválido',
      );
    }

    if ((model.osId ?? 0) <= 0) {
      throw Exception(
        'OS inválida',
      );
    }

    if (model.servicoId <= 0) {
      throw Exception(
        'Serviço inválido',
      );
    }

    if ((model.precoSnapshot ?? 0) <= 0) {
      throw Exception(
        'Preço inválido',
      );
    }
  }

  @override
  Future<void> validateRulesCreate(
    OsItem model,
  ) async {}

  @override
  Future<void> validateRulesUpdate(
    OsItem model,
  ) async {}
}
