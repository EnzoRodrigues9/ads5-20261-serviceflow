import 'package:serviceflow/app/core/base/base.validation.dart';

import 'usuario.model.dart';
import 'usuario.repository.dart';

class UsuarioValidation
    extends BaseValidation<Usuario, UsuarioRepository> {
  UsuarioValidation(
    super.repository,
  );

  @override
  void validateFields(Usuario? model) {
    if (model == null) {
      throw Exception('Usuário inválido');
    }

    if (model.nomeCompleto.trim().isEmpty) {
      throw Exception('Nome obrigatório');
    }

    if (model.email.trim().isEmpty) {
      throw Exception('Email obrigatório');
    }

    if (!model.email.contains('@')) {
      throw Exception('Email inválido');
    }

    if (model.grupoId.trim().isEmpty) {
      throw Exception('Grupo obrigatório');
    }
  }

  @override
  Future<void> validateRulesCreate(
    Usuario model,
  ) async {
    if (await repository.existsByEmail(model.email)) {
      throw Exception(
        'Já existe um usuário com este email',
      );
    }
  }

  @override
  Future<void> validateRulesUpdate(
    Usuario model,
  ) async {
    if (await repository.existsByEmailWithoutId(
      model.email,
      model.id!,
    )) {
      throw Exception(
        'Já existe um usuário com este email',
      );
    }
  }
}