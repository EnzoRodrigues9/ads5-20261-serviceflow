import 'package:serviceflow/app/core/base/base.provider.dart';

import 'tecnico.model.dart';

class TecnicoProvider extends BaseProvider<Tecnico> {
  @override
  String get endpoint => '/rest/v1/tecnicos';

  @override
  Map<String, dynamic> toExternalFormat(
    Tecnico tecnico,
  ) {
    return {
      'nome': tecnico.nome,
      'especialidade': tecnico.especialidade,
      'ativo': tecnico.ativo,
    };
  }

  @override
  Tecnico fromExternalFormat(
    Map<String, dynamic> data,
  ) {
    return Tecnico(
      id: data['id'] as int?,
      nome: data['nome'] as String? ?? '',
      especialidade: data['especialidade'] as String?,
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
    Tecnico tecnico,
  ) async {
    if (tecnico.nome.trim().isEmpty) {
      handleError(
        'validateBeforeSync',
        'Nome obrigatório',
      );

      return false;
    }

    return true;
  }
}
