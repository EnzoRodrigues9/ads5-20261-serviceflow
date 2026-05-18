import 'package:serviceflow/app/core/base/base.provider.dart';

import 'ordem_servico.model.dart';

class OrdemServicoProvider extends BaseProvider<OrdemServico> {
  @override
  String get endpoint => '/rest/v1/ordens_servico';

  @override
  Map<String, dynamic> toExternalFormat(
    OrdemServico os,
  ) {
    final data = {
      'cliente_id': os.clienteId,
      'tecnico_id': os.tecnicoId,
      'observacao': os.observacao,
      'pecas_aplicadas': os.pecasAplicadas,
      'valor_pecas': os.valorPecas,
      'foto_antes': os.fotoAntes,
      'foto_depois': os.fotoDepois,
      'assinatura': os.assinatura,
      'status': os.status,
      'ativo': os.ativo,
    };

    print('📦 JSON enviado OS: $data');
    print('📦 clienteId enviado: ${os.clienteId}');
    print('📦 tecnicoId enviado: ${os.tecnicoId}');

    return data;
  }

  @override
  OrdemServico fromExternalFormat(
    Map<String, dynamic> data,
  ) {
    return OrdemServico(
      id: data['id'] as int?,
      clienteId: data['cliente_id'] as int,
      tecnicoId: data['tecnico_id'] as int,
      observacao: data['observacao'] as String?,
      pecasAplicadas: data['pecas_aplicadas'] as String?,
      valorPecas: (data['valor_pecas'] ?? 0).toDouble(),
      fotoAntes: data['foto_antes'] as String?,
      fotoDepois: data['foto_depois'] as String?,
      assinatura: data['assinatura'] as String?,
      status: data['status'] as String? ?? 'Em aberto',
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
    OrdemServico os,
  ) async {
    print('🔍 Validando OS');
    print(
      'clienteId: ${os.clienteId}',
    );
    print(
      'tecnicoId: ${os.tecnicoId}',
    );

    if (os.clienteId <= 0) {
      print('❌ Cliente inválido');

      handleError(
        'validateBeforeSync',
        'Cliente inválido',
      );

      return false;
    }

    if (os.tecnicoId <= 0) {
      print('❌ Técnico inválido');

      handleError(
        'validateBeforeSync',
        'Técnico inválido',
      );

      return false;
    }

    print('✅ OS válida');

    return true;
  }
}
