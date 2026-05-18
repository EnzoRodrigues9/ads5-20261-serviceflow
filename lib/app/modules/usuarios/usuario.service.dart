import 'usuario.model.dart';
import 'usuario.repository.dart';
import 'usuario.validation.dart';

class UsuarioService {
  final UsuarioRepository repository;
  final UsuarioValidation validation;

  UsuarioService(this.validation, this.repository);

  Future<Usuario> create(Usuario usuario) async {
    validation.validateFields(usuario);
    await validation.validateRulesCreate(usuario);

    await repository.insert(usuario);
    return usuario;
  }

  Future<Usuario> update(Usuario usuario) async {
    validation.validateFields(usuario);
    await validation.validateRulesUpdate(usuario);

    await repository.update(usuario);
    return usuario;
  }
}