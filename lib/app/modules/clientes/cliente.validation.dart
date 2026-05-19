import 'package:serviceflow/app/core/base/base.validation.dart';
import 'package:serviceflow/app/modules/clientes/cliente.repository.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

class ClienteValidation extends BaseValidation<Cliente, ClienteRepository> {
  ClienteValidation(ClienteRepository repository) : super(repository);

  @override
  void validateFields(Cliente? model) {
    if (model == null || model.nome.trim().isEmpty) {
      throw Exception("O nome do cliente é obrigatório");
    }
    if (model.email.trim().isEmpty) {
      throw Exception("O email do cliente é obrigatório");
    }
    if (model.telefone.trim().isEmpty) {
      throw Exception("O telefone do cliente é obrigatório");
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(model.email)) {
      throw Exception("O email do cliente é inválido");
    }

    final telefoneLimpo = model.telefone.replaceAll(RegExp(r'[^0-9]'), '');

    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(telefoneLimpo)) {
      throw Exception("O telefone do cliente é inválido");
    }
  }

  @override
  Future<void> validateRulesCreate(Cliente model) async {
    bool emailExists = await repository.existsByEmail(model.email);
    if (emailExists) {
      throw Exception("Já existe um cliente com este email");
    }

    bool nomeExists = await repository.existsByNome(model.nome);
    if (nomeExists) {
      throw Exception("Já existe um cliente com este nome");
    }
  }

  @override
  Future<void> validateRulesUpdate(Cliente model) async {
    if (await repository.existsByEmailWithoutId(model.email, model.id!)) {
      throw Exception("Já existe um cliente com este email");
    }

    if (await repository.existsByNomeWithoutId(model.nome, model.id!)) {
      throw Exception("Já existe um cliente com este nome");
    }
  }
}
