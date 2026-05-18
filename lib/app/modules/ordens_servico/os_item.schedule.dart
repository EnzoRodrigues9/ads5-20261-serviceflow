import 'package:serviceflow/app/core/base/base.schedule.dart';

import 'os_item.model.dart';
import 'os_item.provider.dart';
import 'os_item.repository.dart';

class OsItemSchedule extends BaseSchedule<
    OsItem,
    OsItemRepository,
    OsItemProvider> {

  static final OsItemSchedule _instance =
      OsItemSchedule._init();

  factory OsItemSchedule() => _instance;

  OsItemSchedule._init()
      : super(
          OsItemRepository(),
          OsItemProvider(),
        );

  @override
  String get featureName => 'os_itens';

  @override
  Duration get syncInterval =>
      const Duration(minutes: 5);

/// Sincronizar itens de uma OS específica
Future<bool> syncByOsId(
  int osId,
) async {
  try {

    print('🚀 syncByOsId iniciado');
    print('🆔 OS ID: $osId');

    final itens =
        await repository.findByOsId(
      osId,
    );

    print('📦 Total itens encontrados: ${itens.length}');

    final pendingItens = itens.where(
      (i) => i.isSync == 0,
    ).toList();

    print('🕓 Itens pendentes: ${pendingItens.length}');

    if (pendingItens.isEmpty) {
      print('✅ Nenhum item pendente');
      return true;
    }

    int successCount = 0;

    for (final item in pendingItens) {

      print('----------------------------');
      print('🔄 Tentando sync item');
      print('ID: ${item.id}');
      print('osId: ${item.osId}');
      print('servicoId: ${item.servicoId}');
      print('isSync: ${item.isSync}');

      final valid =
          await provider.validateBeforeSync(
        item,
      );

      print('✔️ Validação: $valid');

      if (!valid) {
        print('❌ Validação falhou');
        continue;
      }

      final result =
          await provider.syncToCloud(
        item,
      );

      print('☁️ Resultado syncToCloud: $result');

      if (result) {

        item.isSync = 1;

        await repository.update(item);

        print('✅ Item sincronizado');

        successCount++;

      } else {

        print('❌ Sync item falhou');
      }
    }

    print(
      '📊 SuccessCount: $successCount / ${pendingItens.length}',
    );

    return successCount ==
        pendingItens.length;

  } catch (e, stack) {

    print('💥 Erro syncByOsId: $e');
    print(stack);

    return false;
  }
}
}