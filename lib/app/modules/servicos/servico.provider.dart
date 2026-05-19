import 'package:serviceflow/app/core/base/base.provider.dart';

import 'servico.model.dart';

class ServicoProvider extends BaseProvider<Servico> {
  @override
  String get endpoint => '/rest/v1/servicos';

  @override
  Map<String, dynamic> toExternalFormat(
    Servico servico,
  ) {
    return {
      'descricao': servico.descricao,
      'preco': servico.preco,
      'ativo': servico.ativo,
    };
  }

  @override
  Servico fromExternalFormat(
    Map<String, dynamic> data,
  ) {
    return Servico(
      id: data['id'] as int?,
      descricao: data['descricao'] as String? ?? '',
      preco: (data['preco'] ?? 0).toDouble(),
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
    Servico servico,
  ) async {
    if (servico.descricao.trim().isEmpty) {
      handleError(
        'validateBeforeSync',
        'Descrição inválida',
      );

      return false;
    }

    if (servico.preco < 0) {
      handleError(
        'validateBeforeSync',
        'Preço inválido',
      );

      return false;
    }

    return true;
  }
}
