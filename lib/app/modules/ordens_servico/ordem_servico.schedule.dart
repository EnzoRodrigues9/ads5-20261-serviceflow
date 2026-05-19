import 'package:serviceflow/app/core/base/base.schedule.dart';

import 'ordem_servico.model.dart';
import 'ordem_servico.provider.dart';
import 'ordem_servico.repository.dart';

class OrdemServicoSchedule extends BaseSchedule<OrdemServico,
    OrdemServicoRepository, OrdemServicoProvider> {
  static final OrdemServicoSchedule _instance = OrdemServicoSchedule._init();

  factory OrdemServicoSchedule() => _instance;

  OrdemServicoSchedule._init()
      : super(
          OrdemServicoRepository(),
          OrdemServicoProvider(),
        );

  @override
  String get featureName => 'ordens_servico';

  @override
  Duration get syncInterval => const Duration(minutes: 5);

  Future<bool> syncById(
    int osId,
  ) async {
    try {
      print('🚀 syncById iniciado');
      print('🆔 Ordem ID: $osId');

      final ordens = await repository.findAll();

      final ordem = ordens.firstWhere(
        (o) => o.id == osId,
      );

      print(
        '📦 Ordem encontrada: ${ordem.id}',
      );

      final valid = await provider.validateBeforeSync(
        ordem,
      );

      print('✔️ Validação: $valid');

      if (!valid) {
        return false;
      }

      final result = await provider.syncToCloud(
        ordem,
      );

      print(
        '☁️ Resultado sync: $result',
      );

      if (result) {
        ordem.isSync = 1;

        await repository.update(
          ordem,
        );

        print(
          '✅ Ordem sincronizada',
        );

        return true;
      }

      print(
        '❌ Falha ao sincronizar ordem',
      );

      return false;
    } catch (e, stack) {
      print('💥 Erro syncById: $e');
      print(stack);

      return false;
    }
  }

  Future<bool> syncOpenOrders() async {
    try {
      print(
        '🚀 INICIOU syncOpenOrders',
      );

      final ordens = await repository.findAll();

      print(
        '📦 Total ordens: ${ordens.length}',
      );

      final pendentes = ordens
          .where(
            (o) => o.isSync == 0 && o.status.toLowerCase() != 'finalizada',
          )
          .toList();

      print(
        '⏳ Pendentes: ${pendentes.length}',
      );

      if (pendentes.isEmpty) {
        print(
          '✅ Nenhuma pendência',
        );

        return true;
      }

      int successCount = 0;

      for (final ordem in pendentes) {
        print(
          '----------------------------',
        );

        print(
          '📤 Tentando sync ordem ID: ${ordem.id}',
        );

        print(
          '📤 clienteId: ${ordem.clienteId}',
        );

        print(
          '📤 tecnicoId: ${ordem.tecnicoId}',
        );

        final valid = await provider.validateBeforeSync(
          ordem,
        );

        print('✔️ Validação: $valid');

        if (!valid) {
          continue;
        }

        final result = await provider.syncToCloud(
          ordem,
        );

        print(
          '☁️ Resultado sync: $result',
        );

        if (result) {
          ordem.isSync = 1;

          await repository.update(
            ordem,
          );

          successCount++;

          print(
            '✅ Ordem sincronizada',
          );
        } else {
          print(
            '❌ Falhou sync da ordem',
          );
        }
      }

      print('🏁 Finalizou sync');

      return successCount == pendentes.length;
    } catch (e, stack) {
      print(
        '💥 Erro syncOpenOrders: $e',
      );

      print(stack);

      return false;
    }
  }
}
