import 'package:serviceflow/app/core/base/base.provider.dart';

import 'os_item.model.dart';

class OsItemProvider extends BaseProvider<OsItem> {
  @override
  String get endpoint => '/rest/v1/os_itens';

  @override
  Map<String, dynamic> toExternalFormat(
    OsItem item,
  ) {
    return {
      'os_id': item.osId,
      'servico_id': item.servicoId,
      'descricao_snapshot': item.descricaoSnapshot,
      'preco_snapshot': item.precoSnapshot,
      'ativo': item.ativo,
    };
  }

  @override
  OsItem fromExternalFormat(
    Map<String, dynamic> data,
  ) {
    return OsItem(
      id: data['id'] as int?,
      osId: data['os_id'] as int?,
      servicoId: data['servico_id'] as int,
      descricaoSnapshot: data['descricao_snapshot'] as String?,
      precoSnapshot: data['preco_snapshot'] != null
          ? (data['preco_snapshot'] as num).toDouble()
          : null,
      ativo: data['ativo'] as bool? ?? true,
      isSync: 1,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(
              data['created_at'].toString(),
            )
          : DateTime.now(),
    );
  }

  @override
  Future<bool> validateBeforeSync(
    OsItem item,
  ) async {
    print('🔍 Validando Item');
    print('osId: ${item.osId}');
    print('servicoId: ${item.servicoId}');

    if ((item.osId ?? 0) <= 0) {
      print('❌ OS inválida');

      handleError(
        'validateBeforeSync',
        'OS inválida',
      );

      return false;
    }

    if (item.servicoId <= 0) {
      print('❌ Serviço inválido');

      handleError(
        'validateBeforeSync',
        'Serviço inválido',
      );

      return false;
    }

    print('✅ Item válido');

    return true;
  }
}
