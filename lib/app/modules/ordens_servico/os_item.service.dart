import 'package:serviceflow/app/core/base/base.service.dart';

import 'os_item.model.dart';
import 'os_item.repository.dart';
import 'os_item.validation.dart';

class OsItemService
    extends BaseService<OsItem, OsItemRepository, OsItemValidation> {
  OsItemService(
    super.validation,
    super.repository,
  );

  @override
  OsItem cloneModelWithId(
    OsItem model,
    int id,
  ) {
    return model.copyWith(
      id: id,
    );
  }
}
