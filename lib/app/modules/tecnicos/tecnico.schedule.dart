import 'package:serviceflow/app/core/base/base.schedule.dart';

import 'tecnico.model.dart';
import 'tecnico.provider.dart';
import 'tecnico.repository.dart';

class TecnicoSchedule
    extends BaseSchedule<Tecnico, TecnicoRepository, TecnicoProvider> {
  static final TecnicoSchedule _instance = TecnicoSchedule._init();

  factory TecnicoSchedule() => _instance;

  TecnicoSchedule._init()
      : super(
          TecnicoRepository(),
          TecnicoProvider(),
        );

  @override
  String get featureName => 'tecnicos';

  @override
  Duration get syncInterval => const Duration(minutes: 5);

  Future<bool> syncPending() async {
    try {
      print(
        '🚀 Sync técnicos iniciado',
      );

      final tecnicos = await repository.findAll();

      final pendentes = tecnicos
          .where(
            (t) => t.isSync == 0,
          )
          .toList();

      print(
        '📦 Técnicos pendentes: ${pendentes.length}',
      );

      if (pendentes.isEmpty) {
        return true;
      }

      int successCount = 0;

      for (final tecnico in pendentes) {
        final valid = await provider.validateBeforeSync(
          tecnico,
        );

        if (!valid) {
          continue;
        }

        final newId = await provider.syncToCloudAndReturnId(
          tecnico,
        );

        if (newId != null) {
          await repository.updateId(
            tecnico.id!,
            newId,
          );

          successCount++;

          print(
            '✅ Técnico sincronizado com novo ID: $newId',
          );
        } else {
          print(
            '❌ Falha ao sincronizar técnico',
          );
        }
      }

      return successCount == pendentes.length;
    } catch (e, stack) {
      print(
        '💥 Erro TecnicoSchedule: $e',
      );

      print(stack);

      return false;
    }
  }
}
