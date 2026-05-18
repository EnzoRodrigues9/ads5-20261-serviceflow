import 'package:serviceflow/app/core/base/base.provider.dart';
import 'package:serviceflow/app/modules/clientes/cliente.model.dart';

class ClienteProvider extends BaseProvider<Cliente> {
  @override
  String get endpoint => '/rest/v1/clientes';

  @override
  Map<String, dynamic> toExternalFormat(Cliente cliente) {
    // Envia APENAS as colunas que existem no Supabase.
    // Campos removidos: id, created_at, is_sync (o BaseProvider já remove esses).
    // 'ativo' é bool no Supabase (coluna bool), Dart bool é mapeado corretamente.
    // 'updated_at' foi removido — NÃO existe na tabela (causava erro 400).
    return {
      'nome': cliente.nome,
      'email': cliente.email,
      'telefone': cliente.telefone,
      'documento': cliente.documento,
      'endereco': cliente.endereco,
      'cidade': cliente.cidade,
      'estado': cliente.estado,
      'cep': cliente.cep,
      'ativo': cliente.ativo,
    };
  }

  @override
  Cliente fromExternalFormat(Map<String, dynamic> data) {
    return Cliente(
      id: data['id'] as int?,
      nome: data['nome'] as String? ?? '',
      email: data['email'] as String? ?? '',
      telefone: data['telefone'] as String? ?? '',
      documento: data['documento'] as String?,
      endereco: data['endereco'] as String?,
      cidade: data['cidade'] as String?,
      estado: data['estado'] as String?,
      cep: data['cep'] as String?,
      ativo: data['ativo'] as bool? ?? true,
      isSync: 1,
      createdAt: data['created_at'] != null
          ? DateTime.tryParse(data['created_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  Future<bool> validateBeforeSync(Cliente cliente) async {
    if (cliente.nome.trim().isEmpty ||
        cliente.email.trim().isEmpty ||
        cliente.telefone.trim().isEmpty) {
      handleError('validateBeforeSync', 'Dados obrigatórios faltando');
      return false;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(cliente.email)) {
      handleError('validateBeforeSync', 'Email inválido: ${cliente.email}');
      return false;
    }
    return true;
  }
}