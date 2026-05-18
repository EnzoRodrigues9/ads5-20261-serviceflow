import 'package:serviceflow/app/core/base/base.schedule.dart';

import 'servico.model.dart';
import 'servico.provider.dart';
import 'servico.repository.dart';

class ServicoSchedule
    extends BaseSchedule<Servico, ServicoRepository, ServicoProvider> {
  static final ServicoSchedule _instance = ServicoSchedule._init();

  factory ServicoSchedule() => _instance;

  ServicoSchedule._init()
      : super(
          ServicoRepository(),
          ServicoProvider(),
        );

  @override
  String get featureName => 'servicos';

  @override
  Duration get syncInterval => const Duration(minutes: 5);

  Future<bool> syncPending() async {
    try {
      print(
        '🚀 Sync serviços iniciado',
      );

      final servicos = await repository.findAll();

      final pendentes = servicos
          .where(
            (s) => s.isSync == 0,
          )
          .toList();

      print(
        '📦 Serviços pendentes: ${pendentes.length}',
      );

      if (pendentes.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final servico in pendentes) {
        final valid = await provider.validateBeforeSync(
          servico,
        );

        if (!valid) {
          continue;
        }

        final newId = await provider.syncToCloudAndReturnId(
          servico,
        );

        if (newId != null) {
          await repository.updateId(
            servico.id!,
            newId,
          );

          successCount++;

          print(
            '✅ Serviço sincronizado com novo ID: $newId',
          );
        } else {
          print(
            '❌ Falha ao sincronizar serviço',
          );
        }
      }

      return successCount == pendentes.length;
    } catch (e, stack) {
      print(
        '💥 Erro ServicoSchedule: $e',
      );

      print(stack);

      return false;
    }
  }
}
