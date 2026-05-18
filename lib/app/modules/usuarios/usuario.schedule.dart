import 'package:serviceflow/app/core/base/base.schedule.dart';

import 'usuario.model.dart';
import 'usuario.repository.dart';
import 'usuario.provider.dart';

class UsuarioSchedule extends BaseSchedule<Usuario, UsuarioRepository, UsuarioProvider> {
  static final UsuarioSchedule _instance = UsuarioSchedule._init();

  factory UsuarioSchedule() => _instance;

  UsuarioSchedule._init()
      : super(
          UsuarioRepository(),
          UsuarioProvider(),
        );

  @override
  String get featureName => 'usuarios';

  @override
  Duration get syncInterval => const Duration(minutes: 5);

  Future<bool> syncPending() async {
    try {
      print('🚀 Sync usuários iniciado');

      final usuarios = await repository.findAll();

      final pendentes = usuarios.where((u) => u.isSync == 0).toList();

      print('📦 Usuários pendentes: ${pendentes.length}');

      if (pendentes.isEmpty) return true;

      int successCount = 0;

      for (final usuario in pendentes) {
        final valid = await provider.validateBeforeSync(usuario);

        if (!valid) continue;

        final newId = await provider.syncToCloudAndReturnId(usuario);

        if (newId != null) {
          await repository.updateId(usuario.id!, newId);

          successCount++;

          print('✅ Usuário sincronizado com novo ID: $newId');
        } else {
          print('❌ Falha ao sincronizar usuário');
        }
      }

      return successCount == pendentes.length;
    } catch (e, stack) {
      print('💥 Erro UsuarioSchedule: $e');
      print(stack);
      return false;
    }
  }
}